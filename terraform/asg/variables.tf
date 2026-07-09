variable "asg_sg_id" {
  description = "ASG security group ID from security module"
  type        = string
}

variable "private_subnet_1_az_id" {
  description = "Private subnet 1 (compute) ID from network module"
  type        = string
}

variable "private_subnet_2_az_id" {
  description = "Private subnet 2 (compute) ID from network module"
  type        = string
}

# variable "target_group_az1_arn" {
#   description = "Load balancer target group AZ1 ARN from LB module"
#   type        = string
# }

# variable "target_group_az2_arn" {
#   description = "Load balancer target group AZ2 ARN from LB module"
#   type        = string
# }

variable "target_group_arn" {
  description = "Load balancer target group ARN from LB module"
  type        = string
}

variable "ollama_target_group_arn" {
  description = "Internal Ollama target group ARN from LB module"
  type        = string
}

variable "ollama_base_url" {
  description = "Internal Ollama base URL for Open WebUI"
  type        = string
}

variable "openwebui_database_url" {
  description = "PostgreSQL DATABASE_URL for Open WebUI"
  type        = string
  sensitive   = true
}
