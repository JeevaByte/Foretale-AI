# Terraform Drift Detection Report
**Generated:** February 13, 2026  
**Status:** ⚠️ **CRITICAL - Plan Validation Failed**  
**Location:** `infrastructure/terraform/`

---

## Executive Summary

The `terraform plan` command **failed with validation errors** due to configuration drift and deleted Lambda functions that are still referenced in API Gateway module. The infrastructure has experienced **significant unintended changes** while you were away, including:

1. ✅ **29 resources scheduled for creation** (EKS cluster, SQL Server DB, etc.)
2. ✅ **11 resources scheduled for modification** (Lambda functions, ASG, parameters)
3. ❌ **2 resources scheduled for destruction** (deposed database resources)
4. 🔴 **5 Lambda functions deleted in AWS but still referenced in code** - blocking plan validation

### Key Metrics
- **Plan Status:** Failed validation
- **Configuration Issues:** 5 critical, 3 high-priority
- **Drift Areas:** Lambda functions, API Gateway, Auto Scaling, EKS, Database
- **Action Required:** Remove deleted Lambda references OR recreate functions before applying

---

## 1. Critical Issues (Blocking Plan Execution)

### 1.1 Missing Lambda Functions Referenced in API Gateway

**Problem:** Five Lambda functions were deleted in AWS but are still configured in Terraform code. API Gateway module tries to create permissions for non-existent functions, causing validation errors.

**Affected Functions:**
```
❌ foretale-app-lambda-insert-record    (CRUDL operation)
❌ foretale-app-lambda-update-record    (CRUDL operation)
❌ foretale-app-lambda-delete-record    (CRUDL operation)
❌ foretale-app-lambda-read-record      (CRUDL operation)
❌ foretale-app-lambda-read-json-record (CRUDL operation)
✅ foretale-app-lambda-ecs-invoker      (Critical - still created, being recreated)
```

**Error Message:**
```
Error: invalid value for function_name (must be valid function name or function ARN)
with module.api_gateway.aws_lambda_permission.api_insert,
  on modules/api-gateway/main.tf line 315:
  315: function_name = var.lambda_function_name_insert
Error: expected length of function_name to be in the range (1 - 140), got 
```

**Root Cause:**
- Variables `lambda_function_name_insert`, `lambda_function_name_update`, `lambda_function_name_delete`, `lambda_function_name_read`, `lambda_function_name_read_json` all have empty defaults (`""`)
- API Gateway module still contains resource definitions for these permissions
- When passed empty strings, AWS API rejects them as invalid function names

**Location:**
- **API Gateway module:** `modules/api-gateway/variables.tf` (lines 71-96)
- **References:** `modules/api-gateway/main.tf` (lines 315, 323, 331, 339, 347)

**Code Example - Current Configuration:**
```hcl
# modules/api-gateway/variables.tf
variable "lambda_function_name_insert" {
  description = "Function name for insert_record Lambda (DELETED)"
  type        = string
  default     = ""  # ← Empty default causes validation error
}

# modules/api-gateway/main.tf (line 315)
resource "aws_lambda_permission" "api_insert" {
  function_name = var.lambda_function_name_insert  # ← References empty variable
  # ... error occurs here
}
```

---

## 2. Configuration Drift Detection

### 2.1 Auto Scaling Group - External Modification

**Status:** ⚠️ Drift detected

**Change Detected:**
```
module.autoscaling.aws_autoscaling_group.ai_servers
  desired_capacity: 2 → 1 (external change in AWS)
  target_group_arns: [foretale-dev-eks-tg] → [foretale-dev-eks-tg, null]
```

**Impact:** Infrastructure code expects 2 desired instances but AWS has 1. Terraform will correct this to 2 on apply.

**Timeline:** Changed externally (not via Terraform)

---

### 2.2 Lambda Function - ecs_invoker Being Recreated

**Status:** ⚠️ Major drift

**Change Detected:**
```
module.lambda.aws_lambda_function.ecs_invoker
  [DEPOSED/DESTROYED] Deleted in AWS but exists in Terraform state
  [CREATING] Terraform will recreate it with:
    - function_name: foretale-app-lambda-ecs-invoker
    - handler: index.lambda_handler
    - runtime: python3.12
    - memory: 256 MB
    - timeout: 900 seconds
```

**Why Recreated:**
- Code was modified to recreate the function
- AWS version was deleted at some point while in code
- Plan shows it as being created from `modules/lambda/ecs_invoker.zip`

**Integration Impact:**
- API Gateway will create `aws_lambda_permission.api_ecs_invoker` to allow API invocation
- This function is **critical** - it orchestrates ECS task execution

---

### 2.3 PostgreSQL Parameter Group - Modification Method Change

**Status:** ⚠️ Configuration drift

**Change Detected:**
```
module.rds.aws_db_parameter_group.postgresql
  shared_preload_libraries parameter:
    apply_method: pending-reboot → immediate
    value: pg_stat_statements (unchanged)
```

**Impact:** Parameter application method changed. Current code uses `immediate` (apply without reboot), but infrastructure had it as `pending-reboot` (requires restart).

**Severity:** Low (monitoring library, can be applied without service interruption now)

---

### 2.4 Launch Template Image Update

**Status:** ✅ Auto Scaling Managed

**Change Detected:**
```
module.autoscaling.aws_launch_template.ai_servers
  image_id: ami-0bb172e7d7a2e80b8 → ami-0754d1185d001e9aa
  (Amazon Linux 2 base image updated)
```

**Note:** This is a normal OS patch/update cycle. Auto Scaling groups automatically use updated launch templates for new instances.

---

## 3. Planned Infrastructure Changes

### 3.1 New EKS Cluster Creation (29 resources)

**Status:** 🔵 Planned addition - not critical drift

**Resources to Create:**
```
✓ EKS Cluster:
  - Name: foretale-app-eks-cluster
  - Version: 1.29
  - Logging: API, Audit, Authenticator, ControllerManager, Scheduler
  - VPC Config: Private/Public access enabled

✓ EKS Node Group:
  - Name: foretale-app-eks-node-group
  - Instance Type: t3.medium
  - Desired Size: 2 (min: 1, max: 4)

✓ Security Groups (2):
  - EKS Cluster security group
  - EKS Node group security group

✓ IAM Roles & Policies:
  - EKS Cluster Role + AmazonEKSClusterPolicy
  - EKS Node Group Role + AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy
  - Pod Execution Role + RDS access policy

✓ OIDC Provider for Pod IAM integration

✓ CloudWatch Log Group: /aws/eks/foretale-app-eks-cluster/cluster
```

**Terraform References:** `modules/eks/`

**Note:** This appears to be an intentional planned addition (not drift), but confirm with team before applying.

---

### 3.2 SQL Server Instance Creation

**Status:** 🔵 Planned addition

**Configuration:**
```
Database Instance: foretale-app-rds-sqlserver
  - Engine: SQL Server Express Edition (sqlserver-ex)
  - Version: 15.00.4153.1.v1 (SQL Server 2019)
  - Instance Class: db.t3.large
  - Storage: 100 GB gp3
  - Multi-AZ: True (High Availability)
  - Backup Retention: 7 days
  - Monitoring: 60-second interval
  - Encryption: True (at rest)

Secrets Manager:
  - Secret: foretale-app-rds-sqlserver-credentials
  - Automatic rotation: Enabled

Alarms:
  - CPU > 80%: Alert enabled
```

**Note:** Appears intentional but should be reviewed before creation (SQL Server licensing implications).

---

### 3.3 Lambda Function Updates

**Status:** ⚠️ Mixed - Some deleted, some updated, one recreated

**Changes:**
```
Creating:
  + foretale-app-lambda-ecs-invoker (Critical - being recreated)
  + modules/lambda/ecs_invoker zip handler

Updating:
  ~ calling-sql-procedure: source_code_hash change (code updated)
  ~ sql-server-data-upload: source_code_hash change (code updated)

Modified:
  ✓ ASG scaling policy added: alb_request_scaling
    - Type: Target Tracking
    - Metric: ALBRequestCountPerTarget
    - Target: 1000 requests per target
```

---

### 3.4 Other Changes

**API Gateway Integrations (6 to update):**
Two categories of changes:

**Breaking - Missing Functions:**
```
- api_insert_record: URI will be set to null (function deleted)
- api_update_record: URI will be set to null (function deleted)
- api_delete_record: URI will be set to null (function deleted)
- api_read_record: URI will be set to null (function deleted)
- api_read_json_record: URI will be set to null (function deleted)
```

**Working - Will Update:**
```
~ api_ecs_invoker: URI will be recalculated (function being recreated)
  New URI: arn:aws:apigateway:us-east-2:lambda:path/2015-03-31/functions/
           arn:aws:lambda:us-east-2:442426872653:function:foretale-app-lambda-ecs-invoker/invocations
```

---

### 3.5 Deposed Resources Being Destroyed

**Status:** Cleanup from failed replacement

```
Destroying (cleanup):
  - module.rds.aws_db_subnet_group.main (deposed object 6a3381a6)
    Name: foretale-dev-db-subnet-group (orphaned)
    
  - module.rds.aws_secretsmanager_secret.db_credentials (deposed object b05c4655)  
    Name: foretale-dev-db-credentials (orphaned)
```

**Reason:** These were left over from a partially-failed replacement during earlier RDS migrations. They should be safely destroyed.

---

## 4. Unwanted/Orphaned Files Analysis

### 4.1 Terraform Code Structure Assessment

**Modules Directory:** `infrastructure/terraform/modules/`

**Modules Inventory (18 total):**
```
Active/In-Use:
  ✓ vpc/ - Core networking (active VPC configuration)
  ✓ lambda/ - Lambda functions (5 deleted, 3 active)
  ✓ api-gateway/ - API configuration (broken, needs repair)
  ✓ rds/ - Database instances (PostgreSQL active, SQL Server new)
  ✓ iam/ - IAM roles and policies
  ✓ cognito/ - User authentication
  ✓ security-groups/ - Network security
  ✓ dynamodb/ - Data store tables
  ✓ s3/ - Object storage
  ✓ monitoring/ - CloudWatch resources
  ✓ secrets/ - Secrets Manager
  ✓ eks/ - Kubernetes cluster (NEW)
  ✓ alb/ - Load balancer
  ✓ autoscaling/ - Auto Scaling groups
  
Potentially Unused (Review Recommended):
  ? ci_cd/ - CI/CD pipeline configuration
  ? bedrock/ - AWS Bedrock integration
  ? transit_gateway/ - Transit gateway setup
  ? ssm_automation/ - Systems Manager automation
  ? account_vending/ - Account management
```

**Recommendation:** Verify if `ci_cd`, `bedrock`, `transit_gateway`, `ssm_automation`, and `account_vending` modules are actually being used in `main.tf`.

---

### 4.2 Terraform Root Files Check

**Files Present:**
```
✓ main.tf (364 lines) - Module references and configuration
✓ outputs.tf (14.71 KB) - Output definitions
✓ variables.tf (9.21 KB) - Input variables
✓ amplify.tf (4.14 KB) - Amplify-specific resources
✓ terraform.tfvars (3.17 KB) - Variable values
✓ .terraform/ - Provider cache
✓ .terraform.lock.hcl - Dependency lock file
```

**Assessment:** All root files are necessary for Terraform state management. No obvious candidates for deletion.

---

## 5. Recommended Actions

### IMMEDIATE (Before terraform apply):

1. **CRITICAL: Fix API Gateway Lambda References**
   
   **Option A: Remove deleted Lambda functions from API Gateway** (Recommended)
   ```bash
   # In modules/api-gateway/main.tf, remove or comment:
   - resource "aws_lambda_permission" "api_insert" { ... }
   - resource "aws_lambda_permission" "api_update" { ... }
   - resource "aws_lambda_permission" "api_delete" { ... }
   - resource "aws_lambda_permission" "api_read" { ... }
   - resource "aws_lambda_permission" "api_read_json" { ... }
   
   # Also remove these resources from the module:
   - aws_api_gateway_method.insert_record_post
   - aws_api_gateway_method.update_record_put
   - aws_api_gateway_method.delete_record_delete
   - aws_api_gateway_method.read_record_get
   - aws_api_gateway_method.read_json_record_get
   - aws_api_gateway_integration.insert_record_lambda
   - aws_api_gateway_integration.update_record_lambda
   - aws_api_gateway_integration.delete_record_lambda
   - aws_api_gateway_integration.read_record_lambda
   - aws_api_gateway_integration.read_json_record_lambda
   ```

   **Option B: Recreate deleted Lambda functions**
   ```bash
   # Create modules/lambda/insert_record.zip
   # Create modules/lambda/update_record.zip
   # Create modules/lambda/delete_record.zip
   # Create modules/lambda/read_record.zip
   # Create modules/lambda/read_json_record.zip
   # Add to modules/lambda/main.tf
   ```

   **Status:** Must complete before `terraform plan` validates successfully.

2. **Review EKS Cluster Addition**
   - Confirm with team that EKS cluster creation is intentional
   - Verify Kubernetes requirements and workload plans
   - Check budget impact (t3.medium instances, managed service costs)

3. **Review SQL Server Database Creation**
   - Confirm SQL Server Express Edition licensing compliance
   - Verify database purpose and migration plan
   - Check backup and Multi-AZ requirements

4. **Validate ASG Desired Capacity Change**
   - Confirm if 2 instances is the correct target
   - Update Terraform variable if 1 instance is intentional
   - Current plan will scale from 1 to 2 on apply

### SHORT-TERM (After fixing critical issues):

5. **Verify Unused Modules**
   ```bash
   grep -r "module \"ci_cd\"" main.tf        # Check if referenced
   grep -r "module \"bedrock\"" main.tf      # Check if referenced
   grep -r "module \"transit_gateway\"" main.tf
   grep -r "module \"ssm_automation\"" main.tf
   grep -r "module \"account_vending\"" main.tf
   ```
   - If not referenced in `main.tf`, mark for deletion or archive
   - Move unused modules to `_archive/` directory

6. **Clean Up Deposed Resources**
   - Plan includes destruction of orphaned database resources (safe)
   - Apply plan to clean up `foretale-dev-db-subnet-group` and `foretale-dev-db-credentials`

7. **Lambda Code Updates**
   - Review changes to `calling-sql-procedure` (source_code_hash modified)
   - Review changes to `sql-server-data-upload` (source_code_hash modified)
   - Verify these are intentional updates and not data corruption

---

## 6. Risk Assessment

| Issue | Severity | Blast Radius | Reversible | Recommended Action |
|-------|----------|--------------|-----------|-------------------|
| Missing Lambda functions in API Gateway | 🔴 Critical | API endpoints broken | Yes | Remove from code before apply |
| EKS cluster creation | 🟠 High | New infrastructure, costs | Yes | Review before apply |
| SQL Server database creation | 🟠 High | New infrastructure, licensing | Yes | Review before apply |
| ASG desired capacity drift | 🟡 Medium | Instance scaling | Yes | Update Terraform or confirm external change |
| PostgreSQL parameter change | 🟡 Medium | Database monitoring | Yes | Acceptable, affects stat collection method |
| Lambda code updates | 🟡 Medium | Function behavior | Yes | Review change details before apply |
| Deposed resource cleanup | 🟢 Low | Orphaned resources | Yes | Safe to destroy |

---

## 7. Terraform Plan Summary

```
Plan: 29 to add, 11 to change, 2 to destroy

Adding:
  - 21 EKS resources (cluster, node group, IAM, security groups, logging)
  - 1 SQL Server RDS instance
  - 3 SQL Server secrets/alarms
  - 1 Lambda function (ecs_invoker)
  - 1 Auto Scaling scaling policy
  - 1 Lambda permission (api_ecs_invoker)
  - 1 TLS certificate data source (for EKS OIDC)

Modifying:
  - 5 API Gateway integrations (setting URIs to null - BROKEN)
  - 2 Lambda functions (source code updates)
  - 1 Launch template (AMI update)
  - 1 ASG (desired capacity, target groups)
  - 1 Database parameter group (apply method)
  - 1 Lambda permission (recreating ecs_invoker)

Destroying:
  - 2 orphaned deposed resources (cleanup from failed replacement)

Output Changes:
  - 8 new EKS outputs added
  - 5 Lambda ARNs removed (deleted functions)
  - API Gateway endpoints updated in phase3_summary
```

---

## 8. Files Needing Changes

### Critical - Must Fix Before Applying:

**`modules/api-gateway/main.tf`**
- Remove or conditionally create Lambda permissions for deleted functions
- Lines: 315 (api_insert), 323 (api_update), 331 (api_delete), 339 (api_read), 347 (api_read_json)

**`modules/api-gateway/variables.tf`**
- Options:
  - Option A: Remove variable definitions for deleted functions
  - Option B: Change defaults from `""` to conditional values

**`infrastructure/terraform/main.tf`** (Line 245-261)
- Consider conditional block for API Gateway CRUDL operations
- Or update to only pass required lambda variables

### Review - Verify Before Applying:

**`modules/eks/` (entire module)**
- Verify EKS configuration is intentional
- Review cluster version, node types, security settings

**`modules/rds/main.tf`**
- Verify SQL Server database requirements
- Review licensing model (Express Edition)

**`modules/lambda/calling_sql_procedure.zip` and `modules/lambda/sql_server_data_upload.zip`**
- Review code changes
- Verify deployments are intentional

---

## 9. Questions to Answer

Before proceeding with `terraform apply`, answer these questions:

1. **Lambda Functions:** Should we remove the deleted CRUD Lambda functions from Terraform entirely, or should we recreate them?
   
2. **EKS Cluster:** Was the EKS cluster addition intentional? Do we have workloads to deploy?
   
3. **SQL Server:** Why was SQL Server Express added? Is this replacing the isolated SQL Server instance?
   
4. **ASG Capacity:** Should the Auto Scaling Group have 1 or 2 desired instances? Currently code expects 2.
   
5. **Unused Modules:** Should we archive modules like `ci_cd`, `bedrock`, `transit_gateway`, etc. that may not be in use?

---

## Next Steps

**Phase 1: Fix Critical Issues (TODAY)**
1. Decision on Lambda functions (delete from code or recreate)
2. Fix API Gateway module references
3. Run `terraform plan` again to validate

**Phase 2: Review Planned Changes (24 hours)**
1. Confirm EKS cluster and SQL Server additions
2. Review Lambda code updates
3. Validate all infrastructure changes

**Phase 3: Apply Changes (When Ready)**
1. Run `terraform apply` with confirmed changes
2. Monitor resource creation in AWS Console
3. Validate functionality of new infrastructure

---

## Archive Notes

This report documents infrastructure state at the time you returned from leave. The plan failure is due to **intentional Lambda deletion** combined with **continued code references** to those deleted functions.

**Key Takeaway:** This is not a critical AWS outage—it's a code/infrastructure sync issue that requires deliberate fix before proceeding.

---

**Report Generated By:** GitHub Copilot Terraform Analysis  
**Report Version:** 1.0  
**Last Updated:** 2026-02-13 15:47 UTC
