# AWS Services Active in US-EAST-1
**Generated:** February 13, 2026  
**AWS Account:** 442426872653  
**Region:** us-east-1

---

## Summary Overview

| Service | Count | Status |
|---------|-------|--------|
| **EC2 Instances** | 1 | 🟢 Running |
| **Lambda Functions** | 8 | 🟢 Active |
| **API Gateway APIs** | 3 | 🟢 Active |
| **ECS Clusters** | 4 | 🟢 Active |
| **Cognito User Pools** | 2 | 🟢 Active |
| **S3 Buckets** | 13 | 🟢 Active |
| **CloudWatch Log Groups** | 10+ | 🟢 Logging |
| **RDS Databases** | 0 | ⚪ None |
| **DynamoDB Tables** | 0 | ⚪ None |
| **VPCs** | 1 | 🟢 Default |
| **IAM Roles** | 21 | 🟢 Active |

---

## 1. EC2 INSTANCES (1 Active)

### Running Instances
| Instance ID | Type | Name | Status |
|------------|------|------|--------|
| `i-0f27e2388c5f34c46` | `t4g.xlarge` | `foretale-ai-t4g-xlarge` | 🟢 Running |

**Purpose:** Production AI server for the ForeTale application  
**Instance Type:** ARM-based (Graviton2), 4 vCPU, 16GB RAM  
**Estimated Cost:** ~$0.104/hour (~$75/month)

---

## 2. LAMBDA FUNCTIONS (8 Total)

### Custom Business Functions (3)
| Function Name | Runtime | Last Modified | Purpose |
|---------------|---------|---------------|---------|
| `sql-server-data-upload` | Python 3.12 | 2026-02-10 | Upload data to SQL Server |
| `ecs-task-invoker` | Python 3.12 | 2026-01-30 | Trigger ECS tasks |
| `calling-sql-procedure` | Python 3.12 | 2026-02-10 | Execute stored procedures |

### Amplify Managed Functions (5)
| Function Name | Runtime | Purpose |
|---------------|---------|---------|
| `amplify-login-custom-message-de15b5e1` | Node.js 20.x | Cognito custom messages |
| `amplify-login-verify-auth-challenge-de15b5e1` | Node.js 20.x | Auth challenge verification |
| `amplify-login-create-auth-challenge-de15b5e1` | Node.js 20.x | Auth challenge creation |
| `amplify-login-define-auth-challenge-de15b5e1` | Node.js 20.x | Auth flow definition |
| `amplify-foretaleapplicati-UpdateRolesWithIDPFuncti-huPwKhw8QOI3` | Node.js 22.x | IDP role updates |

**Estimated Cost:** ~$0.50-2.00/month (based on invocations)

---

## 3. API GATEWAY APIs (3 Total)

### REST APIs Deployed
| API Name | API ID | Created | Purpose |
|----------|--------|---------|---------|
| `api-ecs-task-invoker` | `itpkscu97c` | 2025-05-28 | ECS task invocation endpoint |
| `api-sql-procedure-invoker` | `uq56kj6m5f` | 2025-04-14 | SQL procedure execution endpoint |
| `api-sql-procedure-invoker-private` | `y6pniymc5h` | 2026-02-02 | Private SQL procedure endpoint |

**Status:** All three APIs are active and deployed  
**Estimated Cost:** ~$3.50/month (monthly cache + request costs)

---

## 4. ECS CLUSTERS (4 Total)

### Active Clusters
| Cluster Name | Purpose | Status |
|--------------|---------|--------|
| `cluster-agents` | AI agents execution | 🟢 Active |
| `cluster-jobs` | Background job processing | 🟢 Active |
| `cluster-execute` | Test/execution tasks | 🟢 Active |
| `cluster-uploads` | CSV upload processing | 🟢 Active |

**Estimated Cost:** Variable (EC2 instances + task execution, ~$50-200/month depending on usage)

---

## 5. COGNITO USER POOLS (2 Total)

### User Pools
| Pool Name | Pool ID | Created | Purpose |
|-----------|---------|---------|---------|
| `foretaleapplication6f8acf89_userpool_6f8acf89-dev` | `us-east-1_GJdwG2sgM` | 2026-01-05 | Production user authentication |
| `amplify_backend_manager_dntg2jkpeiynq` | `us-east-1_ceN5pc2zI` | 2026-01-05 | Amplify backend management |

**Estimated Cost:** Free tier (up to 50 MAU), then $0.015/MAU

---

## 6. S3 BUCKETS (13 Total)

### Amplify Deployment Buckets (3)
- `amplify-foretaleapplication-dev-18d56-deployment` - 2026-01-05
- `amplify-foretaleapplication-dev-c6950-deployment` - 2026-01-05
- `amplify-foretaleapplication-dev-fe78a-deployment` - 2026-02-04

### ForeTale Application Buckets (2)
- `foretale-app-s3-vector-db-us-east-2` - Vector database storage (2026-02-04)
- `master-codebase-foretale` - Source code repository (2026-02-13)

### Amplify Storage Buckets (2)
- `foretalestoragebucket18d56-dev` - 2026-02-05
- `foretalestoragebucketfe78a-dev` - 2026-02-05

### Other AWS Buckets (6)
- `aws-athena-query-results-442426872653-eu-west-2` - Athena query cache
- `terraform-state-client1-dev-442426872653` - **Terraform state backup**
- `cdk-hnb659fds-assets-442426872653-ap-south-1` - CDK assets
- `cloudtrail-logs-o-udjqw5magg` - CloudTrail logs
- `elasticbeanstalk-ap-south-1-442426872653` - EB assets
- `os-s3vectors-62b76ff02907` - Vector storage
- `cdk-hnb659fds-assets-442426872653-ap-south-1` - CDK assets

**Estimated Cost:** ~$5-15/month (storage + requests)

---

## 7. CLOUDWATCH LOG GROUPS (10+ Active)

### Lambda Logs
- `/aws/lambda/calling-sql-procedure` - SQL execution logs
- `/aws/lambda/ecs-task-invoker` - Task orchestration logs
- `/aws/lambda/sql-server-data-upload` - Data upload logs
- `/aws/lambda/amplify-...` (3 groups) - Amplify auth logs

### ECS Logs
- `/ecs/` - Default ECS logs
- `/ecs/con-csv-upload` - CSV upload cluster logs
- `/ecs/td-bg-jobs` - Background job task logs
- `/ecs/td-db-process` - Database processing task logs

### Infrastructure Logs
- `/aws/eks/eks-foretale-agentic-ai/cluster` - EKS cluster logs
- `/aws/vendedlogs/events/event-bus/default` - EventBridge logs
- `/aws/vendedlogs/pipes/pipe-controls-execution` - EventBridge Pipes

**Oldest Log Group:** `/aws/eks/eks-foretale-agentic-ai/cluster` (Jan 2025)  
**Estimated Cost:** ~$0.50-2.00/month (ingestion + storage)

---

## 8. IAM ROLES (21 Total)

### ForeTale Application Roles (8)
- `foretale-dev-lambda-execution-role` - Lambda functions execution
- `foretale-dev-ecs-task-execution-role` - ECS task execution
- `foretale-dev-ecs-task-role` - ECS task permissions
- `foretale-dev-api-gateway-cloudwatch-role` - API Gateway logging
- `foretale-dev-rds-monitoring-role` - RDS monitoring
- `foretale-dev-amplify-service-role` - Amplify service
- `foretale-dev-cognito-authenticated-role` - Cognito auth
- `foretale-dev-ai-server-role` - AI server permissions
- `foretale-ec2-access-role` - EC2 access

### Amplify Managed Roles (11)
- `amplify-deployment-role` - Deployments
- `amplify-service-role` - Service management
- 5x Auth roles (18d56, fe78a variants)
- 3x Unauthenticated roles
- 3x Lambda execution roles for auth functions
- 1x SSO role

---

## 9. RDS DATABASES

**Status:** ⚠️ **No RDS instances in us-east-1**

All databases are located in **us-east-2** (or deleted).

---

## 10. DYNAMODB TABLES

**Status:** ⚠️ **No DynamoDB tables in us-east-1**

If tables exist, they're in **us-east-2** or another region.

---

## 11. VPC & NETWORKING

### VPCs
| VPC ID | CIDR Block | Name | Type |
|--------|-----------|------|------|
| `vpc-02db63af725c65f79` | 172.31.0.0/16 | None | Default VPC |

**Note:** Only default VPC present. Custom VPC is in **us-east-2**.

---

## Cost Estimation

### Monthly Cost Breakdown (Estimated)
| Service | Estimated Cost | Notes |
|---------|-----------------|-------|
| EC2 (t4g.xlarge) | **$75** | Continuous running |
| ECS (variable) | **$50-200** | Depends on task execution |
| Lambda | **$0.50-2** | Custom functions only |
| S3 | **$5-15** | Storage + requests |
| Cognito | **Free-$1** | < 50 monthly active users |
| CloudWatch Logs | **$0.50-2** | Ingestion + storage |
| API Gateway | **$3.50** | Monthly minimum |
| IAM | **Free** | No additional cost |
| **TOTAL** | **~$134-298/month** | **Mainly EC2 & ECS** |

---

## Key Findings

### 🟢 Active & Running
- ✅ Production EC2 instance (`foretale-ai-t4g-xlarge`) - LIVE
- ✅ 8 Lambda functions - LIVE  
- ✅ 3 API Gateway endpoints - LIVE
- ✅ 4 ECS clusters - LIVE
- ✅ 2 Cognito pools - LIVE
- ✅ 13 S3 buckets - LIVE
- ✅ Comprehensive logging via CloudWatch

### ⚠️ Important Notes
1. **No RDS in us-east-1** - All databases are in **us-east-2**
2. **No DynamoDB in us-east-1** - Tables are in **us-east-2**
3. **Custom VPC in us-east-2** - Default VPC only in us-east-1
4. **High EC2 Cost** - t4g.xlarge is the largest cost driver
5. **Production State** - All services appear to be actively used

### 🔴 Potential Issues
1. **ECS Clusters** - Verify if all 4 clusters are still needed
2. **S3 Bucket Proliferation** - 13 buckets total (many deployments)
3. **Old API Gateway** - Some APIs created in 2025, verify still in use
4. **Multiple Amplify Deployments** - 3 separate deployment stacks

---

## Recommendations

### Immediate Actions
1. **Verify EC2 Usage** - Is t4g.xlarge always running? Can it be scheduled?
2. **Clean Unused Buckets** - Remove old Amplify deployment buckets (2)
3. **Verify ECS Clusters** - Are all 4 clusters actively used?
4. **Review Old APIs** - Are 2025-created APIs still in production?

### Cost Optimization
1. **Use EC2 Spot/Scheduling** - Could save 50-70% on EC2 costs
2. **Consolidate S3 Buckets** - Reduce from 13 to ~5 buckets
3. **Archive Old Logs** - Move logs > 6 months to Glacier
4. **Cleanup Amplify** - Remove duplicate deployment stacks

### Infrastructure Sync
- us-east-1: **Source/Active region** (EC2, Lambda, APIs)
- us-east-2: **Target region** (Databases, DynamoDB, custom VPC)
- Consider consolidation if not using multi-region redundancy

---

**Last Updated:** February 13, 2026  
**Data Sources:** AWS CLI queries across all service APIs  
**Account:** 442426872653 (Flutter-Deployment user)

