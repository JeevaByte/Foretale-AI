output "api_gateway_id" {
  description = "SQL API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.sql.id
}

output "api_gateway_root_resource_id" {
  description = "SQL API Gateway root resource ID"
  value       = aws_api_gateway_rest_api.sql.root_resource_id
}

output "api_gateway_invoke_url" {
  description = "SQL API Gateway invoke URL"
  value       = aws_api_gateway_stage.sql.invoke_url
}

output "api_gateway_execution_arn" {
  description = "SQL API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.sql.execution_arn
}

output "api_gateway_stage_arn" {
  description = "SQL API Gateway stage ARN"
  value       = aws_api_gateway_stage.sql.arn
}

output "authorizer_id" {
  description = "Cognito authorizer ID"
  value       = aws_api_gateway_authorizer.cognito.id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway_sql.name
}
