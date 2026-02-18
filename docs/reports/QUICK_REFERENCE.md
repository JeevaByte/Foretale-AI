# AWS Multi-Region Migration - Quick Reference Guide

## 🎯 Migration Status: 86% Complete

### ✅ Completed (18 of 21 resources)
- **9 ECR Repositories** - All created
- **8 Lambda Functions** - All deployed
- **1 SQS Queue** - Created and configured

### ⏳ Remaining (3 resources)
- **2 API Gateways** - Exported, awaiting import
- **1 Amplify App** - Manual recreation required

---

## 🚀 Quick Start Commands

### 1. Verify Current State
```powershell
# Run the audit script
.\scripts\audit_aws_regions.ps1
```

### 2. Import API Gateways
```powershell
# Export (already done)
.\scripts\export_api_gateways.ps1

# Import manually via Console or use CLI:
cd scripts\api_gateway_exports

# API 1: ECS Task Invoker
aws apigateway import-rest-api `
  --body file://api-ecs-task-invoker_oas30.json `
  --region us-east-2

# API 2: SQL Procedure Invoker
aws apigateway import-rest-api `
  --body file://api-sql-procedure-invoker_oas30.json `
  --region us-east-2
```

### 3. Copy Docker Images to ECR
```powershell
# Example for one repository
$sourceImage = "442426872653.dkr.ecr.us-east-1.amazonaws.com/servers/redis:latest"
$targetImage = "442426872653.dkr.ecr.us-east-2.amazonaws.com/servers/redis:latest"

# Login to source
aws ecr get-login-password --region us-east-1 | `
  docker login --username AWS --password-stdin 442426872653.dkr.ecr.us-east-1.amazonaws.com

# Pull image
docker pull $sourceImage

# Tag for target region
docker tag $sourceImage $targetImage

# Login to target
aws ecr get-login-password --region us-east-2 | `
  docker login --username AWS --password-stdin 442426872653.dkr.ecr.us-east-2.amazonaws.com

# Push to target
docker push $targetImage
```

---

## 📋 Services Checklist

### ECR Repositories (9/9) ✅
- [x] servers/redis/sync
- [x] servers/mcp
- [x] servers/embedding/sync
- [x] invoke/bg/job
- [x] uploads/ecr-csv-upload
- [x] servers/embedding
- [x] servers/redis
- [x] servers/deepai
- [x] invoke/db/process

**Action Required:** Copy images from us-east-1

### Lambda Functions (8/8) ✅
- [x] sql-server-data-upload
- [x] amplify-login-custom-message-de15b5e1
- [x] amplify-login-verify-auth-challenge-de15b5e1
- [x] ecs-task-invoker
- [x] calling-sql-procedure
- [x] amplify-login-create-auth-challenge-de15b5e1
- [x] amplify-foretaleapplicati-UpdateRolesWithIDPFuncti-huPwKhw8QOI3
- [x] amplify-login-define-auth-challenge-de15b5e1

**Action Required:** Configure environment variables and triggers

### SQS Queues (1/1) ✅
- [x] sqs-controls-execution

**Action Required:** Verify attributes match us-east-1

### API Gateways (0/2) ⏳
- [ ] api-ecs-task-invoker
- [ ] api-sql-procedure-invoker

**Action Required:** Import and configure

### Amplify Apps (0/1) ⏳
- [ ] foretaleapplication

**Action Required:** Manual recreation

---

## 🔗 Resource ARNs & URLs

### Lambda Functions (us-east-2)
```
arn:aws:lambda:us-east-2:442426872653:function:sql-server-data-upload
arn:aws:lambda:us-east-2:442426872653:function:ecs-task-invoker
arn:aws:lambda:us-east-2:442426872653:function:calling-sql-procedure
arn:aws:lambda:us-east-2:442426872653:function:amplify-login-custom-message-de15b5e1
arn:aws:lambda:us-east-2:442426872653:function:amplify-login-verify-auth-challenge-de15b5e1
arn:aws:lambda:us-east-2:442426872653:function:amplify-login-create-auth-challenge-de15b5e1
arn:aws:lambda:us-east-2:442426872653:function:amplify-login-define-auth-challenge-de15b5e1
arn:aws:lambda:us-east-2:442426872653:function:amplify-foretaleapplicati-UpdateRolesWithIDPFuncti-huPwKhw8QOI3
```

### SQS Queue (us-east-2)
```
https://sqs.us-east-2.amazonaws.com/442426872653/sqs-controls-execution
```

### ECR Repositories (us-east-2)
```
442426872653.dkr.ecr.us-east-2.amazonaws.com/servers/redis
442426872653.dkr.ecr.us-east-2.amazonaws.com/servers/mcp
442426872653.dkr.ecr.us-east-2.amazonaws.com/invoke/bg/job
... (see full list in MIGRATION_SUMMARY.md)
```

---

## 📁 Generated Files & Scripts

### Scripts
- `scripts/audit_aws_regions.ps1` - Compare regions
- `scripts/create_ecr_repos.ps1` - Create ECR repositories
- `scripts/deploy_lambdas_final.ps1` - Deploy Lambda functions
- `scripts/export_api_gateways.ps1` - Export API configs

### Data Exports
- `scripts/lambda_exports/*.zip` - Lambda function code
- `scripts/lambda_exports/*_config.json` - Function configurations
- `scripts/api_gateway_exports/*.json` - API definitions

### Reports
- `MIGRATION_SUMMARY.md` - Detailed migration report
- `scripts/migration_results.json` - JSON results
- `scripts/aws_region_comparison.json` - Audit comparison

---

## ⚠️ Important Notes

### Update Application Configuration
After migration, update these in your application:

1. **Lambda ARNs** - Point to us-east-2 functions
2. **API Gateway URLs** - Use new us-east-2 endpoints
3. **SQS Queue URL** - Update to us-east-2 URL
4. **ECR Repository URIs** - Use us-east-2 registry

### Testing Checklist
- [ ] Test each Lambda function individually
- [ ] Verify SQS queue message flow
- [ ] Test API Gateway endpoints
- [ ] Verify ECR image pulls work
- [ ] End-to-end application testing

### Cost Optimization
- Monitor data transfer costs between regions
- Consider deleting duplicate resources in us-east-1 if no longer needed
- Set up cost alerts for us-east-2 resources

---

## 🆘 Troubleshooting

### Lambda Function Issues
```powershell
# Check function logs
aws logs tail /aws/lambda/FUNCTION_NAME --region us-east-2 --follow

# Test function
aws lambda invoke --function-name FUNCTION_NAME --region us-east-2 output.json
```

### ECR Access Issues
```powershell
# Re-authenticate
aws ecr get-login-password --region us-east-2 | `
  docker login --username AWS --password-stdin 442426872653.dkr.ecr.us-east-2.amazonaws.com
```

### API Gateway Issues
- Check Lambda function permissions
- Verify API Gateway execution role
- Test with AWS Console before CLI

---

## 📞 Quick Links

- **AWS Console - us-east-2:** https://us-east-2.console.aws.amazon.com/
- **Lambda Console:** https://us-east-2.console.aws.amazon.com/lambda/
- **API Gateway Console:** https://us-east-2.console.aws.amazon.com/apigateway/
- **ECR Console:** https://us-east-2.console.aws.amazon.com/ecr/
- **Amplify Console:** https://us-east-2.console.aws.amazon.com/amplify/

---

**Last Updated:** $(Get-Date -Format "yyyy-MM-DD HH:mm:ss")
