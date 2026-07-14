resource "aws_key_pair" "deployer" {
  key_name   = "new-ssh-key"
  public_key = file("${path.module}/../../new-aws-key.pem.pub")
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
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ollama-instance"
    }
  }
}

resource "aws_launch_template" "al2_template" {
  name_prefix            = "openwebui-ubuntu-"
  image_id               = data.aws_ami.openwebui.id
  instance_type          = var.openwebui_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [var.asg_sg_id]
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
