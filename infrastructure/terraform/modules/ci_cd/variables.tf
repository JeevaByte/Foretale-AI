variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for CodeBuild"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for CodeBuild"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for deployment"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name for deployment"
  type        = string
}

variable "notification_email" {
  description = "Email address for pipeline notifications"
  type        = string
}

variable "branch_name" {
  description = "Git branch name to trigger pipeline"
  type        = string
  default     = "main"
}
