output "bedrock_model_arn" {
  description = "ARN of the Bedrock provisioned model"
  value       = aws_bedrock_provisioned_model_throughput.main.provisioned_model_arn
}

output "bedrock_guardrail_arn" {
  description = "ARN of the Bedrock guardrail"
  value       = aws_bedrock_guardrail.main.guardrail_arn
}

output "bedrock_logging_role_arn" {
  description = "ARN of the Bedrock logging IAM role"
  value       = aws_iam_role.bedrock_logging.arn
}

output "dashboard_arn" {
  description = "ARN of the Bedrock CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.bedrock.arn
}