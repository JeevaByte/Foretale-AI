variable "organization_root_id" {
  description = "The AWS Organization Root ID (r-xxxx)"
  type        = string
}

variable "organization_id" {
  description = "The AWS Organization ID"
  type        = string
}

variable "client_name" {
  description = "Client name for account creation (default: foretale)"
  type        = string
  default     = "foretale"
}

variable "client_dev_email" {
  description = "Email for DEV account (must be valid)"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.client_dev_email))
    error_message = "Invalid email format for DEV account."
  }
}

variable "client_uat_email" {
  description = "Email for UAT account (must be valid)"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.client_uat_email))
    error_message = "Invalid email format for UAT account."
  }
}

variable "client_prod_email" {
  description = "Email for PROD account (must be valid)"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.client_prod_email))
    error_message = "Invalid email format for PROD account."
  }
}

variable "cidr_block" {
  description = "VPC CIDR block for account"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "azs" {
  description = "Availability zones for deployment"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "environment" {
  description = "Environment name (dev/uat/prod)"
  type        = string
  default     = "dev"
}

variable "cost_center" {
  description = "Cost center for billing and allocation"
  type        = string
  default     = "engineering"
}

variable "sustainability" {
  description = "Sustainability tagging"
  type        = string
  default     = "enabled"
}

variable "security_admin_account_id" {
  description = "Delegated admin account ID for Security OU"
  type        = string
}

variable "config_role_arn" {
  description = "Role ARN for AWS Config recorder"
  type        = string
}

variable "scp_validation_lambda_zip_path" {
  description = "Path to lambda function zip file for account vending validation"
  type        = string
  default     = "account_vending.zip"
}
