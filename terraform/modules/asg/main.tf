resource "aws_key_pair" "deployer" {
  key_name   = "new-ssh-key"
  public_key = var.public_key
}

data "aws_ami" "ollama" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["ollama-backend-*"]
  }
}

data "aws_ami" "openwebui" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["openwebui-frontend-*"]
  }
}

resource "aws_launch_template" "al1_template" {
  name_prefix            = "ollama-ubuntu-"
  image_id               = data.aws_ami.ollama.id
  instance_type          = var.ollama_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [var.asg_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_cw_profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ollama-instance"
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash

# ── Grafana Alloy (Prometheus remote_write) ──────────────────────────────────
cat > /etc/alloy/config.alloy << 'ALLOY_CFG'
prometheus.exporter.unix "default" { }

prometheus.scrape "default" {
  targets = prometheus.exporter.unix.default.targets
  forward_to = [prometheus.remote_write.default.receiver]
}

prometheus.remote_write "default" {
  endpoint {
    url = "http://${var.grafana_private_ip}:9090/api/v1/write"
  }
}
ALLOY_CFG
systemctl restart alloy

# ── CloudWatch Agent (mem / disk / procstat → CWAgent namespace) ─────────────
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CW_CFG'
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "InstanceId": "$${aws:InstanceId}"
    },
    "aggregation_dimensions": [["AutoScalingGroupName"]],
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["disk_used_percent"],
        "resources": ["/"],
        "metrics_collection_interval": 60
      },
      "procstat": [
        {
          "exe": "ollama",
          "measurement": ["pid_count"],
          "metrics_collection_interval": 60
        }
      ]
    }
  }
}
CW_CFG
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
EOF
  )
}

resource "aws_launch_template" "al2_template" {
  name_prefix            = "openwebui-ubuntu-"
  image_id               = data.aws_ami.openwebui.id
  instance_type          = var.openwebui_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [var.asg_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_cw_profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "openwebui-instance"
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
cat >/etc/openwebui.env <<'ENV'
OLLAMA_BASE_URL=${var.ollama_base_url}
OLLAMA_BASE_URLS=${var.ollama_base_url}
DATABASE_URL=${var.openwebui_database_url}
WEBUI_SECRET_KEY=${var.webui_secret_key}
ENV
chown root:openwebui /etc/openwebui.env
chmod 0640 /etc/openwebui.env
/opt/openwebui/venv/bin/pip install "open-webui[postgres]"
systemctl restart openwebui.service
EOF
  )
}

resource"aws_ssm_parameter" "webui_secret_key" {
  name   = "/webui/secret_key"
  value  = var.webui_secret_key
  type   = "SecureString"
}
resource "aws_autoscaling_group" "ollama_asg" {
  name_prefix         = "ollama-asg-"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = [var.private_subnet_1_az_id, var.private_subnet_2_az_id]
  target_group_arns   = [var.ollama_target_group_arn]

  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.al1_template.id
    version = aws_launch_template.al1_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }
}

resource "aws_autoscaling_group" "openwebui_asg" {
  name_prefix               = "openwebui-asg-"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  vpc_zone_identifier       = [var.private_subnet_1_az_id, var.private_subnet_2_az_id]
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.al2_template.id
    version = aws_launch_template.al2_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }
}

resource "aws_autoscaling_policy" "ollama_cpu_policy" {
  name                   = "ollama-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.ollama_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

resource "aws_autoscaling_policy" "openwebui_cpu_policy" {
  name                   = "openwebui-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.openwebui_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}
