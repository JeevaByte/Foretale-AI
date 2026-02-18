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

variable "lambda_invoke_arn_ecs_invoker" {
  description = "Lambda invoke ARN for ECS invoker function"
  type        = string
}

variable "lambda_function_name_ecs_invoker" {
  description = "Lambda function name for ECS invoker"
  type        = string
}

variable "lambda_invoke_arn_get_ecs_status" {
  description = "Lambda invoke ARN for get_ecs_status function"
  type        = string
}

variable "lambda_function_name_get_ecs_status" {
  description = "Lambda function name for get_ecs_status"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
