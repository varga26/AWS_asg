resource "aws_db_instance" "default" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres16"
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
