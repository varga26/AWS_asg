terraform {
    backend "s3" {
    bucket         = "terraform-state-bucket-7779823758347t093"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}