# Lambda Functions - ForeTale Application

## Overview

This directory contains 6 AWS Lambda functions that provide the foundation services for the ForeTale Application:

### Database API Functions (5 functions)
1. **insert_record** - Insert operations via stored procedures
2. **update_record** - Update operations via stored procedures
3. **delete_record** - Delete operations via stored procedures
4. **read_record** - Read/SELECT operations via stored procedures
5. **read_json_record** - Read operations with advanced JSON handling

### Task Orchestration (1 function)
6. **ecs_invoker** - Triggers ECS Fargate tasks for long-running operations

---

## Architecture

### Database Functions Architecture
```
Client → API Gateway → Lambda → RDS PostgreSQL
                ↓
         Lambda Layers:
         - layer-db-utils (Secrets Manager)
         - pyodbc-layer-prebuilt (Database connectivity)
```

### ECS Invoker Architecture
```
Client → API Gateway → Lambda → ECS Fargate Task
                                 ├── CSV Processor
                                 └── Test Executor
```

---

## Lambda Layers

Both layers are deployed in **us-east-2** region:

| Layer | Version | ARN | Purpose |
|-------|---------|-----|---------|
| layer-db-utils | 10 | `arn:aws:lambda:us-east-2:444242687653:layer:layer-db-utils:10` | Secrets Manager credential retrieval |
| pyodbc-layer-prebuilt | 1 | `arn:aws:lambda:us-east-2:444242687653:layer:pyodbc-layer-prebuilt:1` | PyODBC for SQL Server/PostgreSQL |

---

## Function Details

### 1. Insert Record (`insert_record/`)

**Purpose**: Create new records in the database via stored procedures

**Request Format**:
```json
{
  "procedure": "sp_insert_project",
  "parameters": {
    "project_name": "New Project",
    "user_id": 123,
    "description": "Project description"
  }
}
```

**Response Format**:
```json
{
  "success": true,
  "data": {
    "message": "Record inserted successfully",
    "id": 456
  }
}
```

**Environment Variables**:
- `RDS_ENDPOINT` - Database endpoint
- `RDS_PORT` - Database port (default: 5432)
- `RDS_DATABASE` - Database name
- `RDS_USER` - Database username
- `SECRETS_MANAGER_SECRET` - Secrets Manager secret name
- `AWS_REGION` - AWS region

---

### 2. Update Record (`update_record/`)

**Purpose**: Update existing records via stored procedures

**Request Format**:
```json
{
  "procedure": "sp_update_project",
  "parameters": {
    "project_id": 456,
    "project_name": "Updated Project Name",
    "status": "active"
  }
}
```

**Response Format**:
```json
{
  "success": true,
  "data": {
    "message": "Record updated successfully"
  }
}
```

---

### 3. Delete Record (`delete_record/`)

**Purpose**: Delete records via stored procedures

**Request Format**:
```json
{
  "procedure": "sp_delete_project",
  "parameters": {
    "project_id": 456
  }
}
```

**Response Format**:
```json
{
  "success": true,
  "data": {
    "message": "Record deleted successfully"
  }
}
```

---

### 4. Read Record (`read_record/`)

**Purpose**: Read/query records via stored procedures

**Request Format (POST)**:
```json
{
  "procedure": "sp_get_projects",
  "parameters": {
    "user_id": 123
  }
}
```

**Request Format (GET)**:
```
GET /dev/read_record?procedure=sp_get_project&project_id=456
```

**Response Format**:
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "project_id": 456,
      "project_name": "Project Alpha",
      "created_at": "2026-02-01T10:30:00",
      "status": "active"
    },
    {
      "project_id": 457,
      "project_name": "Project Beta",
      "created_at": "2026-02-02T14:15:00",
      "status": "completed"
    }
  ]
}
```

---

### 5. Read JSON Record (`read_json_record/`)

**Purpose**: Read records with complex JSON/JSONB column handling

**Features**:
- Automatic JSON parsing for JSONB columns
- Decimal to float conversion
- DateTime to ISO format conversion
- Binary data handling

**Request Format**: Same as `read_record`

**Response Format**:
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "test_id": 789,
      "test_name": "Performance Test",
      "results": {
        "passed": 25,
        "failed": 3,
        "metrics": {
          "avg_response_time": 125.5,
          "max_response_time": 450.2
        }
      },
      "executed_at": "2026-02-03T16:20:00"
    }
  ]
}
```

---

### 6. ECS Invoker (`ecs_invoker/`)

**Purpose**: Trigger long-running ECS Fargate tasks

**Supported Task Types**:
- `csv_upload` - CSV data processing
- `test_execution` - Test execution workflows

**Request Format**:
```json
{
  "task_type": "csv_upload",
  "parameters": {
    "s3_bucket": "foretale-uploads",
    "s3_key": "uploads/data.csv",
    "user_id": 123,
    "project_id": 456
  },
  "subnet_ids": ["subnet-abc123", "subnet-def456"],
  "security_groups": ["sg-xyz789"]
}
```

**Response Format**:
```json
{
  "success": true,
  "message": "ECS task started successfully",
  "task_id": "abc123def456",
  "task_arn": "arn:aws:ecs:us-east-2:xxx:task/cluster-uploads/abc123def456",
  "cluster": "cluster-uploads",
  "task_type": "csv_upload"
}
```

**Environment Variables**:
- `ECS_CLUSTER_UPLOADS` - CSV processing cluster name
- `ECS_CLUSTER_EXECUTE` - Test execution cluster name
- `ECS_TASK_DEFINITION_CSV` - CSV task definition ARN
- `ECS_TASK_DEFINITION_EXECUTE` - Test execution task definition ARN
- `AWS_REGION` - AWS region

---

## Deployment

### Package Functions

```powershell
# Package all functions
.\scripts\deploy_lambda.ps1

# Package specific function
.\scripts\deploy_lambda.ps1 -FunctionName insert_record

# Package without deploying
.\scripts\deploy_lambda.ps1 -SkipPackage
```

### Deploy with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Update Function Code Only

```powershell
# Update all functions
.\scripts\deploy_lambda.ps1 -UpdateCode

# Update specific function
.\scripts\deploy_lambda.ps1 -FunctionName read_record -UpdateCode
```

---

## Error Handling

All functions return consistent error responses:

### Database Errors
```json
{
  "error": "Database error",
  "message": "Connection timeout"
}
```
**HTTP Status**: 500

### Validation Errors
```json
{
  "error": "Missing required field: procedure"
}
```
**HTTP Status**: 400

### General Errors
```json
{
  "error": "Internal server error",
  "message": "Unexpected error occurred"
}
```
**HTTP Status**: 500

---

## CORS Configuration

All functions include CORS headers:
```
Access-Control-Allow-Origin: *
Content-Type: application/json
```

**Note**: Update `Access-Control-Allow-Origin` in production to restrict origins.

---

## IAM Permissions

Lambda execution role requires:

### Database Functions
- ✅ `secretsmanager:GetSecretValue` - Retrieve database password
- ✅ `rds-data:ExecuteStatement` - Execute database queries
- ✅ `ec2:CreateNetworkInterface` - VPC access
- ✅ `ec2:DescribeNetworkInterfaces` - VPC access
- ✅ `ec2:DeleteNetworkInterface` - VPC cleanup
- ✅ `logs:CreateLogGroup` - CloudWatch logging
- ✅ `logs:CreateLogStream` - CloudWatch logging
- ✅ `logs:PutLogEvents` - CloudWatch logging

### ECS Invoker
- ✅ `ecs:RunTask` - Start ECS tasks
- ✅ `ecs:DescribeTasks` - Check task status
- ✅ `ecs:StopTask` - Stop tasks if needed
- ✅ `iam:PassRole` - Pass execution role to ECS

---

## Testing

### Local Testing (requires AWS credentials)

```python
import boto3
import json

# Test insert_record
lambda_client = boto3.client('lambda', region_name='us-east-2')

response = lambda_client.invoke(
    FunctionName='foretale-app-lambda-insert-record',
    InvocationType='RequestResponse',
    Payload=json.dumps({
        'procedure': 'sp_insert_project',
        'parameters': {
            'project_name': 'Test Project',
            'user_id': 1
        }
    })
)

result = json.loads(response['Payload'].read())
print(result)
```

### Via API Gateway

```bash
# POST request
curl -X POST https://YOUR_API_GATEWAY/dev/insert_record \
  -H "Content-Type: application/json" \
  -d '{
    "procedure": "sp_insert_project",
    "parameters": {
      "project_name": "Test Project",
      "user_id": 1
    }
  }'

# GET request
curl https://YOUR_API_GATEWAY/dev/read_record?procedure=sp_get_projects&user_id=1
```

---

## Monitoring

### CloudWatch Logs

All functions log to: `/aws/foretale-app/lambda/main`

**Retention**: 30 days

### CloudWatch Metrics

Monitor:
- **Invocations** - Total function calls
- **Duration** - Execution time
- **Errors** - Failed invocations
- **Throttles** - Rate limit hits
- **ConcurrentExecutions** - Concurrent function runs

---

## Configuration

### Function Settings

| Function | Memory | Timeout | Runtime |
|----------|--------|---------|---------|
| insert_record | 512 MB | 60s | python3.12 |
| update_record | 512 MB | 60s | python3.12 |
| delete_record | 512 MB | 60s | python3.12 |
| read_record | 512 MB | 60s | python3.12 |
| read_json_record | 512 MB | 60s | python3.12 |
| ecs_invoker | 256 MB | 60s | python3.12 |

### VPC Configuration

All functions are deployed in **private subnets** with:
- NAT Gateway for internet access (AWS API calls)
- Security groups allowing database access
- No public IP assignment

---

## Next Steps

1. ✅ Lambda functions created and packaged
2. ✅ Lambda layers configured
3. ✅ IAM permissions verified
4. ⏳ Deploy with Terraform
5. ⏳ Create API Gateway endpoints
6. ⏳ Test end-to-end with database
7. ⏳ Set up CloudWatch alarms

---

## Support

For issues or questions:
- Check CloudWatch Logs: `/aws/foretale-app/lambda/main`
- Review Terraform state: `terraform show`
- Validate configuration: `terraform validate`
