variable "db_username" {
  type      = string
  default   = "vasil"
  sensitive = true
}

variable "db_password" {
  type      = string
  default   = "12345678vasil"
  sensitive = true
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