variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default     = {}
}

variable "config_bucket_name" {
  type        = string
  description = "S3 bucket name for Ollama configuration and logs"
  default     = ""
}
