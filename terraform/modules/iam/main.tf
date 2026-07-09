terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ollama-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ollama-ec2-role"
    }
  )
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ollama-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_iam_role_policy" "ssm_policy" {
  name = "${var.environment}-ssm-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMAccess"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ssm:UpdateInstanceInformation"
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2Messages"
        Effect = "Allow"
        Action = [
          "ec2messages:GetMessages"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.environment}-s3-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadConfig"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.config_bucket_name}/ollama/*"
      },
      {
        Sid    = "S3ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = "arn:aws:s3:::${var.config_bucket_name}"
      },
      {
        Sid    = "S3WriteLogsAndMetrics"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::${var.config_bucket_name}/logs/ollama/*"
      }
    ]
  })
}





resource "aws_iam_role_policy" "performance_insights_policy" {
  name = "${var.environment}-pi-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadPI"
        Effect = "Allow"
        Action = [
          "pi:GetResourceMetrics",
          "pi:DescribeDBInstances"
        ]
        Resource = "*"
      }
    ]
  })
}



# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
