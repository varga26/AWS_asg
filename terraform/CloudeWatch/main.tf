resource "aws_cloudwatch_log_group" "log_group" {
  count             = var.create_log_group ? 1 : 0
  name              = var.log_group_name
  retention_in_days = 14
}
resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      for i, w in var.widgets : {
        type   = w.type
        x      = w.x
        y      = w.y
        width  = w.width
        height = w.height
        properties = w.properties
      }
    ]
  })
}
resource "aws_cloudwatch_metric_alarm" "alarm" {
  for_each = { for a in var.alarms : a.name => a }

  alarm_name          = each.value.name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.description
  dimensions          = each.value.dimensions

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}
