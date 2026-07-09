variable "lb_sg_id" {
  description = "Load Balancer security group ID from security module"
  type        = string
}

variable "public_subnet_1_id" {
  description = "Public subnet 1 ID from network module"
  type        = string
}

variable "public_subnet_2_id" {
  description = "Public subnet 2 ID from network module"
  type        = string
}

variable "private_subnet_1_id" {
  description = "Private compute subnet 1 ID from network module"
  type        = string
}

variable "private_subnet_2_id" {
  description = "Private compute subnet 2 ID from network module"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from network module"
  type        = string
}
