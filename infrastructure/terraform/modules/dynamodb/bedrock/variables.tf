variable "environment" {
  description = "Environment tag (DEV/UAT/PROD)"
  type        = string
}

variable "bedrock_role_arn" {
  description = "ARN of the Bedrock IAM role"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for Bedrock encryption"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Bedrock service"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Bedrock service"
  type        = list(string)
}