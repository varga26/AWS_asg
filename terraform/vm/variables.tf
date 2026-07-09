variable "public_subnet_1_id" {
  description = "Public subnet 1 ID from network module"
  type        = string
}

variable "bastion_sg_id" {
  description = "Bastion security group ID from security module"
  type        = string
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
}