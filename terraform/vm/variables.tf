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

variable "bastion_ami" {
  description = "AMI ID for Bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for Bastion host"
  type        = string
}