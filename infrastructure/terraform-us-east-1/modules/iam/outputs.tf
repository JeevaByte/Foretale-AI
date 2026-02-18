output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Name of ECS task role"
  value       = aws_iam_role.ecs_task.name
}

output "lambda_execution_role_arn" {
  description = "ARN of Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Name of Lambda execution role"
  value       = aws_iam_role.lambda_execution.name
}

output "api_gateway_cloudwatch_role_arn" {
  description = "ARN of API Gateway CloudWatch role"
  value       = aws_iam_role.api_gateway_cloudwatch.arn
}

output "amplify_service_role_arn" {
  description = "ARN of Amplify service role"
  value       = aws_iam_role.amplify_service.arn
}

output "ai_server_role_arn" {
  description = "ARN of AI server EC2 role"
  value       = aws_iam_role.ai_server.arn
}

output "ai_server_instance_profile_name" {
  description = "Name of AI server instance profile"
  value       = aws_iam_instance_profile.ai_server.name
}

output "rds_monitoring_role_arn" {
  description = "ARN of RDS monitoring role"
  value       = aws_iam_role.rds_monitoring.arn
}
