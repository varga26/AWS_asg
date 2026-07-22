output "alb_id" {
  description = "Load Balancer ID"
  value       = aws_lb.lb.id
}

output "alb_arn" {
  description = "Load Balancer ARN"
  value       = aws_lb.lb.arn
}

output "alb_dns_name" {
  description = "Load Balancer DNS name - use this to access OpenWebUI"
  value       = aws_lb.lb.dns_name
}

output "alb_zone_id" {
  description = "Load Balancer Zone ID (for Route53 alias records)"
  value       = aws_lb.lb.zone_id
}

output "alb_name" {
  description = "Load Balancer name"
  value       = aws_lb.lb.name
}

# output "target_group_az1_arn" {
#   description = "Target Group ARN for AZ1"
#   value       = aws_lb_target_group.lb_target_group_az1.arn
# }

# output "target_group_az1_name" {
#   description = "Target Group name for AZ1"
#   value       = aws_lb_target_group.lb_target_group_az1.name
# }

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.openwebui_tg.arn
}

output "target_group_arn_suffix" {
  description = "Target Group ARN Suffix"
  value       = aws_lb_target_group.openwebui_tg.arn_suffix
}

output "listener_arn" {
  description = "ALB Listener ARN"
  value       = aws_lb_listener.alb_listener.arn
}

output "ollama_target_group_arn" {
  description = "Internal Ollama target group ARN"
  value       = aws_lb_target_group.ollama_tg.arn
}

output "ollama_target_group_arn_suffix" {
  description = "Internal Ollama target group ARN suffix"
  value       = aws_lb_target_group.ollama_tg.arn_suffix
}

output "ollama_lb_arn_suffix" {
  description = "Internal Ollama load balancer ARN suffix"
  value       = aws_lb.ollama_internal.arn_suffix
}

output "ollama_internal_dns_name" {
  description = "Internal Ollama load balancer DNS name"
  value       = aws_lb.ollama_internal.dns_name
}

output "ollama_base_url" {
  description = "Base URL Open WebUI should use for Ollama"
  value       = "http://${aws_lb.ollama_internal.dns_name}:11434"
}

output "alb_arn_suffix" {
  description = "ALB ARN Suffix for CloudWatch metrics"
  value       = aws_lb.lb.arn_suffix
}

