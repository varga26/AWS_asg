output "lb_sg_id" {
  description = "Load Balancer Security Group ID"
  value       = aws_security_group.lb_sg.id
}

output "lb_sg_name" {
  description = "Load Balancer Security Group Name"
  value       = aws_security_group.lb_sg.name
}

output "bastion_sg_id" {
  description = "Bastion Host Security Group ID"
  value       = aws_security_group.bastion_sg.id
}

output "bastion_sg_name" {
  description = "Bastion Host Security Group Name"
  value       = aws_security_group.bastion_sg.name
}

output "asg_sg_id" {
  description = "ASG (Ollama & OpenWebUI) Security Group ID"
  value       = aws_security_group.asg_sg.id
}

output "asg_sg_name" {
  description = "ASG Security Group Name"
  value       = aws_security_group.asg_sg.name
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_sg_name" {
  description = "RDS Security Group Name"
  value       = aws_security_group.rds_sg.name
}

output "security_groups_summary" {
  description = "Summary of all security groups"
  value = {
    load_balancer = aws_security_group.lb_sg.id
    bastion       = aws_security_group.bastion_sg.id
    asg           = aws_security_group.asg_sg.id
    rds           = aws_security_group.rds_sg.id
  }
}
