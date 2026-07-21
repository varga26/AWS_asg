module "network" {
  source   = "./network"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./security"
  vpc_id = module.network.vpc_id
}

module "db" {
  source                  = "./db"
  rds_sg_id               = module.security.rds_sg_id
  private_subnet_1_rds_id = module.network.private_subnet_1_rds_id
  private_subnet_2_rds_id = module.network.private_subnet_2_rds_id
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  parameter_group_name    = var.db_parameter_group_name
  db_username             = var.db_username
  db_password             = var.db_password
}

module "lb" {
  source              = "./lb"
  lb_sg_id            = module.security.lb_sg_id
  public_subnet_1_id  = module.network.public_subnet_1_id
  public_subnet_2_id  = module.network.public_subnet_2_id
  private_subnet_1_id = module.network.private_subnet_1_az_id
  private_subnet_2_id = module.network.private_subnet_2_az_id
  vpc_id              = module.network.vpc_id
  grafana_instance_id = module.vm.grafana_instance_id
}

data "aws_ami" "grafana" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["grafana-alloy-*"]
  }
}

module "vm" {
  source                = "./vm"
  public_subnet_1_id    = module.network.public_subnet_1_id
  private_subnet_1_id   = module.network.private_subnet_1_az_id
  bastion_sg_id         = module.security.bastion_sg_id
  grafana_sg_id         = module.security.grafana_sg_id
  key_pair_name         = module.asg.ollama_key_pair_name
  bastion_ami           = var.bastion_ami
  bastion_instance_type = var.bastion_instance_type
  grafana_ami           = data.aws_ami.grafana.id
  grafana_instance_type = var.grafana_instance_type
}

module "asg" {
  source                  = "./asg"
  grafana_private_ip      = module.vm.grafana_private_ip
  asg_sg_id               = module.security.asg_sg_id
  private_subnet_1_az_id  = module.network.private_subnet_1_az_id
  private_subnet_2_az_id  = module.network.private_subnet_2_az_id
  target_group_arn        = module.lb.target_group_arn
  ollama_target_group_arn = module.lb.ollama_target_group_arn
  ollama_base_url         = module.lb.ollama_base_url
  openwebui_database_url  = module.db.openwebui_database_url
  ollama_instance_type    = var.ollama_instance_type
  openwebui_instance_type = var.openwebui_instance_type
  webui_secret_key        = var.webui_secret_key
}

module "sns" {
  source   = "./sns"
  protocol = var.protocol
  endpoint = var.endpoint
}

module "cw_ollama" {
  source           = "./CloudeWatch"
  aws_region       = var.aws_region
  dashboard_name   = "ollama-dashboard"
  create_log_group = true
  log_group_name   = "/aws/ollama"

  alarm_actions = [module.sns.sns_topic_arn]
  alarms = [
    {
      name                = "[llm]-[test]-[ec2]-[high]-[cpu]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High CPU"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name }
    },
    {
      name                = "[llm]-[test]-[ec2]-[low]-[cpu]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 10
      description         = "Low CPU"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name }
    },

    {
      name                = "[llm]-[test]-[ec2]-[high]-[memory]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "mem_used_percent"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High memory usage"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name }
    },
    {
      name                = "[llm]-[test]-[ec2]-[low]-[memory]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "mem_used_percent"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 20
      description         = "Low memory usage"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name }
    },
    {
      name                = "[llm]-[test]-[ec2]-[high]-[disk-space]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "disk_used_percent"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High disk space used"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name, path = "/" }
    },
    {
      name                = "[llm]-[test]-[ec2]-[low]-[disk-space]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "disk_used_percent"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 20
      description         = "Low disk space used"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name, path = "/" }
    },
    {
      name                = "[llm]-[test]-[ec2]-[service]-[ollama]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "procstat_lookup_pid_count"
      namespace           = "CWAgent"
      period              = 300
      statistic           = "Average"
      threshold           = 1
      description         = "Service not running"
      dimensions          = { AutoScalingGroupName = module.asg.ollama_asg_name, exe = "ollama" }
    }

  ]

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.asg.ollama_asg_name]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "Ollama ASG CPU Utilization"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", module.asg.ollama_asg_name]]
        period  = 60
        stat    = "Maximum"
        region  = var.aws_region
        title   = "Ollama ASG In-Service Instances"
        view    = "timeSeries"
        stacked = false
      }
    },

    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6
      properties = {
        metrics = [["CWAgent", "mem_used_percent", "AutoScalingGroupName", module.asg.ollama_asg_name]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "Ollama ASG Memory Used %"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 6
      width  = 12
      height = 6
      properties = {
        metrics = [["CWAgent", "disk_used_percent", "AutoScalingGroupName", module.asg.ollama_asg_name]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "Ollama ASG Disk Used % (/)"
        view    = "timeSeries"
        stacked = false
      }
    }

  ]
}

module "cw_rds" {
  source         = "./CloudeWatch"
  aws_region     = var.aws_region
  dashboard_name = "rds-dashboard"

  alarm_actions = [module.sns.sns_topic_arn]
  alarms = [
    {
      name                = "[llm]-[test]-[db]-[high]-[cpu]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/RDS"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      description         = "High CPU Utilization"
      dimensions          = { DBInstanceIdentifier = module.db.rds_identifier }
    },
    {
      name                = "[llm]-[test]-[db]-[high]-[memory]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "FreeableMemory"
      namespace           = "AWS/RDS"
      period              = 300
      statistic           = "Average"
      threshold           = 268435456 # 256MB
      description         = "High memory usage (low freeable memory)"
      dimensions          = { DBInstanceIdentifier = module.db.rds_identifier }
    },
    {
      name                = "[llm]-[test]-[db]-[high]-[storage]"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 2
      metric_name         = "FreeStorageSpace"
      namespace           = "AWS/RDS"
      period              = 300
      statistic           = "Average"
      threshold           = 2147483648 # 2GB
      description         = "High storage usage (low free storage)"
      dimensions          = { DBInstanceIdentifier = module.db.rds_identifier }
    }
  ]

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", module.db.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS CPU Utilization"
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", module.db.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS Freeable Memory"
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", module.db.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS Free Storage Space"
      }
    }
  ]
}

module "cw_elb" {
  source         = "./CloudeWatch"
  aws_region     = var.aws_region
  dashboard_name = "elb-dashboard"

  alarm_actions = [module.sns.sns_topic_arn]
  alarms = [
    {
      name                = "[llm]-[test]-[elb]-[high]-[host-count]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "HealthyHostCount"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Average"
      threshold           = 5
      description         = "Too many healthy hosts"
      dimensions          = { LoadBalancer = module.lb.alb_arn_suffix, TargetGroup = module.lb.target_group_arn_suffix }
    },
    {
      name                = "[llm]-[test]-[elb]-[medium]-[4XX-errors]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "HTTPCode_Target_4XX_Count"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Sum"
      threshold           = 50
      description         = "Elevated 4XX errors"
      dimensions          = { LoadBalancer = module.lb.alb_arn_suffix }
    },
    {
      name                = "[llm]-[test]-[elb]-[medium]-[5XX-errors]"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 1
      metric_name         = "HTTPCode_Target_5XX_Count"
      namespace           = "AWS/ApplicationELB"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      description         = "Elevated 5XX errors"
      dimensions          = { LoadBalancer = module.lb.alb_arn_suffix }
    }
  ]

  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", module.lb.alb_arn_suffix, "TargetGroup", module.lb.target_group_arn_suffix]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "ALB Healthy Hosts (OpenWebUI)"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.lb.alb_arn_suffix],
        ]
        period  = 60
        stat    = "Sum"
        region  = var.aws_region
        title   = "ALB Request Count"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 0
      width  = 8
      height = 6
      properties = {
        metrics = [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.lb.alb_arn_suffix],
        ]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "ALB Target Response Time (s)"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6
      properties = {
        metrics = [
          ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", module.lb.alb_arn_suffix],
          ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", module.lb.alb_arn_suffix],
        ]
        period  = 60
        stat    = "Sum"
        region  = var.aws_region
        title   = "ALB 4XX / 5XX Error Count"
        view    = "timeSeries"
        stacked = false
      }
    },
    # ── NLB (Ollama internal) ─────────────────────────────────────────────────
    {
      type   = "metric"
      x      = 12
      y      = 6
      width  = 6
      height = 6
      properties = {
        metrics = [["AWS/NetworkELB", "HealthyHostCount", "LoadBalancer", module.lb.ollama_lb_arn_suffix, "TargetGroup", module.lb.ollama_target_group_arn_suffix]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "NLB Healthy Hosts (Ollama)"
        view    = "timeSeries"
        stacked = false
      }
    },
    {
      type   = "metric"
      x      = 18
      y      = 6
      width  = 6
      height = 6
      properties = {
        metrics = [["AWS/NetworkELB", "ActiveFlowCount", "LoadBalancer", module.lb.ollama_lb_arn_suffix]]
        period  = 60
        stat    = "Average"
        region  = var.aws_region
        title   = "NLB Active Connections (Ollama)"
        view    = "timeSeries"
        stacked = false
      }
    },
  ]
}
