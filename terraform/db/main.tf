resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "my-db-subnet-group"
  subnet_ids = [var.private_subnet_1_rds_id, var.private_subnet_2_rds_id]

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_ssm_parameter" "db_username" {
  name   = "/db/username"
  value  = var.db_username
  type   = "SecureString"
}
resource "aws_ssm_parameter" "db_password" {
  name   = "/db/password"
  value  = var.db_password
  type   = "SecureString"
}