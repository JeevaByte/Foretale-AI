# Amplify Integration Status - us-east-2

**Date:** February 6, 2026  
**Environment:** Development (dev)  
**Region:** us-east-2

---

## ✅ COMPLETED: Amplify Configuration

### 1. Authentication (Cognito)
- **User Pool ID:** us-east-2_Fz0S5Zqv2
- **App Client ID:** 7rpjmi2d4aemp3qppalnfjklj3
- **Identity Pool ID:** us-east-2:6c6523e1-cb26-42c4-ba57-68c1b56b0561
- **Status:** ✅ Configured in amplifyconfiguration.dart

### 2. Storage (S3)
- **Bucket:** foretale-dev-app-storage
- **Region:** us-east-2
- **Access Level:** protected
- **Status:** ✅ Configured in amplifyconfiguration.dart

### 3. API Gateway (REST)
- **Main API:** foretale-dev-api (ux2kvdl1q8)
- **Endpoint:** https://ux2kvdl1q8.execute-api.us-east-2.amazonaws.com/dev
- **Auth:** Cognito User Pools
- **Status:** ✅ Configured in amplifyconfiguration.dart

### 4. Additional APIs
- **SQL Procedure API:** https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/dev
- **ECS Task Invoker API:** https://6pz582qld4.execute-api.us-east-2.amazonaws.com/dev
- **Status:** ✅ Configured in config_db_api.dart and config_ecs.dart

---

## 🔍 NEEDS VERIFICATION: Backend Connections

### API Gateway → Lambda Integrations

According to Terraform configuration (outputs.tf), the following Lambda integrations should exist:

| Endpoint | Lambda Function | Purpose |
|----------|----------------|---------|
| `/insert_record` | foretale-dev-insert-record | Insert data to RDS |
| `/update_record` | foretale-dev-update-record | Update data in RDS |
| `/delete_record` | foretale-dev-delete-record | Delete data from RDS |
| `/read_record` | foretale-dev-read-record | Read data from RDS |
| `/read_json_record` | foretale-dev-read-json-record | Read JSON data |
| `/ecs_invoker_resource` | foretale-dev-ecs-invoker | Invoke ECS tasks |

**Status:** ⚠️ **NOT TESTED** - Need to verify these integrations exist in AWS

### Lambda → RDS Connections

Lambda functions should connect to RDS via:
- **RDS Endpoint:** (from Terraform state)
- **Credentials:** AWS Secrets Manager
- **VPC:** Private subnets with RDS security group access
- **Lambda Layers:** db_utils, pyodbc

**Status:** ⚠️ **NOT TESTED** - Need to verify Lambda can reach RDS

### Lambda → DynamoDB Connections

Lambda functions should have access to:
- foretale-dev-sessions
- foretale-dev-cache
- foretale-dev-ai-state
- foretale-dev-audit-logs
- foretale-dev-websocket-connections
- foretale-dev-dynamodb-params (103/104 items migrated)

**Status:** ⚠️ **NOT TESTED** - Need to verify IAM permissions

---

## 🧪 REQUIRED TESTS

### Test 1: API Gateway Deployment Status
```powershell
# Check if dev stage is deployed
aws apigateway get-stage --rest-api-id ux2kvdl1q8 --stage-name dev --region us-east-2

# List all resources and methods
aws apigateway get-resources --rest-api-id ux2kvdl1q8 --region us-east-2
```

### Test 2: Lambda Function Connectivity
```powershell
# List Lambda functions
aws lambda list-functions --region us-east-2 --query 'Functions[?starts_with(FunctionName, `foretale-dev`)].FunctionName'

# Test invoke a Lambda (read_record)
aws lambda invoke --function-name foretale-dev-read-record --region us-east-2 response.json
```

### Test 3: API Gateway → Lambda Integration
```powershell
# Get integration for insert_record endpoint
aws apigateway get-integration --rest-api-id ux2kvdl1q8 --resource-id <RESOURCE_ID> --http-method POST --region us-east-2
```

### Test 4: End-to-End API Call (with Cognito auth)
```powershell
# This requires Cognito token from authenticated user
# Example: curl with Authorization header
curl -X GET "https://ux2kvdl1q8.execute-api.us-east-2.amazonaws.com/dev/read_record" `
  -H "Authorization: Bearer <COGNITO_ID_TOKEN>"
```

### Test 5: Lambda → RDS Connectivity
```powershell
# Check Lambda VPC configuration
aws lambda get-function-configuration --function-name foretale-dev-read-record --region us-east-2

# Check if Lambda can access RDS (via CloudWatch Logs)
aws logs tail /aws/lambda/foretale-dev-read-record --region us-east-2 --follow
```

### Test 6: Lambda → DynamoDB Access
```powershell
# Check Lambda IAM role has DynamoDB permissions
aws iam get-role-policy --role-name foretale-dev-lambda-execution-role --policy-name <POLICY_NAME>
```

---

## 📋 VERIFICATION CHECKLIST

- [ ] API Gateway stage `dev` is deployed for ux2kvdl1q8
- [ ] All 6 Lambda integrations exist in API Gateway
- [ ] Lambda functions are deployed and active
- [ ] Lambda VPC configuration matches RDS subnets
- [ ] Lambda security groups allow RDS access
- [ ] Lambda IAM role has DynamoDB permissions
- [ ] RDS is accessible from Lambda subnets
- [ ] Secrets Manager contains RDS credentials
- [ ] Lambda can retrieve RDS credentials from Secrets Manager
- [ ] DynamoDB tables exist and are accessible
- [ ] Cognito authorizer is configured on API Gateway
- [ ] API Gateway has proper CORS configuration

---

## 🚀 NEXT STEPS

1. **Run Terraform Output** to get actual resource IDs and endpoints
   ```bash
   cd terraform
   terraform output
   ```

2. **Verify API Gateway Deployment**
   - Check if resources and methods exist
   - Verify Lambda integrations are configured
   - Test deploy status of `dev` stage

3. **Test Lambda Functions**
   - Invoke test for each Lambda
   - Check CloudWatch Logs for errors
   - Verify RDS and DynamoDB connectivity

4. **Test End-to-End Flow**
   - Authenticate via Cognito (get JWT token)
   - Call API Gateway endpoint with token
   - Verify Lambda executes successfully
   - Confirm data is written to RDS/DynamoDB

5. **Update Flutter App**
   - Run `flutter pub get` to install amplify_api package
   - Test Amplify.configure() initialization
   - Make test API call from app

---

## ⚠️ POTENTIAL ISSUES

1. **API Gateway not deployed to dev stage** - Terraform may have created resources but not deployed
2. **Lambda functions not connected** - Integration may be missing in API Gateway
3. **VPC networking issues** - Lambda may not reach RDS if security groups/subnets misconfigured
4. **Secrets Manager access** - Lambda may not have permission to read RDS credentials
5. **Cognito authorizer** - API Gateway may reject requests if authorizer not properly configured

---

## 📞 SUPPORT COMMANDS

```powershell
# Get all Terraform outputs
terraform output -json > terraform_outputs.json

# Check API Gateway deployment
aws apigateway get-deployments --rest-api-id ux2kvdl1q8 --region us-east-2

# List Lambda functions with VPC config
aws lambda list-functions --region us-east-2 --query 'Functions[*].[FunctionName,VpcConfig.VpcId,VpcConfig.SubnetIds]' --output table

# Check RDS status
aws rds describe-db-instances --region us-east-2 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' --output table
```
