variable "availability_zone_1" {
  description = "The availability zone for the first subnet"
  default     = "us-east-1a"
  type        = string
}

variable "availability_zone_2" {
  description = "The availability zone for the second subnet"
  default     = "us-east-1b"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}