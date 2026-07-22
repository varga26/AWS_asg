variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "dashboard_name" {
  type = string
}

variable "widgets" {
  description = "List of widgets for the dashboard"
  type = list(object({
    type   = string
    x      = number
    y      = number
    width  = number
    height = number
    properties = any
  }))
}

variable "create_log_group" {
  type    = bool
  default = false
}

variable "log_group_name" {
  type    = string
  default = ""
}

variable "alarms" {
  description = "List of CloudWatch Alarms to create"
  type = list(object({
    name                = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    description         = string
    dimensions          = map(string)
  }))
  default = []
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm state changes"
  type        = list(string)
  default     = []
}
