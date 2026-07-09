output "rds_endpoint" {
  description = "RDS database endpoint (address:port)"
  value       = aws_db_instance.default.endpoint
}

output "rds_address" {
  description = "RDS database address (hostname only)"
  value       = aws_db_instance.default.address
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.default.port
}

output "rds_resource_id" {
  description = "RDS database resource ID"
  value       = aws_db_instance.default.resource_id
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.default.db_name
}

output "rds_username" {
  description = "RDS database master username"
  value       = aws_db_instance.default.username
  sensitive   = true
}

output "rds_engine" {
  description = "RDS database engine"
  value       = aws_db_instance.default.engine
}

output "rds_engine_version" {
  description = "RDS database engine version"
  value       = aws_db_instance.default.engine_version
}

output "rds_instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.default.instance_class
}

output "rds_allocated_storage" {
  description = "Allocated storage in GB"
  value       = aws_db_instance.default.allocated_storage
}

output "db_subnet_group_name" {
  description = "DB Subnet Group Name"
  value       = aws_db_subnet_group.default.name
}

output "db_connection_string" {
  description = "PostgreSQL connection string template"
  value       = "postgresql://${aws_db_instance.default.username}:PASSWORD@${aws_db_instance.default.address}:${aws_db_instance.default.port}/${aws_db_instance.default.db_name}"
  sensitive   = true
}

output "openwebui_database_url" {
  description = "PostgreSQL connection string for Open WebUI"
  value       = "postgresql://${aws_db_instance.default.username}:${var.db_password}@${aws_db_instance.default.address}:${aws_db_instance.default.port}/${aws_db_instance.default.db_name}"
  sensitive   = true
}

output "rds_summary" {
  description = "RDS database summary"
  value = {
    endpoint          = aws_db_instance.default.endpoint
    engine            = aws_db_instance.default.engine
    version           = aws_db_instance.default.engine_version
    allocated_storage = "${aws_db_instance.default.allocated_storage}GB"
    instance_class    = aws_db_instance.default.instance_class
    multi_az          = aws_db_instance.default.multi_az
  }
}
