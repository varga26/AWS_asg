output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value = [
    module.network.public_subnet_1_id,
    module.network.public_subnet_2_id
  ]
}

output "private_compute_subnet_ids" {
  description = "IDs of private compute subnets"
  value = [
    module.network.private_subnet_1_az_id,
    module.network.private_subnet_2_az_id
  ]
}

output "private_db_subnet_ids" {
  description = "IDs of private database subnets"
  value = [
    module.network.private_subnet_1_rds_id,
    module.network.private_subnet_2_rds_id
  ]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.network.internet_gateway_id
}

output "nat_gateway_1_ip" {
  description = "Elastic IP of NAT Gateway 1"
  value       = module.network.nat_gateway_1_public_ip
}

output "nat_gateway_2_ip" {
  description = "Elastic IP of NAT Gateway 2"
  value       = module.network.nat_gateway_2_public_ip
}

output "load_balancer_sg_id" {
  description = "Security group ID for load balancer"
  value       = module.security.lb_sg_id
}

output "bastion_sg_id" {
  description = "Security group ID for Bastion host"
  value       = module.security.bastion_sg_id
}

output "asg_sg_id" {
  description = "Security group ID for ASG instances (Ollama & OpenWebUI)"
  value       = module.security.asg_sg_id
}

output "rds_sg_id" {
  description = "Security group ID for RDS database"
  value       = module.security.rds_sg_id
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.db.rds_endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS database address (hostname only)"
  value       = module.db.rds_address
  sensitive   = true
}

output "rds_port" {
  description = "RDS database port"
  value       = module.db.rds_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.db.rds_database_name
}

output "rds_username" {
  description = "RDS database master username"
  value       = module.db.rds_username
  sensitive   = true
}

output "alb_dns_name" {
  description = "DNS name of the load balancer - use this to access OpenWebUI"
  value       = module.lb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = module.lb.alb_arn
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.lb.alb_zone_id
}

output "bastion_public_ip" {
  description = "Public IP of Bastion host - SSH gateway to private instances"
  value       = module.vm.bastion_public_ip
}

output "bastion_private_ip" {
  description = "Private IP of Bastion host"
  value       = module.vm.bastion_private_ip
}

output "bastion_instance_id" {
  description = "Instance ID of Bastion host"
  value       = module.vm.bastion_instance_id
}

output "ollama_asg_name" {
  description = "Name of Ollama Auto Scaling Group"
  value       = module.asg.ollama_asg_name
}

output "ollama_asg_arn" {
  description = "ARN of Ollama Auto Scaling Group"
  value       = module.asg.ollama_asg_arn
}

output "ollama_desired_capacity" {
  description = "Desired capacity for Ollama ASG"
  value       = module.asg.ollama_asg_desired_capacity
}

output "openwebui_asg_name" {
  description = "Name of OpenWebUI Auto Scaling Group"
  value       = module.asg.openwebui_asg_name
}

output "openwebui_asg_arn" {
  description = "ARN of OpenWebUI Auto Scaling Group"
  value       = module.asg.openwebui_asg_arn
}

output "openwebui_desired_capacity" {
  description = "Desired capacity for OpenWebUI ASG"
  value       = module.asg.openwebui_asg_desired_capacity
}

output "key_pair_name" {
  description = "SSH key pair name"
  value       = module.asg.ollama_key_pair_name
}
output "connection_info" {
  description = "Connection information for the deployed resources"
  value = {
    bastion_ssh_command = "ssh -i /path/to/new-aws-key.pem ubuntu@${module.vm.bastion_public_ip}"
    openwebui_url       = "http://${module.lb.alb_dns_name}"
    ollama_endpoint     = module.lb.ollama_base_url
    rds_connection      = module.db.rds_endpoint
  }
}

output "deployment_summary" {
  description = "Quick summary of deployed infrastructure"
  value = {
    environment         = "production"
    vpc_id              = module.network.vpc_id
    bastion_ip          = module.vm.bastion_public_ip
    alb_dns             = module.lb.alb_dns_name
    rds_endpoint        = module.db.rds_endpoint
    ollama_instances    = module.asg.ollama_asg_desired_capacity
    openwebui_instances = module.asg.openwebui_asg_desired_capacity
  }
  sensitive = true
}

