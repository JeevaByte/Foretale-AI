# AWS Multi-Region Migration: us-east-1 → us-east-2

Complete automation toolkit for migrating AWS services from us-east-1 to us-east-2.

## 📊 Current Status

**Migration Progress: 86% Complete (18/21 resources)**

### ✅ Completed
- Amazon ECR: 9/9 repositories
- AWS Lambda: 8/8 functions  
- Amazon SQS: 1/1 queue

### ⏳ Pending
- Amazon API Gateway: 2 APIs (exported, ready to import)
- AWS Amplify: 1 app (manual recreation required)

---

## 🚀 Quick Start

### Option 1: Run Everything
```powershell
.\master_migration.ps1 -All
```

### Option 2: Step by Step
```powershell
# 1. Audit current state
.\master_migration.ps1 -Audit

# 2. Create ECR repositories
.\master_migration.ps1 -CreateECR

# 3. Deploy Lambda functions
.\master_migration.ps1 -DeployLambda

# 4. Export API Gateways
.\master_migration.ps1 -ExportAPI

# 5. Import API Gateways
.\master_migration.ps1 -ImportAPI

# 6. View summary
.\master_migration.ps1 -Summary
```

---

## 📁 Repository Structure

```
deployment/
├── master_migration.ps1           # Main orchestration script
├── MIGRATION_SUMMARY.md           # Detailed migration report
├── QUICK_REFERENCE.md             # Quick reference guide
│
├── scripts/
│   ├── audit_aws_regions.ps1      # Compare services across regions
│   ├── create_ecr_repos.ps1       # Create ECR repositories
│   ├── deploy_lambdas_final.ps1   # Deploy Lambda functions
│   ├── export_api_gateways.ps1    # Export API configurations
│   ├── import_api_gateways.ps1    # Import APIs to us-east-2
│   ├── lambda-trust-policy.json   # IAM trust policy
│   │
│   ├── lambda_exports/            # Lambda function packages
│   │   ├── *.zip                  # Function code
│   │   └── *_config.json          # Function configurations
│   │
│   └── api_gateway_exports/       # API Gateway definitions
│       ├── *_oas30.json           # OpenAPI 3.0 definitions
│       ├── *_resources.json       # API resources
│       └── *_stages.json          # Stage configurations
```

---

## 🔧 Individual Scripts

### 1. Audit Script
Compares services between us-east-1 and us-east-2

```powershell
.\scripts\audit_aws_regions.ps1
```

**Output:**
- Console comparison table
- `scripts/aws_region_comparison.json` - Detailed JSON report

### 2. ECR Creation Script
Creates all 9 ECR repositories in us-east-2

```powershell
.\scripts\create_ecr_repos.ps1
```

**Created Repositories:**
- servers/redis, servers/redis/sync
- servers/mcp
- servers/embedding, servers/embedding/sync
- servers/deepai
- invoke/bg/job, invoke/db/process
- uploads/ecr-csv-upload

### 3. Lambda Deployment Script
Deploys all 8 Lambda functions to us-east-2

```powershell
.\scripts\deploy_lambdas_final.ps1
```

**Deployed Functions:**
- sql-server-data-upload
- ecs-task-invoker
- calling-sql-procedure
- amplify-login-* (4 authentication functions)
- amplify-foretaleapplicati-UpdateRolesWithIDPFuncti-huPwKhw8QOI3

**Created IAM Role:**
- Name: `LambdaExecRole-USEast2`
- ARN: `arn:aws:iam::442426872653:role/LambdaExecRole-USEast2`

### 4. API Gateway Export Script
Exports API definitions from us-east-1

```powershell
.\scripts\export_api_gateways.ps1
```

**Exported APIs:**
- api-ecs-task-invoker
- api-sql-procedure-invoker

### 5. API Gateway Import Script
Imports and configures APIs in us-east-2

```powershell
.\scripts\import_api_gateways.ps1
```

**Features:**
- Imports API definitions
- Updates Lambda integrations
- Adds Lambda permissions
- Creates deployments
- Returns endpoint URLs

---

## 📋 Detailed Migration Guide

### Phase 1: Infrastructure (✅ Complete)

#### ECR Repositories
All repositories created. To copy images:

```powershell
# Set variables
$repo = "servers/redis"
$sourceReg = "442426872653.dkr.ecr.us-east-1.amazonaws.com"
$targetReg = "442426872653.dkr.ecr.us-east-2.amazonaws.com"

# Authenticate
aws ecr get-login-password --region us-east-1 | `
  docker login --username AWS --password-stdin $sourceReg

# Pull, tag, push
docker pull "${sourceReg}/${repo}:latest"
docker tag "${sourceReg}/${repo}:latest" "${targetReg}/${repo}:latest"

aws ecr get-login-password --region us-east-2 | `
  docker login --username AWS --password-stdin $targetReg

docker push "${targetReg}/${repo}:latest"
```

#### Lambda Functions
All 8 functions deployed. Configuration steps:

```powershell
# View function
aws lambda get-function --function-name FUNCTION_NAME --region us-east-2

# Test function
aws lambda invoke --function-name FUNCTION_NAME out.json --region us-east-2

# Update environment variables (if needed)
aws lambda update-function-configuration `
  --function-name FUNCTION_NAME `
  --environment Variables="{KEY1=VALUE1,KEY2=VALUE2}" `
  --region us-east-2
```

#### SQS Queue
Queue created: `https://sqs.us-east-2.amazonaws.com/442426872653/sqs-controls-execution`

Verify attributes match source:
```powershell
# Get source attributes
aws sqs get-queue-attributes `
  --queue-url https://sqs.us-east-1.amazonaws.com/442426872653/sqs-controls-execution `
  --attribute-names All `
  --region us-east-1

# Get target attributes
aws sqs get-queue-attributes `
  --queue-url https://sqs.us-east-2.amazonaws.com/442426872653/sqs-controls-execution `
  --attribute-names All `
  --region us-east-2
```

### Phase 2: API Layer (⏳ In Progress)

#### API Gateway
Run import script:
```powershell
.\scripts\import_api_gateways.ps1
```

Manual verification:
1. Open AWS Console → API Gateway in us-east-2
2. Verify both APIs are created
3. Test each endpoint
4. Check CloudWatch logs

### Phase 3: Application Layer (⏳ Pending)

#### Amplify App
Manual steps:
1. Navigate to AWS Amplify Console in us-east-2
2. Click "New app" → "Host web app"
3. Connect to your Git repository
4. Configure build settings (same as us-east-1)
5. Add backend resources:
   - Update API endpoints to us-east-2
   - Configure Cognito (if not already in us-east-2)
   - Update environment variables
6. Deploy

---

## ✅ Verification & Testing

### 1. Infrastructure Verification
```powershell
# Run audit again
.\scripts\audit_aws_regions.ps1

# Should show "Both regions" for:
# - ECR (9 repos)
# - Lambda (8 functions)
# - SQS (1 queue)
# - API Gateway (2 APIs)
```

### 2. Lambda Function Testing
```powershell
# Test each function
$functions = @(
    "sql-server-data-upload",
    "ecs-task-invoker",
    "calling-sql-procedure"
)

foreach ($func in $functions) {
    Write-Host "Testing $func..."
    aws lambda invoke --function-name $func response.json --region us-east-2
    Get-Content response.json
}
```

### 3. API Gateway Testing
```powershell
# Get API endpoints
aws apigateway get-rest-apis --region us-east-2

# Test endpoint (replace with actual URL)
Invoke-WebRequest -Uri "https://API_ID.execute-api.us-east-2.amazonaws.com/prod/PATH"
```

### 4. SQS Testing
```powershell
# Send test message
aws sqs send-message `
  --queue-url "https://sqs.us-east-2.amazonaws.com/442426872653/sqs-controls-execution" `
  --message-body "Test message" `
  --region us-east-2

# Receive message
aws sqs receive-message `
  --queue-url "https://sqs.us-east-2.amazonaws.com/442426872653/sqs-controls-execution" `
  --region us-east-2
```

---

## 📊 Resource Inventory

### Lambda Functions (us-east-2)
| Function | Runtime | Timeout | Memory |
|----------|---------|---------|--------|
| sql-server-data-upload | python3.12 | 900s | 128 MB |
| ecs-task-invoker | python3.12 | 3s | 128 MB |
| calling-sql-procedure | python3.12 | 300s | 128 MB |
| amplify-login-custom-message-de15b5e1 | nodejs20.x | 15s | 256 MB |
| amplify-login-verify-auth-challenge-de15b5e1 | nodejs20.x | 15s | 256 MB |
| amplify-login-create-auth-challenge-de15b5e1 | nodejs20.x | 15s | 256 MB |
| amplify-login-define-auth-challenge-de15b5e1 | nodejs20.x | 15s | 256 MB |
| amplify-foretaleapplicati-UpdateRolesWithIDPFuncti-huPwKhw8QOI3 | nodejs22.x | 300s | 128 MB |

### ECR Repositories (us-east-2)
All 9 repositories created:
- `442426872653.dkr.ecr.us-east-2.amazonaws.com/REPO_NAME`

---

## 🆘 Troubleshooting

### Common Issues

#### 1. IAM Permission Errors
```powershell
# Check current identity
aws sts get-caller-identity

# Verify permissions for specific service
aws iam simulate-principal-policy `
  --policy-source-arn USER_ARN `
  --action-names lambda:CreateFunction ecr:CreateRepository
```

#### 2. Lambda Deployment Failures
- Check IAM role exists: `LambdaExecRole-USEast2`
- Verify VPC configuration if function requires it
- Check function package size limits

#### 3. API Gateway Import Issues
- Verify Lambda permissions are added
- Check integration URIs point to us-east-2
- Ensure proper stage deployment

#### 4. ECR Access Issues
```powershell
# Re-authenticate
aws ecr get-login-password --region us-east-2 | `
  docker login --username AWS --password-stdin 442426872653.dkr.ecr.us-east-2.amazonaws.com
```

---

## 💰 Cost Considerations

### Ongoing Costs (us-east-2)
- **Lambda**: Pay per invocation + duration
- **ECR**: Storage costs for Docker images
- **API Gateway**: Per request + data transfer
- **SQS**: Per request (first 1M free/month)

### Optimization Tips
- Delete unused resources in us-east-1 after validation
- Set up CloudWatch alarms for cost monitoring
- Use Reserved Capacity for predictable workloads
- Enable S3 lifecycle policies for logs

---

## 📞 Support & Resources

### Documentation
- [MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md) - Detailed status report
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Commands and ARNs
- `scripts/aws_region_comparison.json` - Audit results

### AWS Console Links (us-east-2)
- [Lambda Console](https://us-east-2.console.aws.amazon.com/lambda/)
- [API Gateway Console](https://us-east-2.console.aws.amazon.com/apigateway/)
- [ECR Console](https://us-east-2.console.aws.amazon.com/ecr/)
- [SQS Console](https://us-east-2.console.aws.amazon.com/sqs/)
- [Amplify Console](https://us-east-2.console.aws.amazon.com/amplify/)

### Script Logs
All scripts output results to:
- `scripts/migration_results.json`
- `scripts/lambda_exports/final_deployment_results.json`
- `scripts/api_gateway_exports/import_results.json`

---

## 🔄 Rollback Plan

If issues occur in us-east-2:
1. Application can continue using us-east-1 resources
2. Delete created resources in us-east-2 to stop charges
3. Review logs and fix issues before retry

```powershell
# Delete Lambda functions
aws lambda delete-function --function-name FUNCTION_NAME --region us-east-2

# Delete ECR repositories
aws ecr delete-repository --repository-name REPO_NAME --region us-east-2 --force

# Delete API Gateways
aws apigateway delete-rest-api --rest-api-id API_ID --region us-east-2

# Delete SQS queue
aws sqs delete-queue --queue-url QUEUE_URL --region us-east-2
```

---

## ✨ Next Steps

1. **Complete API Gateway import** - Run `.\scripts\import_api_gateways.ps1`
2. **Create Amplify app** - Manual setup in console
3. **Copy Docker images** - Transfer images to us-east-2 ECR
4. **Update application config** - Point to us-east-2 resources
5. **End-to-end testing** - Verify complete application flow
6. **Monitor and optimize** - Set up CloudWatch dashboards

---

**Last Updated:** 2026-01-28
**Status:** 86% Complete
**AWS Account:** 442426872653
