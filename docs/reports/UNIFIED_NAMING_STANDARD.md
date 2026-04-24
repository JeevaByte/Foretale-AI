# ForeTale Unified Naming Convention Standard
**Date:** February 3, 2026  
**Status:** Production Standard - Single Naming Convention for All Environments

---

## Overview

All AWS infrastructure resources across **dev**, **uat**, and **prod** environments follow a **single unified naming convention**. This eliminates the need for separate naming patterns per environment and ensures consistency across all services.

---

## Unified Naming Pattern

### Standard Format:
```
foretale-app-{service}-{resource}[-{descriptor}][-{region-az}]
```

### Components:
- **foretale-app**: Application prefix (consistent across all resources)
- **{service}**: AWS service type (lambda, rds, s3, dynamodb, etc.)
- **{resource}**: Resource specific identifier
- **[{descriptor}]**: Optional descriptive suffix (e.g., insert-record, sessions)
- **[{region-az}]**: Optional AZ suffix for region-specific resources (us-east-2a)

---

## Service-Specific Naming Conventions

### Lambda Functions
```
Pattern: foretale-app-lambda-{function-name}
Examples:
  - foretale-app-lambda-insert-record
  - foretale-app-lambda-update-record
  - foretale-app-lambda-delete-record
  - foretale-app-lambda-read-record
  - foretale-app-lambda-ecs-invoker
```

### RDS Database Instances
```
Pattern: foretale-app-rds-{database-name}
Examples:
  - foretale-app-rds-primary
  - foretale-app-rds-postgresql
  - foretale-app-rds-main
```

### RDS Subnet Groups
```
Pattern: foretale-app-rds-subnet-group
```

### RDS Parameter Groups
```
Pattern: foretale-app-rds-params-pg
```

### S3 Buckets
```
Pattern: foretale-app-s3-{bucket-type}
Examples:
  - foretale-app-s3-app-storage
  - foretale-app-s3-user-uploads
  - foretale-app-s3-vector-store
  - foretale-app-s3-logs
  - foretale-app-s3-terraform-state
```

### DynamoDB Tables
```
Pattern: foretale-app-dynamodb-{table-name}
Examples:
  - foretale-app-dynamodb-sessions
  - foretale-app-dynamodb-chat-history
  - foretale-app-dynamodb-vector-metadata
  - foretale-app-dynamodb-audit-logs
```

### Cognito User Pools
```
Pattern: foretale-app-cognito-{pool-name}
Examples:
  - foretale-app-cognito-main
  - foretale-app-cognito-users
```

### Cognito App Clients
```
Pattern: foretale-app-cognito-client-{purpose}
Examples:
  - foretale-app-cognito-client-web
  - foretale-app-cognito-client-mobile
```

### Application Load Balancer
```
Pattern: foretale-app-alb-{purpose}
Examples:
  - foretale-app-alb-main
  - foretale-app-alb-eks
```

### ALB Target Groups
```
Pattern: foretale-app-tg-{service}
Examples:
  - foretale-app-tg-eks
  - foretale-app-tg-ecs
```

### EKS Clusters
```
Pattern: foretale-app-eks-cluster
```

### EKS Node Groups
```
Pattern: foretale-app-eks-nodes-{az}
Examples:
  - foretale-app-eks-nodes-us-east-2a
  - foretale-app-eks-nodes-us-east-2b
  - foretale-app-eks-nodes-us-east-2c
```

### ECS Clusters
```
Pattern: foretale-app-ecs-{cluster-name}
Examples:
  - foretale-app-ecs-uploads
  - foretale-app-ecs-execute
```

### VPC Resources (Already Compliant)
```
Pattern: foretale-app-{resource-type}[-{descriptor}][-{az}]
Examples:
  - foretale-app-vpc (VPC)
  - foretale-app-public-subnet-us-east-2a
  - foretale-app-private-subnet-us-east-2a
  - foretale-app-database-subnet-us-east-2a
  - foretale-app-igw (Internet Gateway)
  - foretale-app-nat-us-east-2a (NAT Gateway)
  - foretale-app-{service}-sg (Security Groups - Already Compliant)
  - foretale-app-{service}-rt (Route Tables - Already Compliant)
```

### CloudWatch Log Groups
```
Pattern: /aws/foretale-app/{service}/{resource}
Examples:
  - /aws/foretale-app/lambda/insert-record
  - /aws/foretale-app/lambda/update-record
  - /aws/foretale-app/rds/main
  - /aws/foretale-app/eks/cluster
```

### IAM Roles
```
Pattern: foretale-app-{service}-role[-{purpose}]
Examples:
  - foretale-app-lambda-role
  - foretale-app-rds-role
  - foretale-app-eks-cluster-role
  - foretale-app-eks-node-role
  - foretale-app-alb-role
```

### IAM Policies
```
Pattern: foretale-app-{service}-policy[-{purpose}]
Examples:
  - foretale-app-lambda-policy
  - foretale-app-rds-policy
```

### Secrets Manager Secrets
```
Pattern: foretale-app-{service}-{secret-type}
Examples:
  - foretale-app-rds-credentials
  - foretale-app-api-keys
  - foretale-app-oauth-tokens
```

### EventBridge Event Bus
```
Pattern: foretale-app-event-bus
```

### EventBridge Rules
```
Pattern: foretale-app-rule-{event-type}
Examples:
  - foretale-app-rule-user-events
  - foretale-app-rule-project-events
```

### API Gateway APIs
```
Pattern: foretale-app-api-{service}
Examples:
  - foretale-app-api-account-vending
  - foretale-app-api-data
```

### Systems Manager Parameters
```
Pattern: /foretale-app/{service}/{parameter}
Examples:
  - /foretale-app/rds/endpoint
  - /foretale-app/s3/bucket-name
```

### Transit Gateway
```
Pattern: foretale-app-tgw
```

### Transit Gateway Attachments
```
Pattern: foretale-app-tgw-attachment-{resource}
Examples:
  - foretale-app-tgw-attachment-vpc
```

---

## Environment Handling

### IMPORTANT: No Environment Suffix
- **Do NOT** use `-dev`, `-uat`, `-prod` suffixes
- All environments use the same naming pattern
- Environment differentiation is handled via:
  - AWS Account structure (separate AWS accounts per environment)
  - Terraform variables and workspace isolation
  - Tags (Environment tag = dev/uat/prod)

### Example:
```
Dev Environment:   foretale-app-rds-main (in DEV AWS account)
UAT Environment:   foretale-app-rds-main (in UAT AWS account)
Prod Environment:  foretale-app-rds-main (in PROD AWS account)

Not: foretale-dev-rds-main, foretale-uat-rds-main, foretale-prod-rds-main
```

---

## Tagging Standard

All resources must include the following tags:

```terraform
tags = {
  Application   = "foretale-app"
  Environment   = var.environment  # dev/uat/prod
  CostCenter    = var.cost_center
  Owner         = var.owner
  CreatedDate   = var.created_date
  Terraform     = "true"
  NameStandard  = "foretale-app-unified-v1"
}
```

---

## Implementation Guidelines

### 1. Terraform Variable
All modules should reference a naming prefix:
```terraform
locals {
  name_prefix = "foretale-app"
  full_name_prefix = "${local.name_prefix}-{service}"
}
```

### 2. CloudWatch Log Groups
```terraform
# Use hierarchical path structure
name = "/aws/foretale-app/{service}/{resource}"
```

### 3. Database Names
```terraform
# Instance identifier
db_instance_class = "foretale-app-rds-{type}"

# Database names within instance
database_name = "foretale_app_db"
```

### 4. Bucket Names
```terraform
# S3 buckets use lowercase with hyphens
bucket = "foretale-app-s3-{purpose}"

# Global uniqueness: Add account ID if needed
bucket = "foretale-app-s3-${var.aws_account_id}-{purpose}"
```

---

## Naming Compliance Checklist

Before deploying resources, verify:

- [ ] All resources use `foretale-app-` prefix
- [ ] Service type is clearly identified (`-lambda-`, `-rds-`, `-s3-`, etc.)
- [ ] No environment suffixes (`-dev`, `-uat`, `-prod`) in names
- [ ] Descriptive identifiers are lowercase with hyphens
- [ ] No underscores in resource names (hyphens only, except where AWS requires)
- [ ] CloudWatch logs follow `/aws/foretale-app/` hierarchy
- [ ] S3 buckets are globally unique and comply with AWS requirements
- [ ] All resources tagged with required metadata
- [ ] Documentation reflects the naming convention

---

## Related Documents

- [NETWORKING_AUDIT_FEB3_2026.md](NETWORKING_AUDIT_FEB3_2026.md) - Networking resource verification
- [NAMING_CORRECTIONS_COMPLETE.md](NAMING_CORRECTIONS_COMPLETE.md) - Completed corrections report
- [NETWORKING_QUICK_REFERENCE.md](NETWORKING_QUICK_REFERENCE.md) - Network component reference

---

## Migration Path

### Phase 1: Completed (Feb 3, 2026)
✅ VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway - All compliant
✅ Security Groups (8/8) - Renamed to foretale-app-* pattern
✅ VPC Endpoints (3/3) - Already compliant

### Phase 2: In Progress
⏳ Lambda Functions - Update naming pattern
⏳ RDS Database - Update naming pattern  
⏳ S3 Buckets - Update naming pattern
⏳ DynamoDB - Update naming pattern
⏳ Cognito - Update naming pattern
⏳ ALB/Target Groups - Update naming pattern
⏳ EKS - Update naming pattern
⏳ Other Services - Update naming pattern

### Phase 3: Future
- Update Terraform code references
- Update deployment scripts
- Update documentation
- Rename existing resources in AWS

---

## Questions & Support

For naming convention clarifications, refer to this standard document and ensure all new resources follow the pattern:
```
foretale-app-{service}-{resource}[-{descriptor}][-{region-az}]
```

**No environment suffixes. Single unified naming across all environments.**
