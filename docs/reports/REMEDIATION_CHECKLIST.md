# Infrastructure Validation - Remediation Checklist

**Generated:** February 12, 2026  
**Priority:** Address Critical + High items before production release

---

## 🔴 CRITICAL REMEDIATION ITEMS

### Item 1: Verify & Fix Lambda Handler Entry Points

**Status:** ❌ BLOCKED - Requires Code Verification  
**Severity:** CRITICAL  
**Risk:** Lambda functions will not execute if handlers don't match code structure

#### Root Cause
```
Source Entry Point:  lambda_function.lambda_handler
Deployed Entry Point: index.lambda_handler
```
The Terraform deployment changed the handler path, but actual Lambda package code might not match.

#### Remediation Steps

```bash
# Step 1: Get current Lambda package and extract
aws lambda get-function --function-name ecs-task-invoker --region us-east-2 \
  --query 'Code.Location' --output text > function-url.txt

# Step 2: Check actual Python file structure
# Look for:
#   - index.py with lambda_handler() function
#   - OR lambda_function.py with lambda_handler() function

# Step 3a: If code uses lambda_function.py, update Terraform
#   In /infrastructure/terraform/modules/lambda/main.tf line ~150:
#   Change: handler = "index.lambda_handler"
#   To:     handler = "lambda_function.lambda_handler"

# Step 3b: If code uses index.py, verify it's in package root
#   Ensure /src/handlers/index.py is properly packaged

# Step 4: Re-deploy via Terraform
cd /infrastructure/terraform
terraform plan -target=module.lambda
terraform apply -target=module.lambda
```

#### Validation
```bash
# Test handler invocation
aws lambda invoke \
  --function-name ecs-task-invoker \
  --region us-east-2 \
  --invocation-type RequestResponse \
  --payload '{}' \
  /tmp/test-response.json

# Expected: HTTP 200, valid response (not execution error)
```

#### Owner: DevOps  
#### Timeline: 1-2 hours  
#### Dependency: Code review required

---

### Item 2: Deploy Missing Private API Gateway

**Status:** ❌ NOT DEPLOYED  
**Severity:** CRITICAL  
**Risk:** Internal SQL procedure API not accessible

#### Root Cause
`api-sql-procedure-invoker-private` exists in us-east-1 but not replicated in us-east-2

#### Remediation Steps

**Option A: Terraform Deployment** (Preferred)
```bash
# Step 1: Source private API configuration from us-east-1
aws apigateway get-rest-api --rest-api-id uq56kj6m5f --region us-east-1

# Step 2: Create Terraform configuration for private API
# In /infrastructure/terraform/modules/api_gateway/main.tf, add:
resource "aws_api_gateway_rest_api" "sql_procedure_private" {
  name         = "api-sql-procedure-invoker-private"
  description  = "An API to invoke the SQL Server procedure from internal services"
  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

# Step 3: Deploy
terraform apply -target=module.api_gateway.aws_api_gateway_rest_api.sql_procedure_private

# Step 4: Create methods and integrations
# Reference: Source region API structure for parity
```

**Option B: Manual Recreation** (If Terraform config unavailable)
```bash
# Create REST API
aws apigateway create-rest-api \
  --name api-sql-procedure-invoker-private \
  --description "An API to invoke the SQL Server procedure from internal services" \
  --endpoint-configuration types=PRIVATE \
  --region us-east-2

# Note API ID: <API_ID>

# Query source region for methods/integrations
aws apigateway get-resources --rest-api-id uq56kj6m5f --region us-east-1
aws apigateway get-method --rest-api-id uq56kj6m5f --resource-id <RES_ID> \
  --http-method POST --region us-east-1
```

#### Validation
```bash
# Test private API
aws apigateway test-invoke-method \
  --rest-api-id <NEW_API_ID> \
  --resource-id / \
  --http-method POST \
  --region us-east-2
```

#### Owner: Infrastructure  
#### Timeline: 1-2 hours  
#### Dependency: Terraform configuration must exist

---

### Item 3: Enable Multi-AZ for RDS Instances

**Status:** ❌ SINGLE AZ ONLY  
**Severity:** CRITICAL  
**Risk:** No automatic failover; complete data loss if AZ fails

#### Root Cause
RDS instances provisioned in single AZ without Multi-AZ replication

#### Remediation Steps - foretale-app-rds-main

```bash
# Step 1: Check current configuration
aws rds describe-db-instances \
  --db-instance-identifier foretale-app-rds-main \
  --region us-east-2 \
  --query 'DBInstances[0].[DBInstanceClass,Engine,AllocatedStorage,MultiAZ,AvailabilityZone]'

# Expected: db.t3.micro, postgres, 20, False, us-east-2a/b/c

# Step 2: Enable Multi-AZ (requires 10-30 minutes downtime)
aws rds modify-db-instance \
  --db-instance-identifier foretale-app-rds-main \
  --multi-az \
  --apply-immediately \
  --region us-east-2

# Step 3: Monitor progress
while true; do
  STATUS=$(aws rds describe-db-instances \
    --db-instance-identifier foretale-app-rds-main \
    --region us-east-2 \
    --query 'DBInstances[0].DBInstanceStatus' \
    --output text)
  echo "Status: $STATUS"
  if [ "$STATUS" = "available" ]; then
    MULTI_AZ=$(aws rds describe-db-instances \
      --db-instance-identifier foretale-app-rds-main \
      --region us-east-2 \
      --query 'DBInstances[0].MultiAZ' \
      --output text)
    echo "Multi-AZ enabled: $MULTI_AZ"
    break
  fi
  sleep 30
done
```

#### Remediation Steps - hexango-standard-vpc0bb9

```bash
# Repeat same process for SQL Server instance
aws rds modify-db-instance \
  --db-instance-identifier hexango-standard-vpc0bb9 \
  --multi-az \
  --apply-immediately \
  --region us-east-2
```

#### Validation Post-Deployment
```bash
# Verify Multi-AZ enabled
aws rds describe-db-instances \
  --db-instance-identifier foretale-app-rds-main \
  --region us-east-2 \
  --query 'DBInstances[0].[DBInstanceIdentifier,MultiAZ,SecondaryAvailabilityZone]' \
  --output table

# Expected:
# foretale-app-rds-main  |  True  |  us-east-2b (different from primary)
```

#### Owner: Database Team  
#### Timeline: 1-2 hours per instance (requires maintenance window)  
#### Risk: 10-30 min downtime per instance

---

## 🟡 HIGH-PRIORITY REMEDIATION ITEMS

### Item 4: Extend RDS Backup Retention

**Status:** ⚠️ BELOW MINIMUM  
**Severity:** HIGH  
**Current:** 1-7 days | **Target:** 30 days minimum

#### Root Cause
Backup retention configured below production requirements

#### Remediation Step

```bash
# Update all RDS instances to 30-day retention
for instance in foretale-app-rds-main hexango-standard-vpc0bb9; do
  aws rds modify-db-instance \
    --db-instance-identifier $instance \
    --backup-retention-period 30 \
    --region us-east-2
done

# Verify
aws rds describe-db-instances \
  --region us-east-2 \
  --query 'DBInstances[*].[DBInstanceIdentifier,BackupRetentionPeriod]' \
  --output table
```

#### Owner: Database/DevOps  
#### Timeline: 15 minutes  
#### Risk: No downtime, applies immediately

---

### Item 5: Verify Lambda Layer Versions

**Status:** ⚠️ VERSION MISMATCH  
**Severity:** HIGH  
**Risk:** Dependency resolution failures at runtime

#### Layer Version Comparison

| Layer | Source (us-east-1) | Target (us-east-2) | Status |
|-------|---|---|---|
| layer-db-utils | v10 | v1 | ⚠️ MISMATCH |
| pyodbc-layer-prebuilt | v1 | v3 | ⚠️ MISMATCH |
| psycopg2-layer | Not present | v2 | ✅ NEW |

#### Remediation Steps

```bash
# Step 1: Test current layers with real Lambda invocation
aws lambda invoke \
  --function-name calling-sql-procedure \
  --region us-east-2 \
  --invocation-type RequestResponse \
  --payload '{"action":"test"}' \
  /tmp/layer-test.json

# Step 2: Check CloudWatch logs for import errors
aws logs tail /aws/lambda/calling-sql-procedure \
  --region us-east-2 \
  --follow

# Step 3a: If errors found, update Terraform
#   In /infrastructure/terraform/modules/lambda/main.tf:
#   Update layers block to use v10 and v1 (matching source)

# Step 3b: If no errors, document that newer versions are compatible
#   Update confluence/wiki with layer version compatibility notes
```

#### Owner: Development/DevOps  
#### Timeline: 1-2 hours (includes testing)

---

### Item 6: Audit IAM Role Permissions

**Status:** ⚠️ CONSOLIDATED, NEEDS AUDIT  
**Severity:** MEDIUM-HIGH  
**Risk:** Over-permissioned role may violate least-privilege principle

#### Current State
```
Source (us-east-1):  3 individual Lambda roles per function
  ├─ ecs-task-invoker-role-eq44ntlp
  ├─ calling-sql-procedure-role-2gcn7tlr
  └─ sql-server-data-upload-role-q2a72wkk

Target (us-east-2):  1 consolidated role for all
  └─ foretale-dev-lambda-execution-role
```

#### Remediation Steps

```bash
# Step 1: Export role policies
aws iam get-role-policy \
  --role-name foretale-dev-lambda-execution-role \
  --policy-name foretale-dev-lambda-policy \
  --region us-east-2 | jq '.RolePolicyDocument'

# Step 2: Check attached managed policies
aws iam list-attached-role-policies \
  --role-name foretale-dev-lambda-execution-role

# Step 3: Audit for wildcards and excessive permissions
# Look for:
#   - Action: "*"
#   - Resource: "*"
#   - Effect: "Allow" without restrictions

# Step 4a: If wildcards exist, create least-privilege policy
# Step 4b: If compliant, document audit result

# Step 5: Compare with source region roles if needed
aws iam get-role-policy \
  --role-name ecs-task-invoker-role-eq44ntlp \
  --policy-name EcsTaskInvokerPolicy \
  --region us-east-1
```

#### Owner: Security/DevOps  
#### Timeline: 2-3 hours (includes review)

---

## 🟢 MEDIUM-PRIORITY ITEMS

### Item 7: Rename API Gateway Stages for Clarity

**Status:** ⚠️ CONFUSING NAMING  
**Severity:** MEDIUM

#### Root Cause
Development environment using "prod" stage name (misleading)

#### Change Required
```
Current (Confusing):   api-ecs-task-invoker/prod
Target (Clear):       api-ecs-task-invoker/dev
```

#### Remediation

```bash
# Option A: Update stage name (breaking change)
aws apigateway update-stage \
  --rest-api-id 6pz582qld4 \
  --stage-name prod \
  --patch-operations op=replace,path=/stageName,value=dev \
  --region us-east-2

# Option B: Create new stage and migrate (non-breaking)
aws apigateway create-stage \
  --rest-api-id 6pz582qld4 \
  --stage-name dev \
  --deployment-id $(aws apigateway get-deployments \
    --rest-api-id 6pz582qld4 \
    --region us-east-2 \
    --query 'items[0].id' \
    --output text) \
  --region us-east-2
```

#### Owner: DevOps  
#### Timeline: 30 minutes  
#### Risk: API endpoint URL changes (requires client updates)

---

### Item 8: Document Handler Path Migration

**Status:** ⚠️ UNDOCUMENTED  
**Severity:** MEDIUM

#### Action: Create migration guide

```markdown
# Lambda Handler Path Migration (us-east-1 → us-east-2)

## Changes
- Source entry point: lambda_function.lambda_handler
- Target entry point: index.lambda_handler

## Affected Functions
- ecs-task-invoker
- calling-sql-procedure
- sql-server-data-upload

## Code Structure Changes
Original:
  src/
  └─ lambda_function.py (contains lambda_handler function)

Migrated:
  src/
  └─ index.py (contains lambda_handler function)

## Verification
Run: aws lambda invoke --function-name ecs-task-invoker ...
Expected: HTTPStatusCode 200

## Rollback
If handler mismatch detected:
1. Restore old Lambda code
2. Revert Terraform handler config
3. Re-deploy via terraform apply
```

#### Owner: DevOps/Development  
#### Timeline: 1 hour

---

## 🔵 LOW-PRIORITY ITEMS

### Item 9: Clean Up Orphaned VPCs

**Status:** ❌ PENDING  
**Severity:** LOW

#### VPCs to Delete

1. **vpc-0aef39d92ca9cb3f9** (foretale-prod-vpc)
   - Status: Empty, unused
   - Risk: Safe to delete
   ```bash
   aws ec2 delete-vpc --vpc-id vpc-0aef39d92ca9cb3f9 --region us-east-2
   ```

2. **vpc-0de30b9415bf1b730** (default VPC)
   - Status: RDS migrated, cleanup in progress
   - Risk: Deferred (may have dependencies)
   ```bash
   # After ensuring no resources use this VPC
   aws ec2 delete-vpc --vpc-id vpc-0de30b9415bf1b730 --region us-east-2
   ```

#### Owner: DevOps  
#### Timeline: 30 minutes  
#### Risk: None (confirmed orphaned)

---

### Item 10: Review & Optimize RDS Instance Classes

**Status:** ⚠️ MAY BE UNDERSIZED  
**Severity:** LOW

#### Current Classes
- foretale-app-rds-main: **db.t3.micro** (1 vCPU, 1 GB RAM)
- langgraph: **db.t4g.micro** (2 vCPU, 1 GB RAM)

#### Recommendation
Consider **db.t3.small** (1 vCPU, 2 GB RAM) for production if:
- Application observing CPU throttling
- Memory usage above 80%
- Burst balance frequently empty

#### Validation
```bash
# Monitor CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=foretale-app-rds-main \
  --start-time 2026-02-05T00:00:00Z \
  --end-time 2026-02-12T00:00:00Z \
  --period 3600 \
  --statistics Average,Maximum \
  --region us-east-2

# If Average > 30% or Maximum > 70%, consider upgrade
```

#### Owner: Database Team  
#### Timeline: 2 hours (if scaling needed)

---

## Quick-Reference Remediation Order

```
DAY 1 (CRITICAL):
  [ ] Item 1: Verify Lambda handlers (1-2 hrs)
  [ ] Item 2: Deploy private API (1-2 hrs)  
  [ ] Item 3: Enable Multi-AZ RDS (2-4 hrs, 2x instances)
  [ ] Item 4: Extend backup retention (15 min)

DAY 2 (HIGH):
  [ ] Item 5: Verify layer versions (1-2 hrs testing)
  [ ] Item 6: Audit IAM permissions (2-3 hrs)
  [ ] Item 7: Rename API stages (30 min)

WEEK 1 (MEDIUM):
  [ ] Item 8: Document migration (1 hr)
  [ ] Item 9: Delete orphaned VPCs (30 min)
  [ ] Item 10: Optimize RDS classes (2 hrs if needed)

TOTAL ESTIMATED TIME: 12-18 hours
```

---

## Sign-Off Tracking

| Item | Status | Owner | Due Date | Sign-Off |
|------|--------|-------|----------|----------|
| 1. Handler verification | 🔴 BLOCKED | DevOps | 2026-02-13 | ___ |
| 2. Private API | ❌ NOT STARTED | Infra | 2026-02-13 | ___ |
| 3. Multi-AZ RDS | ❌ NOT STARTED | DBA | 2026-02-13 | ___ |
| 4. Backup retention | ❌ NOT STARTED | DevOps | 2026-02-13 | ___ |
| 5. Layer versions | ❌ NOT STARTED | Dev | 2026-02-14 | ___ |
| 6. IAM audit | ❌ NOT STARTED | Security | 2026-02-14 | ___ |
| 7. Stage naming | ❌ NOT STARTED | DevOps | 2026-02-14 | ___ |
| 8. Documentation | ❌ NOT STARTED | DevOps | 2026-02-14 | ___ |
| 9. VPC cleanup | ❌ NOT STARTED | DevOps | 2026-02-15 | ___ |
| 10. RDS optimization | ⏳ MONITOR | DBA | 2026-02-15 | ___ |

---

**Generated:** 2026-02-12  
**Next Review:** Upon completion of all critical items  
**Contact:** Infrastructure Team
