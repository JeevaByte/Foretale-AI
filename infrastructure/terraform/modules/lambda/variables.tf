################################################################################
# Lambda Module - Input Variables
################################################################################

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Lambda Execution Role
################################################################################

variable "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

################################################################################
# VPC Configuration
################################################################################

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda functions"
  type        = list(string)
}

################################################################################
# RDS Configuration
################################################################################

variable "rds_endpoint" {
  description = "RDS database endpoint (host)"
  type        = string
}

variable "rds_port" {
  description = "RDS database port"
  type        = number
  default     = 5432
}

variable "rds_database" {
  description = "RDS database name"
  type        = string
}

variable "rds_username" {
  description = "RDS database username"
  type        = string
}

variable "secrets_manager_secret_name" {
  description = "Secrets Manager secret name for database credentials"
  type        = string
}

################################################################################
# ECS Configuration
################################################################################

variable "ecs_cluster_uploads" {
  description = "ECS cluster name for CSV upload processing"
  type        = string
  default     = "cluster-uploads"
}

variable "ecs_cluster_execute" {
  description = "ECS cluster name for test execution"
  type        = string
  default     = "cluster-execute"
}

variable "ecs_task_definition_csv" {
  description = "ECS task definition ARN for CSV upload processing"
  type        = string
}

variable "ecs_task_definition_execute" {
  description = "ECS task definition ARN for test execution"
  type        = string
}

################################################################################
# Lambda Layers
################################################################################

variable "lambda_layer_db_utils_arn" {
  description = "ARN of the layer-db-utils Lambda layer for secret manager credentials"
  type        = string
}

variable "lambda_layer_pyodbc_arn" {
  description = "ARN of the pyodbc-layer-prebuilt Lambda layer for database connectivity"
  type        = string
}
