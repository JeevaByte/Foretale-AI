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

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS on user uploads bucket"
  type        = list(string)
  default     = ["*"] # Should be restricted in production
}

