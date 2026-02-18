################################################################################
# Secrets Manager Module - API Keys and Credentials
################################################################################

locals {
  name_prefix = "foretale-app"
}

################################################################################
# Dev ALB ECS Services URL
################################################################################

resource "aws_secretsmanager_secret" "dev_url_alb_ecs_services" {
  count = var.create_dev_url_alb_ecs_services ? 1 : 0

  name        = "foretale-app-alb-ecs-url"
  description = "ALB ECS Services URL for question answering"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-alb-ecs-url"
    }
  )
}

resource "aws_secretsmanager_secret_version" "dev_url_alb_ecs_services" {
  count = var.create_dev_url_alb_ecs_services ? 1 : 0

  secret_id = aws_secretsmanager_secret.dev_url_alb_ecs_services[0].id
  secret_string = jsonencode({
    "url-alb-ecs-question-answering-service" = var.dev_url_alb_ecs_services
  })
}

################################################################################
# Pinecone API Key
################################################################################

resource "aws_secretsmanager_secret" "dev_pinecone_api" {
  count = var.create_dev_pinecone_api ? 1 : 0

  name        = "foretale-app-pinecone-api"
  description = "Pinecone project specific API key"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-pinecone-api"
    }
  )
}

resource "aws_secretsmanager_secret_version" "dev_pinecone_api" {
  count = var.create_dev_pinecone_api ? 1 : 0

  secret_id = aws_secretsmanager_secret.dev_pinecone_api[0].id
  secret_string = jsonencode({
    "pinecone_project_specific_api_key" = var.dev_pinecone_api
  })
}

################################################################################
# LangSmith API Key
################################################################################

resource "aws_secretsmanager_secret" "dev_langsmith_api" {
  count = var.create_dev_langsmith_api ? 1 : 0

  name        = "foretale-app-langsmith-api"
  description = "LangSmith API key for LLM tracing"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-langsmith-api"
    }
  )
}

resource "aws_secretsmanager_secret_version" "dev_langsmith_api" {
  count = var.create_dev_langsmith_api ? 1 : 0

  secret_id = aws_secretsmanager_secret.dev_langsmith_api[0].id
  secret_string = jsonencode({
    "LANGSMITH_API_KEY" = var.dev_langsmith_api
  })
}

################################################################################
# Redis Password
################################################################################

resource "aws_secretsmanager_secret" "dev_redis" {
  count = var.create_dev_redis ? 1 : 0

  name        = "foretale-app-redis"
  description = "Redis password for caching"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-redis"
    }
  )
}

resource "aws_secretsmanager_secret_version" "dev_redis" {
  count = var.create_dev_redis ? 1 : 0

  secret_id = aws_secretsmanager_secret.dev_redis[0].id
  secret_string = jsonencode({
    "REDIS_PASSWORD" = var.dev_redis
  })
}

################################################################################
# SQL Server Credentials
################################################################################

resource "aws_secretsmanager_secret" "dev_sql_credentials" {
  count = var.create_dev_sql_credentials ? 1 : 0

  name        = "foretale-app-sql-credentials"
  description = "SQL Server database credentials"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-sql-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "dev_sql_credentials" {
  count = var.create_dev_sql_credentials ? 1 : 0

  secret_id = aws_secretsmanager_secret.dev_sql_credentials[0].id
  secret_string = jsonencode({
    "username" : var.dev_sql_username,
    "password" : var.dev_sql_password,
    "engine" : "sqlserver",
    "host" : var.dev_sql_host,
    "port" : var.dev_sql_port,
    "dbInstanceIdentifier" : var.dev_sql_dbname
  })
}

################################################################################
# PostgreSQL Credentials
################################################################################

resource "aws_secretsmanager_secret" "dev_postgres_credentials" {
  count = var.create_dev_postgres_credentials ? 1 : 0

  name        = "foretale-app-postgres-credentials"
  description = "PostgreSQL database credentials"

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-postgres-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "dev_postgres_credentials" {
  count = var.create_dev_postgres_credentials ? 1 : 0

  secret_id = aws_secretsmanager_secret.dev_postgres_credentials[0].id
  secret_string = jsonencode({
    "username" : var.dev_postgres_username,
    "password" : var.dev_postgres_password,
    "engine" : "postgresql",
    "host" : var.dev_postgres_host,
    "port" : var.dev_postgres_port,
    "dbname" : var.dev_postgres_dbname
  })
}
