################################################################################
# Secrets Manager Module Variables
################################################################################

variable "project_name" {
  description = "Project name for naming conventions"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

################################################################################
# Control Flags
################################################################################

variable "create_dev_url_alb_ecs_services" {
  description = "Create ALB ECS Services URL secret"
  type        = bool
  default     = true
}

variable "create_dev_pinecone_api" {
  description = "Create Pinecone API key secret"
  type        = bool
  default     = true
}

variable "create_dev_langsmith_api" {
  description = "Create LangSmith API key secret"
  type        = bool
  default     = true
}

variable "create_dev_redis" {
  description = "Create Redis password secret"
  type        = bool
  default     = true
}

variable "create_dev_sql_credentials" {
  description = "Create SQL Server credentials secret"
  type        = bool
  default     = true
}

variable "create_dev_postgres_credentials" {
  description = "Create PostgreSQL credentials secret"
  type        = bool
  default     = true
}

################################################################################
# Secret Values
################################################################################

variable "dev_url_alb_ecs_services" {
  description = "ALB ECS Services URL"
  type        = string
  sensitive   = true
}

variable "dev_pinecone_api" {
  description = "Pinecone API key"
  type        = string
  sensitive   = true
}

variable "dev_langsmith_api" {
  description = "LangSmith API key"
  type        = string
  sensitive   = true
}

variable "dev_redis" {
  description = "Redis password"
  type        = string
  sensitive   = true
}

variable "dev_sql_username" {
  description = "SQL Server username"
  type        = string
  sensitive   = true
}

variable "dev_sql_password" {
  description = "SQL Server password"
  type        = string
  sensitive   = true
}

variable "dev_sql_host" {
  description = "SQL Server host endpoint"
  type        = string
}

variable "dev_sql_port" {
  description = "SQL Server port"
  type        = number
  default     = 1433
}

variable "dev_sql_dbname" {
  description = "SQL Server database instance name"
  type        = string
}

variable "dev_postgres_username" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
}

variable "dev_postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "dev_postgres_host" {
  description = "PostgreSQL host endpoint"
  type        = string
}

variable "dev_postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "dev_postgres_dbname" {
  description = "PostgreSQL database name"
  type        = string
}
