module "cw_ollama" {
  source           = "../cloudwatch"
  aws_region       = var.aws_region
  dashboard_name   = "ollama-dashboard"
  create_log_group = true
  log_group_name   = "/aws/ollama"

  alarm_actions = [var.sns_topic_arn]
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name }
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name }
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name }
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name }
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name, path = "/" }
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name, path = "/" }
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
      dimensions          = { AutoScalingGroupName = var.ollama_asg_name, exe = "ollama" }
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
        metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.ollama_asg_name]]
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
        metrics = [["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.ollama_asg_name]]
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
        metrics = [["CWAgent", "mem_used_percent", "AutoScalingGroupName", var.ollama_asg_name]]
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
        metrics = [["CWAgent", "disk_used_percent", "AutoScalingGroupName", var.ollama_asg_name]]
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
  source           = "../cloudwatch"
  aws_region     = var.aws_region
  dashboard_name = "rds-dashboard"

  alarm_actions = [var.sns_topic_arn]
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
      dimensions          = { DBInstanceIdentifier = var.rds_identifier }
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
      dimensions          = { DBInstanceIdentifier = var.rds_identifier }
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
      dimensions          = { DBInstanceIdentifier = var.rds_identifier }
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
        metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier]]
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
        metrics = [["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", var.rds_identifier]]
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
        metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_identifier]]
        period  = 300
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS Free Storage Space"
      }
    }
  ]
}

module "cw_elb" {
  source           = "../cloudwatch"
  aws_region     = var.aws_region
  dashboard_name = "elb-dashboard"

  alarm_actions = [var.sns_topic_arn]
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
      dimensions          = { LoadBalancer = var.alb_arn_suffix, TargetGroup = var.target_group_arn_suffix }
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
      dimensions          = { LoadBalancer = var.alb_arn_suffix }
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
      dimensions          = { LoadBalancer = var.alb_arn_suffix }
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
        metrics = [["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]]
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
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
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
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix],
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
          ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.alb_arn_suffix],
          ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix],
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
        metrics = [["AWS/NetworkELB", "HealthyHostCount", "LoadBalancer", var.ollama_lb_arn_suffix, "TargetGroup", var.ollama_target_group_arn_suffix]]
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
        metrics = [["AWS/NetworkELB", "ActiveFlowCount", "LoadBalancer", var.ollama_lb_arn_suffix]]
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


