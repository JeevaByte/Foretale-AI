################################################################################
# Global Variables
################################################################################

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "foretale"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# VPC Variables
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (for ECS, Lambda)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost optimization for dev)"
  type        = bool
  default     = true
}

################################################################################
# IAM Variables (for Phase 2+ resources)
################################################################################

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for IAM policies (Phase 2)"
  type        = list(string)
  default     = []
}

variable "rds_cluster_arn" {
  description = "RDS cluster ARN for IAM policies (Phase 2)"
  type        = string
  default     = ""
}

################################################################################
# Phase 2: S3 Configuration
################################################################################

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS on user uploads bucket"
  type        = list(string)
  default     = ["*"]
}

################################################################################
# Phase 2: RDS Configuration
################################################################################

variable "rds_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.5"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "rds_db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "foretaledb"
}

variable "rds_db_username" {
  description = "Master username for the database"
  type        = string
  default     = "foretaleadmin"
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on deletion (set to false in production)"
  type        = bool
  default     = true
}

variable "rds_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "rds_enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "rds_auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

################################################################################
# Phase 2: DynamoDB Configuration
################################################################################

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  description = "Read capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Write capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_enable_pitr" {
  description = "Enable point-in-time recovery for DynamoDB tables"
  type        = bool
  default     = true
}

################################################################################
# Phase 1b: Cognito Configuration
################################################################################

variable "enable_cognito_mfa" {
  description = "Enable multi-factor authentication for Cognito User Pool"
  type        = bool
  default     = false
}

################################################################################
# Phase 3: API Gateway, Lambda, and EKS Configuration
################################################################################

variable "cognito_user_pool_arn" {
  description = "ARN of Cognito User Pool for API Gateway authorization"
  type        = string
  default     = ""
}

################################################################################
# Lambda Layers Configuration
################################################################################

variable "lambda_layer_db_utils_arn" {
  description = "ARN of the layer-db-utils Lambda layer for secret manager credentials (us-east-2)"
  type        = string
  default     = "arn:aws:lambda:us-east-2:442426872653:layer:layer-db-utils:1"
}

variable "lambda_layer_pyodbc_arn" {
  description = "ARN of the pyodbc-layer-prebuilt Lambda layer for database connectivity (us-east-2)"
  type        = string
  default     = "arn:aws:lambda:us-east-2:442426872653:layer:pyodbc-layer-prebuilt:3"
}

################################################################################
# EKS Configuration
################################################################################

variable "eks_kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "eks_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_size" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 4
}

################################################################################
# KAN-9: ALB and Auto Scaling Variables
################################################################################

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener (optional)"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID for EC2 instances in Auto Scaling Group"
  type        = string
  default     = "ami-00c97a6757d24bd8b"  # ARM64 ALLinux 2023 in us-east-1
}

variable "asg_instance_type" {
  description = "EC2 instance type for ASG"
  type        = string
  default     = "t4g.medium"
}

variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 10
}

variable "asg_desired_size" {
  description = "Desired capacity of Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_ebs_volume_size" {
  description = "EBS volume size for ASG instances (GB)"
  type        = number
  default     = 50
}

variable "cpu_target_utilization" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "alb_request_target" {
  description = "Target ALB request count per instance for auto scaling"
  type        = number
  default     = 1000
}

