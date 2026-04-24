# Lambda Function Roles Comparison: us-east-1 vs us-east-2

## Summary
Currently, only **US-EAST-2** has a complete Lambda deployment configured in this Terraform setup. There is **no separate us-east-1 Lambda configuration** in this repository.

---

## US-EAST-2 Configuration (Current)

### Region Details
- **Region:** us-east-2 (Ohio)
- **Environment:** dev
- **Account ID:** 442426872653

### Lambda Execution Role

#### Role Name
- **Name:** `foretale-dev-lambda-execution-role`
- **ARN:** `arn:aws:iam::442426872653:role/foretale-dev-lambda-execution-role`
- **Created:** Managed by Terraform module `module.iam.aws_iam_role.lambda_execution`

#### Trust Policy (AssumeRole)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
```

#### Attached Policies

##### 1. AWS Managed Policy
- **Policy:** `AWSLambdaVPCAccessExecutionRole`
- **ARN:** `arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole`
- **Purpose:** Allow Lambda to execute within VPC
- **Permissions Include:**
  - Create/Manage ENIs
  - CloudWatch Logs

##### 2. Custom Policy: `lambda-rds-access`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Resource": ["<RDS_CLUSTER_ARN>"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:foretale/*"
    }
  ]
}
```

##### 3. Custom Policy: `lambda-s3-access` (Conditional)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::bucket-name",
        "arn:aws:s3:::bucket-name/*"
      ]
    }
  ]
}
```

##### 4. Custom Policy: `lambda-ecs-invoke`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:DescribeTasks",
        "ecs:StopTask"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "arn:aws:iam::442426872653:role/foretale-dev-ecs-task-execution-role",
        "arn:aws:iam::442426872653:role/foretale-dev-ecs-task-role"
      ]
    }
  ]
}
```

### Deployed Lambda Functions (us-east-2)

| Function Name | Timeout | Memory | Runtime | Architecture |
|---|---|---|---|---|
| `ecs_invoker` | 900s | 256MB | Python 3.12 | x86_64 |
| `calling_sql_procedure` | 900s | 512MB | Python 3.12 | ARM64 |
| `sql_server_data_upload` | 900s | 512MB | Python 3.12 | ARM64 |
| `ecs_task_invoker` | 900s | 256MB | Python 3.12 | ARM64 |
| `delete_record` | 900s | 512MB | Python 3.12 | ARM64 |
| `insert_record` | 900s | 512MB | Python 3.12 | ARM64 |
| `read_json_record` | 900s | 512MB | Python 3.12 | ARM64 |
| `read_record` | 900s | 512MB | Python 3.12 | ARM64 |
| `update_record` | 900s | 512MB | Python 3.12 | ARM64 |

---

## US-EAST-1 Configuration (NOT IMPLEMENTED)

### Current Status
- **Infrastructure:** Uses some us-east-1 resources for cross-region services
- **Lambda Functions:** **No Lambda functions deployed in us-east-1**
- **IAM Role:** Different AWS Account or would need to be created

### Us-East-1 Resources Referenced
The infrastructure references us-east-1 for:
1. **Bedrock Models** - Available in us-east-1 (primary AI region)
2. **DynamoDB Global Tables** - Replication target from us-east-2
3. **ALB/EC2** - Some infrastructure referenced from us-east-1

### What Would Be Needed for Us-East-1 Lambda

If Lambda functions were to be deployed in us-east-1, create:

```hcl
# us-east-1 Lambda Execution Role (if separate from us-east-2)
resource "aws_iam_role" "lambda_execution_east1" {
  name = "foretale-dev-lambda-execution-role-us-east-1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
```

---

## Key Differences & Recommendations

| Aspect | us-east-1 | us-east-2 |
|---|---|---|
| **Lambda Functions** | None deployed | 9 functions |
| **Execution Role** | Would need creation | `foretale-dev-lambda-execution-role` |
| **RDS Access** | Not configured | Configured for SQL Server |
| **ECS Integration** | Not configured | Configured for ECS task invocation |
| **Bedrock Access** | Could leverage native us-east-1 support | Cross-region call required |
| **Primary Use** | Cross-region services (DDB, Bedrock) | Main application workload |

### Recommendations

1. **If hosting Lambda in us-east-1:** Create separate IAM role with appropriate policies for that region
2. **If us-east-1 is read-only:** Current cross-region setup is appropriate
3. **For Bedrock:** Consider deploying Bedrock-integrated Lambda in us-east-1 for lower latency
4. **For DynamoDB:** Current replication from us-east-2 to us-east-1 is appropriate

---

## Role Policy Permissions Summary

### VPC Access
- Create/Manage network interfaces
- CloudWatch log writing

### Database Access
- RDS Data API calls
- AWS Secrets Manager access

### Storage Access
- S3 Read/Write operations
- Lambda layer access

### Task Orchestration
- ECS task execution
- IAM PassRole for ECS

---

## Generated: February 11, 2026
Last Updated: Terraform state inspection of foretale_application-main
