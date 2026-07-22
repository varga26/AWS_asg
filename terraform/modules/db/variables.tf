variable "db_username" {
  type        = string
  description = "DB username"
}

variable "db_password" {
  type        = string
  description = "DB password"
}

variable "rds_sg_id" {
  description = "RDS security group ID from security module"
  type        = string
}

variable "private_subnet_1_rds_id" {
  description = "Private RDS subnet 1 ID from network module"
  type        = string
}

variable "private_subnet_2_rds_id" {
  description = "Private RDS subnet 2 ID from network module"
  type        = string
}

variable "allocated_storage" {
  type = number
}

variable "db_name" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "parameter_group_name" {
  type = string
}