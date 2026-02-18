# Secrets Manager Module

This module manages AWS Secrets Manager secrets for the Foretale application in us-east-2.

## Secrets Created

1. **dev-url-alb-ecs-services** - ALB ECS Services URL for question answering
2. **dev-pinecone-api** - Pinecone project specific API key
3. **dev-langsmith-api** - LangSmith API key for LLM tracing
4. **dev-redis** - Redis password for caching
5. **dev-sql-credentials** - SQL Server database credentials
6. **dev-postgres-credentials** - PostgreSQL database credentials

## Inputs

- `project_name` - Project name for naming conventions
- `environment` - Environment name
- `tags` - Common tags applied to all resources
- `create_dev_*` - Control flags to create each secret
- Secret values for each service

## Outputs

- `dev_url_alb_ecs_services_secret_arn` - ARN of ALB ECS Services URL secret
- `dev_pinecone_api_secret_arn` - ARN of Pinecone API key secret
- `dev_langsmith_api_secret_arn` - ARN of LangSmith API key secret
- `dev_redis_secret_arn` - ARN of Redis password secret
- `dev_sql_credentials_secret_arn` - ARN of SQL Server credentials secret
- `dev_postgres_credentials_secret_arn` - ARN of PostgreSQL credentials secret
