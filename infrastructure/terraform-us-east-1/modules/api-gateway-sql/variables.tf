variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "Cognito user pool ARN for API Gateway authorizer"
  type        = string
}

variable "lambda_invoke_arn_calling_sql_procedure" {
  description = "Lambda invoke ARN for calling_sql_procedure function"
  type        = string
}

variable "lambda_function_name_calling_sql_procedure" {
  description = "Lambda function name for calling_sql_procedure"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
