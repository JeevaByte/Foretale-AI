################################################################################
# EKS Module - Input Variables
################################################################################

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# VPC Configuration
################################################################################

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for control plane (optional)"
  type        = list(string)
  default     = []
}

################################################################################
# EKS Cluster Configuration
################################################################################

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster"
  type        = string
  default     = "1.29"
}

################################################################################
# Worker Node Configuration
################################################################################

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

################################################################################
# RDS Configuration
################################################################################

variable "rds_security_group_id" {
  description = "Security group ID of RDS database"
  type        = string
}

variable "rds_port" {
  description = "RDS database port"
  type        = number
  default     = 5432
}

variable "secrets_manager_secret_arn" {
  description = "ARN of Secrets Manager secret for database credentials"
  type        = string
}
