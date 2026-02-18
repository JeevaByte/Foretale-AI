################################################################################
# Secrets Manager Module Outputs
################################################################################

output "dev_url_alb_ecs_services_secret_arn" {
  description = "ARN of ALB ECS Services URL secret"
  value       = try(aws_secretsmanager_secret.dev_url_alb_ecs_services[0].arn, "")
}

output "dev_pinecone_api_secret_arn" {
  description = "ARN of Pinecone API key secret"
  value       = try(aws_secretsmanager_secret.dev_pinecone_api[0].arn, "")
}

output "dev_langsmith_api_secret_arn" {
  description = "ARN of LangSmith API key secret"
  value       = try(aws_secretsmanager_secret.dev_langsmith_api[0].arn, "")
}

output "dev_redis_secret_arn" {
  description = "ARN of Redis password secret"
  value       = try(aws_secretsmanager_secret.dev_redis[0].arn, "")
}

output "dev_sql_credentials_secret_arn" {
  description = "ARN of SQL Server credentials secret"
  value       = try(aws_secretsmanager_secret.dev_sql_credentials[0].arn, "")
}

output "dev_postgres_credentials_secret_arn" {
  description = "ARN of PostgreSQL credentials secret"
  value       = try(aws_secretsmanager_secret.dev_postgres_credentials[0].arn, "")
}
