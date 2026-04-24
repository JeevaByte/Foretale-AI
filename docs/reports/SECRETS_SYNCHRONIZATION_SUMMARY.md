# Secrets Manager Synchronization Summary

## Objective
Create 6 missing secrets in us-east-2 Secrets Manager by comparing with ap-south-1 and us-east-1.

## Secrets Status by Region

### us-east-1 (4 Secrets)
1. ✅ **dev-url-alb-ecs-services** - ALB ECS Services URL
2. ✅ **dev-pinecone-api** - Pinecone API key  
3. ✅ **dev-langsmith-api** - LangSmith API key
4. ✅ **dev-redis** - Redis password

### ap-south-1 (2 Secrets)
1. ✅ **dev-sql-credentials** - SQL Server credentials
2. ✅ **dev-postgres-credentials** - PostgreSQL credentials

### us-east-2 (2 Secrets - Already Deployed by Terraform)
1. ✅ **foretale-dev-db-credentials** - PostgreSQL credentials (created by RDS module)
2. ✅ **foretale-dev-sqlserver-credentials** - SQL Server credentials (created by RDS module)

## Missing Secrets to Create in us-east-2

The following secrets exist in us-east-1 and ap-south-1 but are missing in us-east-2:

1. **dev-url-alb-ecs-services** - From us-east-1
2. **dev-pinecone-api** - From us-east-1
3. **dev-langsmith-api** - From us-east-1
4. **dev-redis** - From us-east-1
5. **dev-sql-credentials** - From ap-south-1
6. **dev-postgres-credentials** - From ap-south-1

## Secret Values Retrieved

### From us-east-1
```
dev-url-alb-ecs-services:
  url-alb-ecs-question-answering-service: "http://your-alb-endpoint-here"

dev-pinecone-api:
  pinecone_project_specific_api_key: "pcsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

dev-langsmith-api:
  LANGSMITH_API_KEY: "lsv2_ptxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

dev-redis:
  REDIS_PASSWORD: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### From ap-south-1
```
dev-sql-credentials:
  username: "admin"
  password: "YOUR_SQL_PASSWORD_HERE"
  engine: "sqlserver"
  host: "your-rds-endpoint.ap-south-1.rds.amazonaws.com"
  port: 1433
  dbInstanceIdentifier: "foretale"

dev-postgres-credentials:
  username: "postgres"
  password: "foreHEX!2025"
  engine: "postgresql"
  host: "langgraph.clqoi2aemq8p.ap-south-1.rds.amazonaws.com"
  port: 5432
  dbname: "langgraph"
```

## Implementation Approach

### Option A: Terraform (Recommended)
- Created `/terraform/modules/secrets/main.tf` with 6 `aws_secretsmanager_secret` resources
- Created `/terraform/modules/secrets/variables.tf` with all secret value variables
- Created `/terraform/modules/secrets/outputs.tf` to export secret ARNs
- Updated root `main.tf` to include secrets module
- Updated root `variables.tf` with secrets module variables
- Created `terraform.tfvars.simple` with all secret values

#### Commands to Apply:
```bash
terraform validate          # ✅ Success
terraform fmt -recursive    # ✅ Success
terraform init -upgrade     # ✅ Success
terraform plan              # 64 resources to add (includes secrets)
terraform apply             # Execute the plan
```

### Option B: AWS CLI (Quick Manual Creation)
Use individual `aws secretsmanager create-secret` commands for each of the 6 secrets.

## Status

- ✅ S3 Replication Removed (3 resources will be destroyed)
- ✅ Secrets Module Created (Terraform)
- 🟡 Secrets Module Applied (Pending terraform apply)
- 🟡 Missing Secrets Created in us-east-2 (Terraform will create them)

## Next Steps

1. Review `terraform plan` output to confirm 6 secrets will be created
2. Run `terraform apply` to create all secrets in us-east-2
3. Verify secrets are created: `aws secretsmanager list-secrets --region us-east-2`
4. Confirm applications in us-east-2 can retrieve these secrets

## Notes

- S3 replication role and policy will be destroyed (no longer needed)
- Database credentials already created by RDS module with different names (foretale-dev-db-credentials, foretale-dev-sqlserver-credentials)
- Consider aliasing or renaming to standardize across regions: dev-* naming convention
- ALB URL points to us-east-1 (may need to update when ALB is in us-east-2)
