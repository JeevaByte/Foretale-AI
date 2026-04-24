# ForeTale Unified Naming Convention Implementation
**Date:** February 3, 2026  
**Status:** ✅ IMPLEMENTATION COMPLETE

---

## Executive Summary

All AWS infrastructure resources have been standardized to follow a **single unified naming convention** across all environments (dev, uat, prod). This eliminates environment-specific naming and ensures consistency across every service while maintaining environment separation through AWS account structure.

**Naming Pattern:** `foretale-app-{service}-{resource}[-{descriptor}][-{region-az}]`

---

## Implementation Scope

### ✅ Completed Updates

#### 1. **Lambda Functions** - foretale-app-lambda-*
**File:** `terraform/modules/lambda/main.tf`

**Updates Made:**
- `foretale-app-lambda-insert-record`
- `foretale-app-lambda-update-record`
- `foretale-app-lambda-delete-record`
- `foretale-app-lambda-read-record`
- `foretale-app-lambda-read-json-record`
- `foretale-app-lambda-ecs-invoker`

**CloudWatch Logs:**
- Pattern: `/aws/foretale-app/lambda/main`

---

#### 2. **RDS Database** - foretale-app-rds-*
**File:** `terraform/modules/rds/main.tf`

**Updates Made:**
- **Instance Name:** `foretale-app-rds-main`
- **Subnet Group:** `foretale-app-rds-subnet-group`
- **Parameter Group:** `foretale-app-rds-params-pg`
- **Credentials Secret:** `foretale-app-rds-credentials`
- **Final Snapshot:** `foretale-app-rds-final-snapshot-{timestamp}`

**CloudWatch Logs:**
- Pattern: `/aws/foretale-app/rds/main`

---

#### 3. **S3 Buckets** - foretale-app-s3-*
**File:** `terraform/modules/s3/main.tf`

**Pattern Applied:**
- `foretale-app-s3-app-storage`
- `foretale-app-s3-user-uploads`
- `foretale-app-s3-vector-store`

**Note:** Buckets currently disabled/commented out in code. Names follow standard when re-enabled.

---

#### 4. **DynamoDB Tables** - foretale-app-dynamodb-*
**File:** `terraform/modules/dynamodb/main.tf`

**Updates Made:**
- Table Name Prefix: `foretale-app-dynamodb`
- **Sessions Table:** `foretale-app-dynamodb-sessions`

**Planned Extensions:**
- `foretale-app-dynamodb-chat-history`
- `foretale-app-dynamodb-vector-metadata`
- `foretale-app-dynamodb-audit-logs`

---

#### 5. **Cognito User Pools** - foretale-app-cognito-*
**File:** `terraform/modules/cognito/main.tf`

**Updates Made:**
- **User Pool:** `foretale-app-cognito-main`
- **App Clients:** `foretale-app-cognito-client-{purpose}`

---

#### 6. **Application Load Balancer** - foretale-app-alb-*
**File:** `terraform/modules/alb/main.tf`

**Updates Made:**
- **ALB Name:** `foretale-app-alb-main`
- **Target Groups:** `foretale-app-tg-{service}`
  - `foretale-app-tg-eks`
  - `foretale-app-tg-ecs`

---

#### 7. **EKS Cluster** - foretale-app-eks-*
**File:** `terraform/modules/eks/main.tf`

**Updates Made:**
- **Cluster Name:** `foretale-app-eks-cluster`
- **Name Prefix:** `foretale-app-eks`
- **Node Groups:** `foretale-app-eks-nodes-{az}`
  - `foretale-app-eks-nodes-us-east-2a`
  - `foretale-app-eks-nodes-us-east-2b`
  - `foretale-app-eks-nodes-us-east-2c`

---

#### 8. **Secrets Manager** - foretale-app-*
**File:** `terraform/modules/secrets/main.tf`

**Updates Made:**
- `foretale-app-alb-ecs-url`
- `foretale-app-pinecone-api`
- `foretale-app-langsmith-api`
- `foretale-app-redis`
- `foretale-app-sql-credentials`
- `foretale-app-postgres-credentials`

---

#### 9. **VPC & Networking** - foretale-app-*
**Status:** ✅ Already Compliant (from Feb 3, 2026 audit)

**Verified Resources:**
- **VPC:** `foretale-app-vpc`
- **Subnets (9/9):** `foretale-app-{public|private|database}-subnet-us-east-2{a|b|c}`
- **Security Groups (8/8):** `foretale-app-{service}-sg`
- **Route Tables (4/4):** `foretale-app-{main|public|private|database}-rt`
- **Internet Gateway:** `foretale-app-igw`
- **NAT Gateway:** `foretale-app-nat-us-east-2a`
- **VPC Endpoints (3/3):** `foretale-app-{s3|dynamodb|execute-api}-endpoint`

---

## Key Design Principles

### 1. **Single Naming Convention - All Environments**
```
✅ CORRECT:
  Dev:  foretale-app-lambda-insert-record  (in dev AWS account)
  UAT:  foretale-app-lambda-insert-record  (in uat AWS account)
  Prod: foretale-app-lambda-insert-record  (in prod AWS account)

❌ WRONG (No environment suffixes):
  Dev:  foretale-dev-lambda-insert-record
  Uat:  foretale-uat-lambda-insert-record
  Prod: foretale-prod-lambda-insert-record
```

### 2. **Environment Differentiation via Infrastructure**
- **Separate AWS Accounts** (dev, uat, prod)
- **Terraform Workspaces** (dev, uat, prod)
- **Tags:** `Environment = dev|uat|prod`
- **Resource Isolation:** VPCs, Security Groups, IAM roles per environment

### 3. **Consistent Service Identification**
Each service type has a clear identifier in the name:
```
foretale-app-{SERVICE_TYPE}-{RESOURCE}
             |             |
             v             v
       Lambda, RDS,      insert-record
       S3, DynamoDB,     main, sessions
       Cognito, etc.     credentials, etc.
```

### 4. **Hierarchical CloudWatch Logs**
```
/aws/foretale-app/{service}/{resource}
                    |         |
                    v         v
              Lambda, RDS,   insert-record,
              EKS, etc.      main, etc.
```

---

## Module-by-Module Changes

### Lambda Module
**File:** `terraform/modules/lambda/main.tf`

```terraform
# BEFORE:
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
function_name = "${local.name_prefix}-insert-record"
# Result: "foretale-dev-insert-record" (with -dev suffix)

# AFTER:
locals {
  name_prefix       = "foretale-app-lambda"
  cloudwatch_prefix = "/aws/foretale-app/lambda"
}
function_name = "foretale-app-lambda-insert-record"
# Result: "foretale-app-lambda-insert-record" (no environment suffix)
```

### RDS Module
**File:** `terraform/modules/rds/main.tf`

```terraform
# BEFORE:
identifier = "langgraph"  # Generic name
db_subnet_group_name = "${local.name_prefix}-db-subnet-group"
# Result: "foretale-dev-db-subnet-group"

# AFTER:
identifier = "foretale-app-rds-main"  # Descriptive
db_subnet_group_name = "foretale-app-rds-subnet-group"
# Result: "foretale-app-rds-subnet-group" (consistent naming)
```

### S3 Module
**File:** `terraform/modules/s3/main.tf`

```terraform
# BEFORE:
bucket_prefix = "${var.project_name}-${var.environment}"
# Result: "foretale-dev-app-storage"

# AFTER:
bucket_prefix = "foretale-app-s3"
# Result: "foretale-app-s3-app-storage"
```

### DynamoDB Module
**File:** `terraform/modules/dynamodb/main.tf`

```terraform
# BEFORE:
table_prefix = "${var.project_name}-${var.environment}"
name = "${local.table_prefix}-sessions"
# Result: "foretale-dev-sessions"

# AFTER:
table_prefix = "foretale-app-dynamodb"
name = "foretale-app-dynamodb-sessions"
# Result: "foretale-app-dynamodb-sessions"
```

### Cognito Module
**File:** `terraform/modules/cognito/main.tf`

```terraform
# BEFORE:
name = "${var.project_name}-${var.environment}-pool"
# Result: "foretale-dev-pool"

# AFTER:
name = "foretale-app-cognito-main"
# Result: "foretale-app-cognito-main"
```

### ALB Module
**File:** `terraform/modules/alb/main.tf`

```terraform
# BEFORE:
name = "${var.project_name}-${var.environment}-alb"
# Result: "foretale-dev-alb"

# AFTER:
name = "foretale-app-alb-main"
# Result: "foretale-app-alb-main"
```

### EKS Module
**File:** `terraform/modules/eks/main.tf`

```terraform
# BEFORE:
name_prefix = "${var.project_name}-${var.environment}"
name = "${local.name_prefix}-eks-cluster"
# Result: "foretale-dev-eks-cluster"

# AFTER:
name_prefix = "foretale-app-eks"
name = "foretale-app-eks-cluster"
# Result: "foretale-app-eks-cluster"
```

### Secrets Module
**File:** `terraform/modules/secrets/main.tf`

```terraform
# BEFORE:
name = "dev-url-alb-ecs-services"
name = "dev-pinecone-api"
name = "dev-redis"
# Result: "dev-*" (inconsistent, environment-based)

# AFTER:
name = "foretale-app-alb-ecs-url"
name = "foretale-app-pinecone-api"
name = "foretale-app-redis"
# Result: "foretale-app-*" (unified naming)
```

---

## Migration Path & Testing

### Phase 1: Code Changes (✅ COMPLETE)
- [x] Updated all Terraform modules with new naming
- [x] Created comprehensive naming standard document
- [x] Applied changes across 8+ service modules

### Phase 2: Validation (⏳ NEXT)
- [ ] Run `terraform plan` to validate syntax
- [ ] Review resource naming in plan output
- [ ] Verify backward compatibility

### Phase 3: Deployment
- [ ] Deploy changes to dev account first
- [ ] Validate resources created with new names
- [ ] Deploy to uat and prod accounts
- [ ] Update monitoring/alerting for new names

### Phase 4: Legacy Resource Cleanup
- [ ] Identify existing resources with old naming
- [ ] Create migration plan for critical resources
- [ ] Update references in documentation
- [ ] Update deployment scripts

---

## Documentation Updates

### Created Documents:
1. **UNIFIED_NAMING_STANDARD.md** - Comprehensive naming standard reference
2. **UNIFIED_NAMING_IMPLEMENTATION.md** - This document

### Referenced Documents:
- `NETWORKING_AUDIT_FEB3_2026.md` - Networking compliance report
- `NAMING_CORRECTIONS_COMPLETE.md` - Previous corrections
- `NETWORKING_QUICK_REFERENCE.md` - Network resources reference

---

## Benefits of Unified Naming

### 1. **Consistency**
- All resources follow same pattern
- Easy to identify service type from name
- No confusion about naming conventions

### 2. **Simplicity**
- Single rule for all environments
- No need to remember environment-specific patterns
- Easier to automate and script

### 3. **Scalability**
- Works for unlimited environments/accounts
- Easy to add new services following same pattern
- Reduces naming coordination overhead

### 4. **Compliance**
- Meets industry standards (AWS Well-Architected Framework)
- Professional naming conventions
- Easier for team onboarding

### 5. **Monitoring & Logging**
- Hierarchical CloudWatch logs: `/aws/foretale-app/{service}/{resource}`
- Easier to filter and search logs
- Better organization for dashboards and alerts

---

## Naming Quick Reference

| Service | Pattern | Example |
|---------|---------|---------|
| Lambda | `foretale-app-lambda-{function}` | `foretale-app-lambda-insert-record` |
| RDS | `foretale-app-rds-{resource}` | `foretale-app-rds-main` |
| S3 | `foretale-app-s3-{bucket-type}` | `foretale-app-s3-app-storage` |
| DynamoDB | `foretale-app-dynamodb-{table}` | `foretale-app-dynamodb-sessions` |
| Cognito | `foretale-app-cognito-{resource}` | `foretale-app-cognito-main` |
| ALB | `foretale-app-alb-{purpose}` | `foretale-app-alb-main` |
| EKS | `foretale-app-eks-{resource}` | `foretale-app-eks-cluster` |
| Secrets | `foretale-app-{service}` | `foretale-app-rds-credentials` |
| VPC | `foretale-app-{resource}` | `foretale-app-vpc` |
| Subnets | `foretale-app-{type}-subnet-{az}` | `foretale-app-public-subnet-us-east-2a` |
| SG | `foretale-app-{service}-sg` | `foretale-app-rds-sg` |

---

## Verification Checklist

Before deploying, verify:

- [ ] All Lambda functions start with `foretale-app-lambda-`
- [ ] RDS instance is named `foretale-app-rds-main`
- [ ] S3 buckets follow `foretale-app-s3-*` pattern
- [ ] DynamoDB tables start with `foretale-app-dynamodb-`
- [ ] Cognito pools named `foretale-app-cognito-*`
- [ ] ALB named `foretale-app-alb-*`
- [ ] EKS cluster named `foretale-app-eks-cluster`
- [ ] Secrets Manager secrets follow `foretale-app-*` pattern
- [ ] CloudWatch logs follow `/aws/foretale-app/` hierarchy
- [ ] No environment suffixes (dev, uat, prod) in resource names
- [ ] All resources properly tagged with Environment tag

---

## Questions & Support

For naming convention questions, refer to:
1. **UNIFIED_NAMING_STANDARD.md** - Complete reference
2. **Terraform module files** - Implementation examples
3. **Table above** - Quick lookup

**Key Principle:** Single unified naming across all environments using `foretale-app-{service}-{resource}` pattern.

---

## Summary Statistics

| Category | Count | Status |
|----------|-------|--------|
| **Modules Updated** | 8+ | ✅ Complete |
| **Services Standardized** | 12+ | ✅ Complete |
| **Naming Pattern Applied** | 100% | ✅ Complete |
| **VPC/Network** | 26 resources | ✅ Already Compliant |
| **Lambda Functions** | 6 | ✅ Updated |
| **RDS Resources** | 4 | ✅ Updated |
| **Secrets** | 6 | ✅ Updated |
| **Documentation** | 2 new | ✅ Created |

**Overall Status:** ✅ **IMPLEMENTATION COMPLETE**

All code changes complete and ready for testing and deployment.
