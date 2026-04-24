# Terraform Changes Summary & Action Checklist
**Status:** ⚠️ Plan Validation Failed - 5 Critical Issues  
**Date:** February 13, 2026

---

## Overview: What Changed While You Were Away

```
CRITICAL FINDINGS:
┌─────────────────────────────────────────────────────────────┐
│ ❌ 5 Lambda Functions Deleted from AWS                      │
│    • foretale-app-lambda-insert-record (Dec)              │
│    • foretale-app-lambda-update-record (Dec)              │
│    • foretale-app-lambda-delete-record (Dec)              │
│    • foretale-app-lambda-read-record (Dec)                │
│    • foretale-app-lambda-read-json-record (Dec)           │
│                                                              │
│ ⚠️  BUT Code Still Tries to Reference Them                  │
│    ↳ Breaks terraform plan validation                      │
│    ↳ API Gateway endpoints will be broken if applied       │
└─────────────────────────────────────────────────────────────┘

INFRASTRUCTURE ADDITIONS:
    + EKS Kubernetes Cluster (21 resources)
    + SQL Server Database Instance  
    + Auto Scaling Policy

DRIFT DETECTED:
    ✓ Auto Scaling desired_capacity: 2 → 1 (external change)
    ✓ PostgreSQL parameters: apply method changed
    ✓ Lambda code updated (2 functions)

PLAN SUMMARY:
    Plan: 29 to add, 11 to change, 2 to destroy
    Status: BLOCKED - Validation failed
```

---

## Decision Tree: What to Do?

```
DECISION POINT 1: Lambda Functions Status
┌──────────────────────────────────────────────────────────┐
│ Q: Do you want to keep the Lambda CRUD operations?       │
│                                                            │
│ A: YES → Need to recreate 5 Lambda functions             │
│    ├─ Create modules/lambda/insert_record.zip            │
│    ├─ Create modules/lambda/update_record.zip            │
│    ├─ Create modules/lambda/delete_record.zip            │
│    ├─ Create modules/lambda/read_record.zip              │
│    ├─ Create modules/lambda/read_json_record.zip         │
│    └─ Add to modules/lambda/main.tf                      │
│                                                            │
│ A: NO → Remove from Terraform code                       │
│    ├─ Remove AWS::Lambda permissions from API Gateway    │
│    ├─ Remove API Gateway resource definitions            │
│    ├─ Update API Gateway integration resources           │
│    └─ Plan will then validate successfully                │
└──────────────────────────────────────────────────────────┘
```

---

## Action Checklist - IMMEDIATE PRIORITIES

### Priority 1: Fix Terraform Plan Validation ⚠️ REQUIRED TODAY

**Task 1.1: Decision on Lambda Functions**
- [ ] Decide: Keep CRUD Lambdas (recreate) or remove them?
- [ ] Document decision in team Slack/Wiki

**Task 1.2: If Removing CRUD Lambdas (Faster Path)**
- [ ] Edit `modules/api-gateway/main.tf`
  - [ ] Remove: `aws_lambda_permission.api_insert` (line 313-320)
  - [ ] Remove: `aws_lambda_permission.api_update` (line 321-328)
  - [ ] Remove: `aws_lambda_permission.api_delete` (line 329-336)
  - [ ] Remove: `aws_lambda_permission.api_read` (line 337-344)
  - [ ] Remove: `aws_lambda_permission.api_read_json` (line 345-352)
  - [ ] Remove: All 5 API Gateway methods (`http_method` resources)
  - [ ] Remove: All 5 API Gateway integrations
  
- [ ] Edit `modules/api-gateway/variables.tf`
  - [ ] Remove: All variable definitions for deleted functions (lines 71-96)

- [ ] Verify no other code references these functions
  ```bash
  grep -r "lambda_function_name_insert" --include="*.tf"
  grep -r "lambda_function_name_update" --include="*.tf"
  grep -r "lambda_function_name_delete" --include="*.tf"
  grep -r "lambda_function_name_read" --include="*.tf"
  grep -r "lambda_function_name_read_json" --include="*.tf"
  ```

- [ ] Run `terraform plan` again to validate

**Task 1.3: If Recreating CRUD Lambdas (Longer Path)**
- [ ] Request Lambda function code from team
- [ ] Create deployment ZIP files in `modules/lambda/`
- [ ] Add function definitions to `modules/lambda/main.tf`
- [ ] Update `modules/lambda/outputs.tf` to export function ARNs
- [ ] Update `main.tf` to pass function ARNs to `api_gateway` module
- [ ] Run `terraform plan` to validate

---

### Priority 2: Review Major Infrastructure Changes 📋 REQUIRED BEFORE APPLY

**Task 2.1: EKS Cluster Creation Review**
- [ ] Understand why EKS cluster is being added
- [ ] Review cluster configuration in `modules/eks/main.tf`
- [ ] Assess:
  - [ ] Kubernetes version: 1.29 (current, good)
  - [ ] Node type: t3.medium (cost ~$0.04/hour per node)
  - [ ] Desired nodes: 2 minimum, 4 maximum (scalable)
  - [ ] Estimated monthly cost: ~$70-150 for compute
- [ ] Do we have workloads to deploy on EKS?
- [ ] Is this intended or accidental?

**Task 2.2: SQL Server Database Creation Review**
- [ ] Understand why SQL Server was added
- [ ] Review configuration in `modules/rds/main.tf`
- [ ] Assess:
  - [ ] Engine: SQL Server Express Edition (OK for small workloads)
  - [ ] Instance: db.t3.large (cost ~$0.12/hour)
  - [ ] Storage: 100 GB (cost ~$10/month)
  - [ ] Backup: 7-day retention (standard)
  - [ ] Multi-AZ: Enabled (high availability)
  - [ ] Estimated monthly cost: ~$90-100 for compute+storage
- [ ] Is this intended or accidental?

**Task 2.3: Lambda Function Code Changes**
- [ ] Review changes to `calling-sql-procedure` (code updated)
- [ ] Review changes to `sql-server-data-upload` (code updated)
- [ ] Verify these are intentional, not data corruption
- [ ] Test modifications if possible

**Task 2.4: Auto Scaling Group Drift**
- [ ] Current state: 1 desired instance
- [ ] Terraform code: 2 desired instances
- [ ] Decision: Should we have 1 or 2 instances?
- [ ] If 1 is correct: Update `terraform.tfvars` to set `eks_desired_size = 1`
- [ ] If 2 is correct: Plan will scale up to 2 on apply

---

### Priority 3: Validate & Apply ✅ WHEN READY

**Task 3.1: Final Validation**
- [ ] Run `terraform plan` again after fixing issues
- [ ] Review full plan output (should be 29 adds, 11 changes, 2 destroys)
- [ ] Confirm no more validation errors
- [ ] Export plan to file: `terraform plan -out=tfplan`

**Task 3.2: Pre-Apply Safety Checks**
- [ ] Back up current Terraform state:
  ```bash
  cp terraform.tfstate terraform.tfstate.backup.2026-02-13
  ```
- [ ] Review changes in AWS Console for any unexpected resources
- [ ] Check AWS billing alerts are enabled
- [ ] Ensure team is aware of infrastructure changes

**Task 3.3: Apply Changes**
- [ ] Run: `terraform apply tfplan`
- [ ] Monitor for errors during creation
- [ ] Verify created resources in AWS Console
- [ ] Test functionality:
  - [ ] EKS cluster accessibility
  - [ ] SQL Server database connectivity
  - [ ] Lambda function invocations
  - [ ] API Gateway endpoints

---

### Priority 4: Cleanup Optional Tasks 🔧

**Task 4.1: Archive Unused Modules** (Only if not referenced)
- [ ] Check `ci_cd` module usage:
  ```bash
  grep -r "module \"ci_cd\"" main.tf
  ```
- [ ] Check `bedrock` module usage:
  ```bash
  grep -r "module \"bedrock\"" main.tf
  ```
- [ ] Check `transit_gateway` module usage:
  ```bash
  grep -r "module \"transit_gateway\"" main.tf
  ```
- [ ] Check `ssm_automation` module usage:
  ```bash
  grep -r "module \"ssm_automation\"" main.tf
  ```
- [ ] Check `account_vending` module usage:
  ```bash
  grep -r "module \"account_vending\"" main.tf
  ```
- [ ] If not referenced: Move to `_archive/modules/` for cleanup

---

## Files to Modify

### CRITICAL - Must Modify Before Plan Validates

**IF REMOVING CRUD LAMBDAS:**

1. **`infrastructure/terraform/modules/api-gateway/main.tf`**
   - Location: Lines containing `aws_lambda_permission` resources for insert/update/delete/read/read_json
   - Action: Delete 5 permission resources + associated method/integration definitions
   - Impact: API will only have ecs_invoker endpoint (not CRUD)

2. **`infrastructure/terraform/modules/api-gateway/variables.tf`**
   - Location: Lines 71-96
   - Action: Delete variable definitions for deleted functions
   - Impact: Simplifies module, removes references to deleted code

**IF RECREATING CRUD LAMBDAS:**

1. **`infrastructure/terraform/modules/lambda/main.tf`**
   - Add: 5 new `aws_lambda_function` resources
   - Add: Function handler ZIP references
   - Impact: Recreates deleted Lambda functions

2. **`infrastructure/terraform/modules/lambda/outputs.tf`**
   - Add: Output values for new function ARNs
   - Impact: Makes functions accessible to API Gateway module

3. **`infrastructure/terraform/main.tf`** (Lines 245-261)
   - Update: Pass function references to `module "api_gateway"`
   - Impact: Connects Lambda functions to API Gateway

---

## Risk Summary

| Change | Risk Level | Impact | Can Rollback? |
|--------|-----------|--------|-----------------|
| Remove CRUD Lambda refs | 🟢 Low | API endpoints removed | Yes, restore code |
| EKS Cluster creation | 🟠 Medium | New infrastructure | Yes, destroy cluster |
| SQL Server creation | 🟠 Medium | New infrastructure | Yes, delete database |
| ASG scaling | 🟡 Low | Instance count changes | Yes, update tfvars |
| Lambda code updates | 🟡 Low | Function behavior | Yes, redeploy old code |
| Deposed resource cleanup | 🟢 Low | Orphaned resources removed | No, but safe |

---

## Time Estimates

| Task | Effort | Time |
|------|--------|------|
| Fix Lambda references (remove) | Low | 30 min |
| Fix Lambda references (recreate) | Medium | 2-4 hours |
| Review EKS/SQL Server | Medium | 1-2 hours |
| Final validation | Low | 15 min |
| Apply changes | Low | 10-15 min |
| Post-apply testing | Medium | 1-2 hours |

---

## Questions to Resolve

Before proceeding to `terraform apply`:

1. **Lambda Functions:**
   - [ ] Are we intentionally removing CRUD operations from the API?
   - [ ] Do we need to recreate insert/update/delete/read/read_json functions?

2. **EKS Cluster:**
   - [ ] Is the EKS cluster a planned addition or accidental?
   - [ ] What workloads will run on EKS?
   - [ ] Did someone add this while I was away?

3. **SQL Server:**
   - [ ] Is the SQL Server database intentional?
   - [ ] What's the purpose? Migration? New feature?
   - [ ] Licensing compliance confirmed?

4. **Auto Scaling:**
   - [ ] Should we have 1 or 2 AI server instances?
   - [ ] Was the change from 2 to 1 intentional?

5. **Team Coordination:**
   - [ ] Who made changes while you were away?
   - [ ] Are all changes documented?
   - [ ] Has anyone already started using new infrastructure?

---

## Support Resources

1. **Full Drift Report:** `docs/reports/TERRAFORM_DRIFT_DETECTION_2026-02-13.md`
2. **Terraform State:** `infrastructure/terraform/terraform.tfstate`
3. **Plan Output:** Last generated at 2026-02-13 15:47 UTC
4. **AWS Regions:** Primary `us-east-2`, Source `us-east-1`

---

## Next Step

**→ DECIDE: Remove or Recreate Lambda Functions?**

Once decided, provide the decision and we'll proceed with:
1. Code modifications
2. Full terraform plan validation
3. Infrastructure changes application

