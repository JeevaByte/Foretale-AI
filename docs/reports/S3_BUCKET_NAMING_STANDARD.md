# S3 Vector Bucket Naming Convention - Action Plan

## Executive Summary

The current vector bucket is named `foretale-dev-vector-bucket` but should follow the organizational naming standard: `foretale-app-s3-vector-db-us-east-2`.

**Status:** ⚠️ Non-compliant | **Action Required:** Rename bucket

---

## Current vs Standard

| Aspect | Current | Standard | Status |
|--------|---------|----------|--------|
| **Name** | foretale-dev-vector-bucket | foretale-app-s3-vector-db-us-east-2 | ✗ Incorrect |
| **Project Prefix** | foretale-dev | foretale-app | ✗ Wrong env tag |
| **Component** | (missing) | s3 | ✗ Missing |
| **Purpose** | vector-bucket | vector-db | ✗ Unclear |
| **Region** | (missing) | us-east-2 | ✗ Missing |

---

## Naming Convention Standard

### Pattern
```
{project}-{component}-s3-{purpose}-{region}
```

### Components Explained

| Component | Value | Description |
|-----------|-------|-------------|
| **project** | foretale | Application/project identifier |
| **component** | app | Service tier (app = main application) |
| **service** | s3 | AWS service type |
| **purpose** | vector-db | Primary use (vector database storage) |
| **region** | us-east-2 | AWS region identifier |

### Examples

```
✓ foretale-app-s3-vector-db-us-east-2    (Vector DB)
✓ foretale-app-s3-app-storage-us-east-2  (App data)
✓ foretale-app-s3-logs-us-east-2         (Logging)
✓ amplify-foretaleapplication-dev-*      (Amplify managed)
```

---

## Terraform Configuration

### Current State

**File:** `terraform/modules/s3/main.tf`

```terraform
locals {
  bucket_prefix = "foretale-app-s3"
}

resource "aws_s3_bucket" "vector_bucket_us_east_2" {
  bucket = "${local.bucket_prefix}-vector-db-us-east-2"  # ← Expected name
  ...
}
```

**Expected Bucket Name:** `foretale-app-s3-vector-db-us-east-2`

### Actual AWS State

```
Current bucket: foretale-dev-vector-bucket  # ← Does not match
```

---

## Action Plan - Option 1: Full Rename (Recommended)

### Step 1: Create New Bucket with Correct Name

```bash
aws s3api create-bucket \
  --bucket foretale-app-s3-vector-db-us-east-2 \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2
```

### Step 2: Copy Data from Old to New Bucket

```bash
aws s3 sync s3://foretale-dev-vector-bucket \
  s3://foretale-app-s3-vector-db-us-east-2 \
  --region us-east-2
```

### Step 3: Apply Same Configuration

- Enable versioning
- Apply encryption
- Set tags
- Configure access policies

### Step 4: Update References

Search and update all code/config that references old bucket:

```bash
grep -r "foretale-dev-vector-bucket" . --include="*.py" --include="*.js" --include="*.tf" --include="*.yaml"
```

### Step 5: Delete Old Bucket

```bash
aws s3api delete-bucket --bucket foretale-dev-vector-bucket --region us-east-2
```

**Timeline:** 5-10 minutes | **Risk:** Low | **Data Loss:** None

---

## Action Plan - Option 2: Terraform Import (Fastest)

### Step 1: Import Existing Bucket

```bash
cd terraform
terraform import 'module.s3.aws_s3_bucket.vector_bucket_us_east_2' foretale-dev-vector-bucket
```

### Step 2: Update Terraform State

The Terraform state will now reference the old bucket name until you:
- Rename the bucket (see Option 1)
- Or update Terraform to generate the new name

**Timeline:** 2-3 minutes | **Risk:** Very Low

---

## Code References to Update

### Search Results
```bash
grep -r "foretale-dev-vector-bucket" . 2>/dev/null
grep -r "foretale-app-s3-vector-db-us-east-2" . 2>/dev/null
```

**Typical locations:**
- `lambda/*/index.py` - Lambda functions accessing bucket
- `terraform/outputs.tf` - Output references
- `config/*.yaml` - Application configuration
- `.env` files - Environment variables
- Documentation and comments

---

## Compliance Checklist

- [ ] New bucket created with standard name
- [ ] Data migrated from old bucket
- [ ] Encryption applied
- [ ] Versioning configured
- [ ] Tags applied
- [ ] All code references updated
- [ ] Lambda functions tested
- [ ] Environment variables updated
- [ ] Old bucket deleted
- [ ] Terraform state synchronized
- [ ] Documentation updated

---

## Rollback Plan

If issues occur:

1. **Revert code to use old bucket name**
2. **Keep old bucket active**
3. **Stop using new bucket**
4. **Investigate issues**
5. **Retry with fixed configuration**

---

## Naming Convention Rules

### Must Have
✓ Always include region (e.g., us-east-2)
✓ Use lowercase letters and hyphens only
✓ Include purpose/service type
✓ Consistent with Terraform configuration
✓ Maximum 63 characters
✓ Must be globally unique

### Should Have
✓ Project identifier (foretale)
✓ Environment/component (app, dev, etc.)
✓ AWS service type (s3)
✓ Descriptive purpose (vector-db, logs, etc.)

### Must NOT Have
✗ Uppercase letters
✗ Underscores
✗ Dots (except in domain names)
✗ Environment-specific tags (dev, staging, prod in name)
✗ Inconsistent formatting

---

## Authorization & Approval

| Item | Status | Owner |
|------|--------|-------|
| **Naming Standard** | ✓ Defined | DevOps |
| **Current State** | ✗ Non-compliant | - |
| **Remediation Plan** | ✓ Ready | DevOps |
| **Execute Rename** | ⏳ Pending Approval | - |

---

## Next Steps

1. **Review this document** with team
2. **Choose an option** (Option 1 or Option 2)
3. **Schedule execution** (low-impact operation)
4. **Execute rename** with these steps
5. **Verify** all applications working
6. **Update documentation**

---

**Document Version:** 1.0
**Created:** 2026-02-05
**Status:** Action Required
**Priority:** Medium (compliance/standardization)
