output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.postgresql.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.postgresql.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.postgresql.endpoint
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.postgresql.address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.postgresql.port
}

output "db_name" {
  description = "Name of the database"
  value       = aws_db_instance.postgresql.db_name
}

output "db_username" {
  description = "Master username for the database"
  value       = aws_db_instance.postgresql.username
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.main.id
}

output "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.postgresql.identifier
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.postgresql.endpoint
}

output "read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = "" # Read replica creation disabled - PostgreSQL primary only
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.rds.dashboard_name}"
}

output "sqlserver_instance_id" {
  description = "SQL Server RDS instance identifier"
  value       = var.enable_sqlserver && length(aws_db_instance.sqlserver) > 0 ? aws_db_instance.sqlserver[0].identifier : null
}

output "sqlserver_endpoint" {
  description = "SQL Server RDS endpoint"
  value       = var.enable_sqlserver && length(aws_db_instance.sqlserver) > 0 ? aws_db_instance.sqlserver[0].endpoint : null
}

output "sqlserver_instance_class" {
  description = "SQL Server instance class (db.m5.xlarge)"
  value       = var.enable_sqlserver && length(aws_db_instance.sqlserver) > 0 ? aws_db_instance.sqlserver[0].instance_class : null
}

output "sqlserver_credentials_secret_arn" {
  description = "Secrets Manager secret ARN for SQL Server credentials"
  value       = var.enable_sqlserver && length(aws_secretsmanager_secret.sqlserver_credentials) > 0 ? aws_secretsmanager_secret.sqlserver_credentials[0].arn : null
}

output "postgresql_identifier" {
  description = "PostgreSQL DB identifier (langgraph)"
  value       = aws_db_instance.postgresql.identifier
}
