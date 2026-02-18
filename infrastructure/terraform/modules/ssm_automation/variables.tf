variable "environment" {
  description = "Environment tag (DEV/UAT/PROD)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for automation"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs for automation"
  type        = list(string)
  default     = []
}

variable "maintenance_window_schedule" {
  description = "Cron expression for maintenance window"
  type        = string
  default     = "cron(0 0 ? * SUN *)"
}