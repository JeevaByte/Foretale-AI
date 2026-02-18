################################################################################
# Lambda Module - Outputs
################################################################################

output "calling_sql_procedure_function_arn" {
  description = "ARN of calling_sql_procedure Lambda function"
  value       = aws_lambda_function.calling_sql_procedure.arn
}

output "calling_sql_procedure_function_name" {
  description = "Name of calling_sql_procedure Lambda function"
  value       = aws_lambda_function.calling_sql_procedure.function_name
}

output "calling_sql_procedure_invoke_arn" {
  description = "Invoke ARN of calling_sql_procedure Lambda function"
  value       = aws_lambda_function.calling_sql_procedure.invoke_arn
}

output "ecs_invoker_function_arn" {
  description = "ARN of ECS invoker Lambda function"
  value       = aws_lambda_function.ecs_invoker.arn
}

output "ecs_invoker_function_name" {
  description = "Name of ECS invoker Lambda function"
  value       = aws_lambda_function.ecs_invoker.function_name
}

output "ecs_invoker_invoke_arn" {
  description = "Invoke ARN of ECS invoker Lambda function"
  value       = aws_lambda_function.ecs_invoker.invoke_arn
}

output "get_ecs_status_invoke_arn" {
  description = "Invoke ARN of get-ecs-task-status Lambda alias (uses ecs_invoker function)"
  value       = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.ecs_invoker.arn}:${aws_lambda_alias.get_ecs_status.name}/invocations"
}

output "get_ecs_status_function_name" {
  description = "Function name for get-ecs-task-status Lambda alias"
  value       = aws_lambda_function.ecs_invoker.function_name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for Lambda functions"
  value       = aws_cloudwatch_log_group.lambda.name
}
