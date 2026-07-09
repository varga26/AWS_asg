terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # Match Packer template
}

# Security group for Packer to SSH into build instances
resource "aws_security_group" "packer_builder" {
  name        = "packer-builder-sg"
  description = "Security group for Packer build instances"

  ingress {
    description = "SSH from anywhere (Packer builder)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "packer-builder"
  }
}

output "packer_security_group_id" {
  description = "Security group ID to use in Packer template"
  value       = aws_security_group.packer_builder.id
}
