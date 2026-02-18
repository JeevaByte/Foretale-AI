################################################################################
# DynamoDB Tables for ForeTale Application
################################################################################

locals {
  table_prefix = "foretale-app-dynamodb"
}

################################################################################
# Parameters Table
# Stores application configuration parameters and settings
# Created to manage both us-east-2 and ap-south-1 regions
################################################################################

resource "aws_dynamodb_table" "params" {
  name           = "foretale-app-dynamodb-params"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "paramType"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "N"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  # Global Secondary Index for querying by parameter type
  global_secondary_index {
    name            = "ParamTypeIndex"
    hash_key        = "paramType"
    range_key       = "createdAt"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  # Enable point-in-time recovery for data protection
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Enable server-side encryption with KMS
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.dynamodb_kms_key_arn != "" ? var.dynamodb_kms_key_arn : null
  }

  # Enable DynamoDB Streams for change data capture
  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? "NEW_AND_OLD_IMAGES" : null

  tags = merge(
    var.tags,
    {
      Name        = "foretale-app-dynamodb-params"
      Purpose     = "Application parameters and configuration"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

################################################################################
# Sessions Table
################################################################################

resource "aws_dynamodb_table" "sessions" {
  name           = "foretale-app-dynamodb-sessions"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "sessionId"
  range_key      = "userId"

  attribute {
    name = "sessionId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "N"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    range_key       = "createdAt"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name    = "${local.table_prefix}-sessions"
      Purpose = "User session management"
    }
  )
}

################################################################################
# Cache Table
################################################################################

resource "aws_dynamodb_table" "cache" {
  name           = "${local.table_prefix}-cache"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "cacheKey"

  attribute {
    name = "cacheKey"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name    = "${local.table_prefix}-cache"
      Purpose = "Application caching layer"
    }
  )
}

################################################################################
# AI Assistant State Table
################################################################################

resource "aws_dynamodb_table" "ai_state" {
  name           = "${local.table_prefix}-ai-state"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "conversationId"
  range_key      = "timestamp"

  attribute {
    name = "conversationId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserConversationsIndex"
    hash_key        = "userId"
    range_key       = "timestamp"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name    = "${local.table_prefix}-ai-state"
      Purpose = "AI assistant conversation state"
    }
  )
}

################################################################################
# Audit Logs Table
################################################################################

resource "aws_dynamodb_table" "audit_logs" {
  name           = "${local.table_prefix}-audit-logs"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "eventId"
  range_key      = "timestamp"

  attribute {
    name = "eventId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "eventType"
    type = "S"
  }

  global_secondary_index {
    name            = "UserEventsIndex"
    hash_key        = "userId"
    range_key       = "timestamp"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  global_secondary_index {
    name            = "EventTypeIndex"
    hash_key        = "eventType"
    range_key       = "timestamp"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name    = "${local.table_prefix}-audit-logs"
      Purpose = "Application audit logging"
    }
  )
}

################################################################################
# WebSocket Connections Table
################################################################################

resource "aws_dynamodb_table" "websocket_connections" {
  name           = "${local.table_prefix}-websocket-connections"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserConnectionsIndex"
    hash_key        = "userId"
    projection_type = "ALL"
    read_capacity   = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
    write_capacity  = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name    = "${local.table_prefix}-websocket-connections"
      Purpose = "WebSocket connection management"
    }
  )
}

################################################################################
# DynamoDB Global Table - us-east-2 Replica
# Replicates table parameters from us-east-1
################################################################################

resource "aws_dynamodb_table" "foretale_table_replica" {
  count = var.enable_table_replication ? 1 : 0

  name         = "${local.table_prefix}-foretale-table-replica"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "timestamp"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "user_id-timestamp-index"
    hash_key        = "user_id"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.dynamodb_kms_key_arn != "" ? var.dynamodb_kms_key_arn : null
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = merge(
    var.tags,
    {
      Name        = "${local.table_prefix}-foretale-table-replica"
      Environment = var.environment
      Source      = "us-east-1"
    }
  )
}

################################################################################
# DynamoDB Table Replication Configuration
################################################################################

resource "aws_dynamodb_table_replica" "foretale_table_replica" {
  count = var.enable_table_replication && var.foretale_global_table_arn != "" ? 1 : 0

  global_table_arn = var.foretale_global_table_arn
  kms_key_arn      = var.dynamodb_kms_key_arn != "" ? var.dynamodb_kms_key_arn : null

  tags = merge(
    var.tags,
    {
      Name = "${local.table_prefix}-foretale-replica"
    }
  )
}
