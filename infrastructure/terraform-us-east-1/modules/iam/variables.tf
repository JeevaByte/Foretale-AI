variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resource-specific policies"
  type        = string
  default     = "us-east-2"
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for IAM policies"
  type        = list(string)
  default     = []
}

variable "rds_cluster_arn" {
  description = "RDS cluster ARN for IAM policies"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
