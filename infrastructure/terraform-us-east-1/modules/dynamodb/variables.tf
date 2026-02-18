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

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "read_capacity" {
  description = "Read capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only used when billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB tables"
  type        = bool
  default     = true
}

variable "foretale_global_table_arn" {
  description = "Global DynamoDB table ARN from us-east-1"
  type        = string
  default     = ""
}

variable "dynamodb_kms_key_arn" {
  description = "KMS key ARN for DynamoDB encryption"
  type        = string
  default     = ""
}

variable "enable_table_replication" {
  description = "Enable DynamoDB table replication from us-east-1"
  type        = bool
  default     = true
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams for change data capture"
  type        = bool
  default     = true
}
