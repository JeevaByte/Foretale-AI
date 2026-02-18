################################################################################
# Auto Scaling Module - Variables
################################################################################

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "app_name" {
  description = "Application name for naming convention (e.g., foretale-app)"
  type        = string
  default     = "foretale-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASG"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for scaling policy"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for scaling policy"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "min_size" {
  description = "Minimum ASG size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 10
}

variable "desired_size" {
  description = "Desired ASG capacity"
  type        = number
  default     = 2
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 30
}

variable "cpu_target_utilization" {
  description = "Target CPU utilization for scaling"
  type        = number
  default     = 70
}

variable "alb_request_target" {
  description = "Target ALB request count per instance"
  type        = number
  default     = 1000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
