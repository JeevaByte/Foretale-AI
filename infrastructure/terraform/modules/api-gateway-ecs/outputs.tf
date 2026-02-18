output "api_gateway_id" {
  description = "ECS API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.ecs.id
}

output "api_gateway_root_resource_id" {
  description = "ECS API Gateway root resource ID"
  value       = aws_api_gateway_rest_api.ecs.root_resource_id
}

output "api_gateway_invoke_url" {
  description = "ECS API Gateway invoke URL"
  value       = aws_api_gateway_stage.ecs.invoke_url
}

output "api_gateway_execution_arn" {
  description = "ECS API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.ecs.execution_arn
}

output "api_gateway_stage_arn" {
  description = "ECS API Gateway stage ARN"
  value       = aws_api_gateway_stage.ecs.arn
}

output "authorizer_id" {
  description = "Cognito authorizer ID"
  value       = aws_api_gateway_authorizer.cognito.id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway_ecs.name
}
