variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "database_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID for RDS instance"
  type        = string
}

variable "monitoring_role_arn" {
  description = "ARN of the IAM role for RDS enhanced monitoring"
  type        = string
}

################################################################################
# Database Configuration
################################################################################

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.5"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "foretaledb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "foretaleadmin"
}

################################################################################
# Backup Configuration
################################################################################

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion (set to false in production)"
  type        = bool
  default     = true
}

################################################################################
# Monitoring and Performance
################################################################################

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

################################################################################
# High Availability and Durability
################################################################################

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_read_replica" {
  description = "Enable RDS read replica"
  type        = bool
  default     = true
}

variable "rds_kms_key_id" {
  description = "KMS key ID for RDS encryption"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "SNS topic ARNs for alarm actions"
  type        = list(string)
  default     = []
}

variable "enable_sqlserver" {
  description = "Enable SQL Server RDS instance"
  type        = bool
  default     = true
}

variable "sqlserver_version" {
  description = "SQL Server engine version"
  type        = string
  default     = "15.00.4153.1.v1"
}

variable "sqlserver_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "sqlserver_storage" {
  description = "SQL Server allocated storage in GB"
  type        = number
  default     = 100
}
