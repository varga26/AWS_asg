variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type    = string
  default = "terraform-state-bucket-7779823758347t093"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "bastion_ami" {
  type    = string
  default = "ami-0886a1a9991170db6"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_engine_version" {
  type    = string
  default = "16"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_parameter_group_name" {
  type    = string
  default = "default.postgres16"
}

variable "ollama_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_username" {
  type    = string
  description = "DB username"
}

variable "db_password" {
  type    = string
  description = "DB password"
}

variable "openwebui_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "webui_secret_key" {
  type      = string
  default   = "t1-static-shared-secret-key-12345"
  sensitive = true
}
