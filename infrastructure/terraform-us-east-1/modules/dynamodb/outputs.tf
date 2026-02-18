output "sessions_table_id" {
  description = "ID of the sessions DynamoDB table"
  value       = aws_dynamodb_table.sessions.id
}

output "params_table_id" {
  description = "ID of the parameters DynamoDB table"
  value       = aws_dynamodb_table.params.id
}

output "params_table_arn" {
  description = "ARN of the parameters DynamoDB table"
  value       = aws_dynamodb_table.params.arn
}

output "params_table_stream_arn" {
  description = "Stream ARN of the parameters DynamoDB table"
  value       = aws_dynamodb_table.params.stream_arn
}

output "sessions_table_arn" {
  description = "ARN of the sessions DynamoDB table"
  value       = aws_dynamodb_table.sessions.arn
}

output "cache_table_id" {
  description = "ID of the cache DynamoDB table"
  value       = aws_dynamodb_table.cache.id
}

output "cache_table_arn" {
  description = "ARN of the cache DynamoDB table"
  value       = aws_dynamodb_table.cache.arn
}

output "ai_state_table_id" {
  description = "ID of the AI state DynamoDB table"
  value       = aws_dynamodb_table.ai_state.id
}

output "ai_state_table_arn" {
  description = "ARN of the AI state DynamoDB table"
  value       = aws_dynamodb_table.ai_state.arn
}

output "audit_logs_table_id" {
  description = "ID of the audit logs DynamoDB table"
  value       = aws_dynamodb_table.audit_logs.id
}

output "audit_logs_table_arn" {
  description = "ARN of the audit logs DynamoDB table"
  value       = aws_dynamodb_table.audit_logs.arn
}

output "websocket_connections_table_id" {
  description = "ID of the WebSocket connections DynamoDB table"
  value       = aws_dynamodb_table.websocket_connections.id
}

output "websocket_connections_table_arn" {
  description = "ARN of the WebSocket connections DynamoDB table"
  value       = aws_dynamodb_table.websocket_connections.arn
}

output "all_table_arns" {
  description = "List of all DynamoDB table ARNs"
  value = [
    aws_dynamodb_table.params.arn,
    aws_dynamodb_table.sessions.arn,
    aws_dynamodb_table.cache.arn,
    aws_dynamodb_table.ai_state.arn,
    aws_dynamodb_table.audit_logs.arn,
    aws_dynamodb_table.websocket_connections.arn,
  ]
}

output "all_table_names" {
  description = "List of all DynamoDB table names"
  value = [
    aws_dynamodb_table.params.name,
    aws_dynamodb_table.sessions.name,
    aws_dynamodb_table.cache.name,
    aws_dynamodb_table.ai_state.name,
    aws_dynamodb_table.audit_logs.name,
    aws_dynamodb_table.websocket_connections.name,
  ]
}

output "replica_table_name" {
  description = "DynamoDB replica table name"
  value       = var.enable_table_replication ? aws_dynamodb_table.foretale_table_replica[0].name : null
}

output "replica_table_arn" {
  description = "DynamoDB replica table ARN"
  value       = var.enable_table_replication ? aws_dynamodb_table.foretale_table_replica[0].arn : null
}

output "replica_stream_arn" {
  description = "DynamoDB replica table stream ARN"
  value       = var.enable_table_replication ? aws_dynamodb_table.foretale_table_replica[0].stream_arn : null
}
