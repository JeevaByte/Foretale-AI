################################################################################
# RDS PostgreSQL Database for ForeTale Application
################################################################################

locals {
  name_prefix       = "foretale-app-rds"
  cloudwatch_prefix = "/aws/foretale-app/rds"
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "main" {
  name       = "foretale-app-rds-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-rds-subnet-group"
    }
  )
}

################################################################################
# DB Parameter Group
################################################################################

resource "aws_db_parameter_group" "postgresql" {
  name   = "foretale-app-rds-params-pg"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-rds-params-pg"
    }
  )
}

################################################################################
# Random Password for RDS
################################################################################

resource "random_password" "db_password" {
  length  = 32
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

################################################################################
# Secrets Manager for DB Credentials
################################################################################

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "foretale-app-rds-credentials"
  description = "Database credentials for ForeTale RDS instance"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-rds-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgresql.address
    port     = aws_db_instance.postgresql.port
    dbname   = var.db_name
  })
}

################################################################################
# RDS PostgreSQL Instance
################################################################################

resource "aws_db_instance" "postgresql" {
  identifier = "foretale-app-rds-main"

  # Engine Configuration
  engine         = "postgres"
  engine_version = var.engine_version

  # Instance Configuration
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = 5432

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  # Backup Configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "foretale-app-rds-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Enhanced Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? 7 : null

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.postgresql.name

  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Deletion Protection
  deletion_protection = var.deletion_protection

  # Multi-AZ
  multi_az = var.multi_az

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-rds-main"
    }
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password,
    ]
  }
}

################################################################################
# RDS Read Replica for High Availability and Scaling
################################################################################

resource "aws_db_instance" "read_replica" {
  count = 0  # PostgreSQL primary already exists, skip read replica creation

  identifier              = "foretale-app-rds-read-replica"
  replicate_source_db     = aws_db_instance.postgresql.arn
  instance_class          = var.instance_class
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.rds_security_group_id]
  storage_encrypted       = true
  kms_key_id              = var.rds_kms_key_id != "" ? var.rds_kms_key_id : null
  backup_retention_period = 0
  skip_final_snapshot     = true

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-postgres-read-replica"
      Type = "ReadReplica"
    }
  )

  depends_on = [aws_db_instance.postgresql]
}

################################################################################
# RDS SQL Server Instance - us-east-2 (Upgraded Instance Type)
################################################################################

resource "aws_db_instance" "sqlserver" {
  count = var.enable_sqlserver ? 1 : 0

  identifier        = "${local.name_prefix}-sqlserver"
  engine            = "sqlserver-ex"
  engine_version    = var.sqlserver_version
  instance_class    = "db.t3.large"
  allocated_storage = var.sqlserver_storage
  storage_type      = "gp3"

  # SQL Server Configuration
  username      = var.sqlserver_username
  password      = random_password.sqlserver_password[0].result
  license_model = "license-included"

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = true
  kms_key_id             = var.rds_kms_key_id != "" ? var.rds_kms_key_id : null

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  skip_final_snapshot     = var.skip_final_snapshot

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["error"]
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn

  # Auto upgrades
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Deletion Protection
  deletion_protection = var.deletion_protection

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-sqlserver"
      Type = "SQLServer"
    }
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password,
    ]
  }

  depends_on = [aws_db_subnet_group.main]
}

################################################################################
# Random Password for SQL Server
################################################################################

resource "random_password" "sqlserver_password" {
  count = var.enable_sqlserver ? 1 : 0

  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

################################################################################
# SQL Server Secrets Manager
################################################################################

resource "aws_secretsmanager_secret" "sqlserver_credentials" {
  count = var.enable_sqlserver ? 1 : 0

  name        = "${local.name_prefix}-sqlserver-credentials"
  description = "SQL Server database credentials"

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-sqlserver-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "sqlserver_credentials" {
  count = var.enable_sqlserver ? 1 : 0

  secret_id = aws_secretsmanager_secret.sqlserver_credentials[0].id
  secret_string = jsonencode({
    username = var.sqlserver_username
    password = random_password.sqlserver_password[0].result
    engine   = "sqlserver-ex"
    host     = aws_db_instance.sqlserver[0].address
    port     = aws_db_instance.sqlserver[0].port
  })
}

################################################################################
# CloudWatch Alarms - SQL Server
################################################################################

resource "aws_cloudwatch_metric_alarm" "sqlserver_cpu_high" {
  count = var.enable_sqlserver ? 1 : 0

  alarm_name          = "${local.name_prefix}-sqlserver-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.sqlserver[0].identifier
  }

  alarm_description = "Alert when SQL Server CPU exceeds 80%"
  alarm_actions     = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-sqlserver-cpu-alarm"
    }
  )
}

################################################################################
# CloudWatch Alarms - RDS CPU Utilization
################################################################################

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.identifier
  }

  alarm_description = "Alert when RDS CPU exceeds 70%"
  alarm_actions     = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-rds-cpu-alarm"
    }
  )
}

################################################################################
# CloudWatch Alarms - RDS Database Connections
################################################################################

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${local.name_prefix}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.identifier
  }

  alarm_description = "Alert when RDS connections exceed 80"
  alarm_actions     = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-rds-connections-alarm"
    }
  )
}

################################################################################
# CloudWatch Alarms - RDS Storage Space
################################################################################

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${local.name_prefix}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2147483648"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.identifier
  }

  alarm_description = "Alert when RDS free storage is below 2GB"
  alarm_actions     = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-rds-storage-alarm"
    }
  )
}

################################################################################
# CloudWatch Dashboard - RDS Monitoring
################################################################################

resource "aws_cloudwatch_dashboard" "rds" {
  dashboard_name = "${local.name_prefix}-rds-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.postgresql.identifier]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "RDS CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.postgresql.identifier]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "RDS Database Connections"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.postgresql.identifier]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "RDS Free Storage Space"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.postgresql.identifier]
          ]
          view   = "singleValue"
          region = data.aws_region.current.name
          title  = "Current Database Connections"
        }
      }
    ]
  })
}

################################################################################
# Data Source - Current AWS Region
################################################################################

data "aws_region" "current" {}
