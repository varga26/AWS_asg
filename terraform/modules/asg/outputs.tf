output "ollama_key_pair_name" {
  description = "SSH key pair name"
  value       = aws_key_pair.deployer.key_name
}

output "ollama_launch_template_id" {
  description = "Ollama Launch Template ID"
  value       = aws_launch_template.al1_template.id
}

output "ollama_asg_name" {
  description = "Ollama Auto Scaling Group name"
  value       = aws_autoscaling_group.ollama_asg.name
}

output "ollama_asg_arn" {
  description = "Ollama Auto Scaling Group ARN"
  value       = aws_autoscaling_group.ollama_asg.arn
}

output "ollama_asg_min_size" {
  description = "Ollama ASG minimum size"
  value       = aws_autoscaling_group.ollama_asg.min_size
}

output "ollama_asg_max_size" {
  description = "Ollama ASG maximum size"
  value       = aws_autoscaling_group.ollama_asg.max_size
}

output "ollama_asg_desired_capacity" {
  description = "Ollama ASG desired capacity"
  value       = aws_autoscaling_group.ollama_asg.desired_capacity
}

output "ollama_asg_health_check_type" {
  description = "Ollama ASG health check type"
  value       = aws_autoscaling_group.ollama_asg.health_check_type
}

output "openwebui_launch_template_id" {
  description = "OpenWebUI Launch Template ID"
  value       = aws_launch_template.al2_template.id
}

output "openwebui_asg_name" {
  description = "OpenWebUI Auto Scaling Group name"
  value       = aws_autoscaling_group.openwebui_asg.name
}

output "openwebui_asg_arn" {
  description = "OpenWebUI Auto Scaling Group ARN"
  value       = aws_autoscaling_group.openwebui_asg.arn
}

output "openwebui_asg_min_size" {
  description = "OpenWebUI ASG minimum size"
  value       = aws_autoscaling_group.openwebui_asg.min_size
}

output "openwebui_asg_max_size" {
  description = "OpenWebUI ASG maximum size"
  value       = aws_autoscaling_group.openwebui_asg.max_size
}

output "openwebui_asg_desired_capacity" {
  description = "OpenWebUI ASG desired capacity"
  value       = aws_autoscaling_group.openwebui_asg.desired_capacity
}

output "openwebui_asg_health_check_type" {
  description = "OpenWebUI ASG health check type"
  value       = aws_autoscaling_group.openwebui_asg.health_check_type
}

output "ollama_cpu_policy_name" {
  description = "Ollama CPU scaling policy name"
  value       = aws_autoscaling_policy.ollama_cpu_policy.name
}

output "openwebui_cpu_policy_name" {
  description = "OpenWebUI CPU scaling policy name"
  value       = aws_autoscaling_policy.openwebui_cpu_policy.name
}

output "asg_summary" {
  description = "Auto Scaling Groups summary"
  value = {
    ollama = {
      name             = aws_autoscaling_group.ollama_asg.name
      desired_capacity = aws_autoscaling_group.ollama_asg.desired_capacity
      min_size         = aws_autoscaling_group.ollama_asg.min_size
      max_size         = aws_autoscaling_group.ollama_asg.max_size
    }
    openwebui = {
      name             = aws_autoscaling_group.openwebui_asg.name
      desired_capacity = aws_autoscaling_group.openwebui_asg.desired_capacity
      min_size         = aws_autoscaling_group.openwebui_asg.min_size
      max_size         = aws_autoscaling_group.openwebui_asg.max_size
    }
  }
}

output "ssh_key_fingerprint" {
  description = "SSH key pair fingerprint"
  value       = aws_key_pair.deployer.fingerprint
}
