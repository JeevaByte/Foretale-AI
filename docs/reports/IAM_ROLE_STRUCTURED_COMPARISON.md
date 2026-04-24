# IAM ROLE COMPARISON REPORT - STRUCTURED ANALYSIS

**Report Generated:** February 12, 2026  
**Comparison Type:** Read-Only Analysis  
**Account ID:** 442426872653 (Same AWS Account - IAM is global)

---

## ✅ ROLE EXISTENCE VERIFICATION

| Role | Region Noted | Account | Status | Path |
|------|--------------|---------|--------|------|
| **ecs-task-invoker-role-eq44ntlp** | us-east-1 | 442426872653 | ✅ **EXISTS** | `/service-role/` |
| **foretale-dev-lambda-execution-role** | us-east-2 | 442426872653 | ✅ **EXISTS** | `/` |

**Note:** IAM is a global AWS service - roles exist across all regions for the account. Region references indicate deployment/usage region, not role storage.

---

## 1️⃣ TRUST RELATIONSHIP COMPARISON

### Side-by-Side Trust Policy

```
┌─────────────────────────────────────────────────────────────────┐
│                    ASSUME ROLE POLICY                            │
├──────────────────────────────┬──────────────────────────────────┤
│ Role 1 (ecs-task-invoker)    │ Role 2 (foretale-dev-lambda)     │
├──────────────────────────────┼──────────────────────────────────┤
│ Principal.Service:           │ Principal.Service:               │
│   lambda.amazonaws.com       │   lambda.amazonaws.com           │
│                              │                                  │
│ Action:                      │ Action:                          │
│   sts:AssumeRole             │   sts:AssumeRole                 │
│                              │                                  │
│ Conditions: NONE             │ Conditions: NONE                 │
│   (Any Lambda can assume)    │   (Any Lambda can assume)        │
└──────────────────────────────┴──────────────────────────────────┘
```

### Trust Relationship Analysis

| Parameter | Role 1 | Role 2 | Match |
|-----------|--------|--------|-------|
| **Principal Type** | Service | Service | ✅ YES |
| **Principal Value** | lambda.amazonaws.com | lambda.amazonaws.com | ✅ YES |
| **Action** | sts:AssumeRole | sts:AssumeRole | ✅ YES |
| **Conditions** | None | None | ✅ YES |
| **Scope** | Any Lambda in account | Any Lambda in account | ✅ YES |

**Finding:** ✅ **TRUST RELATIONSHIPS ARE IDENTICAL**

---

## 2️⃣ ATTACHED MANAGED POLICIES COMPARISON

### Role 1: ecs-task-invoker-role-eq44ntlp

| Policy Type | Policy Name | Scope | ARN |
|-------------|-------------|-------|-----|
| **Customer Managed** | AWSLambdaBasicExecutionRole-1fbd37d6-ab8b-4533-ac8d-b91db295e9e2 | Custom | arn:aws:iam::442426872653:policy/service-role/... |
| **AWS Managed** | None | — | — |

**Customer Policy Details:**
```json
{
  "Effect": "Allow",
  "Action": "logs:CreateLogGroup",
  "Resource": "arn:aws:logs:us-east-1:442426872653:*"
}
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "arn:aws:logs:us-east-1:442426872653:log-group:/aws/lambda/ecs-task-invoker:*"
}
```

**Services Enabled:** CloudWatch Logs (us-east-1 specific)

---

### Role 2: foretale-dev-lambda-execution-role

| Policy Type | Policy Name | Scope | ARN |
|-------------|-------------|-------|-----|
| **AWS Managed** | AWSLambdaVPCAccessExecutionRole | AWS Standard | arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole |
| **Customer Managed** | None | — | — |

**AWS Managed Policy Details:**
```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeSubnets",
    "ec2:DeleteNetworkInterface",
    "ec2:AssignPrivateIpAddresses",
    "ec2:UnassignPrivateIpAddresses"
  ],
  "Resource": "*"
}
```

**Services Enabled:** CloudWatch Logs + EC2 VPC Management

---

### Managed Policies Comparison

| Aspect | Role 1 | Role 2 | Difference |
|--------|--------|--------|-----------|
| **AWS Managed Policies** | 0 | 1 | ⚠️ Role 2 has AWS managed policy |
| **Customer Managed Policies** | 1 | 0 | ⚠️ Role 1 has custom policy |
| **CloudWatch Logs** | ✅ Yes (us-east-1 only) | ✅ Yes (global) | ⚠️ Role 2 more portable |
| **EC2/VPC Access** | ❌ No | ✅ Yes | ⚠️ Role 2 has VPC |
| **Region Portability** | ❌ Locked to us-east-1 | ✅ Portable | ⚠️ Role 1 is region-specific |

**Key Finding:** 🔴 **Role 1 is REGION-LOCKED to us-east-1 CloudWatch Logs**

---

## 3️⃣ INLINE POLICIES COMPARISON

### Role 1: ecs-task-invoker-role-eq44ntlp

**Inline Policies Count:** 1

#### Policy: AllowRunAllECSTasks

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowRunTask",
      "Effect": "Allow",
      "Action": "ecs:RunTask",
      "Resource": "*"
    },
    {
      "Sid": "AllowPassRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*",
      "Condition": {
        "StringEqualsIfExists": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    }
  ]
}
```

**Permissions Detail:**
| Action | Resource | Condition | Scope |
|--------|----------|-----------|-------|
| ecs:RunTask | * | None | 🔴 VERY BROAD |
| iam:PassRole | * | iam:PassedToService=ecs-tasks.amazonaws.com | 🟡 MODERATE |

---

### Role 2: foretale-dev-lambda-execution-role

**Inline Policies Count:** 2

#### Policy 1: foretale-dev-lambda-ecs-invoke

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowECSTaskOperations",
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:DescribeTasks",
        "ecs:StopTask"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowPassRoleToSpecificRoles",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::442426872653:role/foretale-dev-ecs-task-execution-role",
        "arn:aws:iam::442426872653:role/foretale-dev-ecs-task-role"
      ]
    }
  ]
}
```

**Permissions Detail:**
| Action | Resource | Condition | Scope |
|--------|----------|-----------|-------|
| ecs:RunTask | * | None | 🔴 BROAD |
| ecs:DescribeTasks | * | None | 🟡 MODERATE |
| ecs:StopTask | * | None | 🟡 MODERATE |
| iam:PassRole | 2 specific roles | None | 🟢 RESTRICTIVE |

#### Policy 2: foretale-dev-lambda-rds-access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowRDSDataAPIAccess",
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowSecretsRetrival",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:*:*:secret:foretale/*"
    }
  ]
}
```

**Permissions Detail:**
| Action | Resource | Condition | Scope |
|--------|----------|-----------|-------|
| rds-data:ExecuteStatement | * | None | 🔴 VERY BROAD |
| rds-data:BatchExecuteStatement | * | None | 🔴 VERY BROAD |
| rds-data:BeginTransaction | * | None | 🔴 VERY BROAD |
| rds-data:CommitTransaction | * | None | 🔴 VERY BROAD |
| rds-data:RollbackTransaction | * | None | 🔴 VERY BROAD |
| secretsmanager:GetSecretValue | foretale/* | None | 🟢 RESTRICTIVE |

---

### Inline Policies Comparison

| Aspect | Role 1 | Role 2 |
|--------|--------|--------|
| **Total Inline Policies** | 1 | 2 |
| **ECS Permissions** | RunTask only | RunTask, DescribeTasks, StopTask |
| **ECS Resource Scope** | * (all) | * (all) |
| **IAM PassRole Scope** | * (all resources) | 2 specific roles |
| **RDS Access** | ❌ None | ✅ Full RDS Data API |
| **Secrets Manager** | ❌ None | ✅ GetSecretValue (foretale/*) |

---

## 4️⃣ PERMISSIONS SCOPE ANALYSIS

### Permissions Present in ROLE 1 ONLY

```
✓ ecs:RunTask (on all resources)
✓ iam:PassRole (on all resources with condition)
✓ logs:CreateLogGroup (on us-east-1 logs)
✓ logs:CreateLogStream (on us-east-1 specific log group)
✓ logs:PutLogEvents (on us-east-1 specific log group)
```

**Total: 5 permissions (but region-locked)**

---

### Permissions Present in ROLE 2 ONLY

```
✓ ecs:DescribeTasks (on all resources)
✓ ecs:StopTask (on all resources)
✓ ec2:CreateNetworkInterface (on all resources)
✓ ec2:DescribeNetworkInterfaces (on all resources)
✓ ec2:DescribeSubnets (on all resources)
✓ ec2:DeleteNetworkInterface (on all resources)
✓ ec2:AssignPrivateIpAddresses (on all resources)
✓ ec2:UnassignPrivateIpAddresses (on all resources)
✓ rds-data:ExecuteStatement (on all resources)
✓ rds-data:BatchExecuteStatement (on all resources)
✓ rds-data:BeginTransaction (on all resources)
✓ rds-data:CommitTransaction (on all resources)
✓ rds-data:RollbackTransaction (on all resources)
✓ secretsmanager:GetSecretValue (on foretale/* resources)
```

**Total: 14 additional permissions**

---

### Permissions Present in BOTH ROLES

```
✓ ecs:RunTask (on all resources)
✓ iam:PassRole (with service restrictions)
✓ logs:CreateLogGroup
✓ logs:CreateLogStream
✓ logs:PutLogEvents
```

**Common Services:** ECS, IAM, CloudWatch Logs

---

### Wildcard Analysis

| Service | Role 1 | Role 2 | Risk Level |
|---------|--------|--------|-----------|
| **ECS** | ecs:* on * | ecs:* on * | 🔴 CRITICAL (both overly broad) |
| **IAM** | PassRole on * | PassRole on 2 roles | 🟡 HIGH → 🟢 GOOD |
| **RDS Data** | None | rds-data:* on * | 🔴 HIGH |
| **Secrets Manager** | None | GetSecretValue on foretale/* | 🟢 GOOD (restricted) |
| **EC2** | None | ec2:* on * | 🟡 MODERATE |
| **CloudWatch Logs** | us-east-1 only | Global | 🟢 GOOD |

---

### Services Summary

```
┌─────────────────────────────────────────────────────┐
│           SERVICES COMPARISON                       │
├──────────────────────┬──────────────────────────────┤
│ Role 1               │ Role 2                       │
├──────────────────────┼──────────────────────────────┤
│ ✅ CloudWatch Logs   │ ✅ CloudWatch Logs           │
│ ✅ ECS               │ ✅ ECS                       │
│ ✅ IAM (PassRole)    │ ✅ IAM (PassRole)            │
│ ❌ EC2/VPC           │ ✅ EC2/VPC                   │
│ ❌ RDS Data API      │ ✅ RDS Data API              │
│ ❌ Secrets Manager   │ ✅ Secrets Manager           │
├──────────────────────┼──────────────────────────────┤
│ 3 Services Enabled   │ 6 Services Enabled           │
└──────────────────────┴──────────────────────────────┘
```

---

## 5️⃣ ROLE CONFIGURATION COMPARISON

### Basic Configuration

```
┌────────────────────────────────────────────────────────────────┐
│                    ROLE METADATA                               │
├──────────────────────────────┬────────────────────────────────┤
│ Attribute                    │ Role 1    │ Role 2             │
├──────────────────────────────┼───────────┼────────────────────┤
│ Role Name                    │ ecs-task- │ foretale-dev-      │
│                              │ invoker   │ lambda-execution   │
│                              │ -role-... │ -role              │
├──────────────────────────────┼───────────┼────────────────────┤
│ Path                         │ /service- │ / (root)           │
│                              │ role/     │                    │
├──────────────────────────────┼───────────┼────────────────────┤
│ Max Session Duration         │ 3600s     │ 3600s              │
│                              │ (1 hour)  │ (1 hour)           │
├──────────────────────────────┼───────────┼────────────────────┤
│ Created Date                 │ 2025-05-  │ 2026-01-            │
│                              │ 21        │ 20                 │
├──────────────────────────────┼───────────┼────────────────────┤
│ Tags                         │ NONE      │ 6 TAGS             │
├──────────────────────────────┼───────────┼────────────────────┤
│ Permissions Boundary         │ NONE      │ NONE               │
└──────────────────────────────┴───────────┴────────────────────┘
```

### Tags Comparison

**Role 1: ecs-task-invoker-role-eq44ntlp**
```
No tags assigned
```

**Role 2: foretale-dev-lambda-execution-role**
```
Application      = ForeTale
CostCenter       = Engineering
Name             = foretale-dev-lambda-execution-role
Compliance       = None
Owner            = DevOps Team
Environment      = dev
```

**Finding:** 🟢 Role 2 has proper organizational tagging for cost allocation and governance

---

## 🔍 SECURITY OBSERVATIONS

### Critical Issues (Both Roles)

#### ⛔ CRITICAL: Unrestricted ECS RunTask

**Issue:** Both roles allow `ecs:RunTask` on `*` resources without restrictions

**Risk Level:** 🔴 **CRITICAL**

**Current State:**
```json
{
  "Effect": "Allow",
  "Action": "ecs:RunTask",
  "Resource": "*"
}
```

**Impact:**
- Can launch ANY task in ANY cluster
- No task definition restrictions
- No cluster isolation
- Can launch escalated tasks

**Recommended Fix:**
```json
{
  "Effect": "Allow",
  "Action": "ecs:RunTask",
  "Resource": [
    "arn:aws:ecs:*:442426872653:cluster/foretale-*",
    "arn:aws:ecs:*:442426872653:task-definition/foretale-*:*"
  ]
}
```

---

#### ⛔ CRITICAL: Unrestricted RDS Data API (Role 2 Only)

**Issue:** Role 2 allows `rds-data:*` on `*` resources

**Risk Level:** 🔴 **CRITICAL**

**Current State:**
```json
{
  "Effect": "Allow",
  "Action": [
    "rds-data:ExecuteStatement",
    "rds-data:BatchExecuteStatement",
    "rds-data:BeginTransaction",
    "rds-data:CommitTransaction",
    "rds-data:RollbackTransaction"
  ],
  "Resource": "*"
}
```

**Impact:**
- Can execute ANY SQL statement on ANY Aurora cluster
- Full database access (no statement restrictions)
- Can access other applications' databases
- No table/schema isolation

**Recommended Fix:**
```json
{
  "Effect": "Allow",
  "Action": [
    "rds-data:ExecuteStatement",
    "rds-data:BatchExecuteStatement",
    "rds-data:BeginTransaction",
    "rds-data:CommitTransaction",
    "rds-data:RollbackTransaction"
  ],
  "Resource": "arn:aws:rds:*:442426872653:cluster:foretale-*"
}
```

---

#### ⚠️ HIGH: Overly Broad IAM PassRole (Role 1 Only)

**Issue:** Role 1 allows `iam:PassRole` on all resources with condition only

**Risk Level:** 🟡 **HIGH**

**Current State:**
```json
{
  "Effect": "Allow",
  "Action": "iam:PassRole",
  "Resource": "*",
  "Condition": {
    "StringEqualsIfExists": {
      "iam:PassedToService": "ecs-tasks.amazonaws.com"
    }
  }
}
```

**Impact:**
- Can pass any role to ECS tasks
- Weak condition checking (StringEqualsIfExists allows bypass)
- Could escalate privileges

**Preferred Approach (Role 2):**
```json
{
  "Effect": "Allow",
  "Action": "iam:PassRole",
  "Resource": [
    "arn:aws:iam::442426872653:role/foretale-dev-ecs-task-execution-role",
    "arn:aws:iam::442426872653:role/foretale-dev-ecs-task-role"
  ]
}
```

---

#### ⚠️ HIGH: Region-Locked CloudWatch Logs (Role 1 Only)

**Issue:** Role 1 CloudWatch logs restricted to us-east-1

**Risk Level:** 🟡 **HIGH** (Portability Issue)

**Current State:**
```json
{
  "Effect": "Allow",
  "Action": "logs:CreateLogGroup",
  "Resource": "arn:aws:logs:us-east-1:442426872653:*"
},
{
  "Effect": "Allow",
  "Action": ["logs:CreateLogStream", "logs:PutLogEvents"],
  "Resource": "arn:aws:logs:us-east-1:442426872653:log-group:/aws/lambda/ecs-task-invoker:*"
}
```

**Impact:**
- Role cannot be used in other regions
- Requires separate role per region
- Maintenance overhead
- No role portability

**Better Approach (Role 2):**
Uses AWS managed `AWSLambdaVPCAccessExecutionRole` which is global and portable

---

#### 🟢 GOOD: restrictive Secrets Manager Access (Role 2 Only)

**Positive Finding:** Role 2 properly restricts Secrets Manager

```json
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:*:*:secret:foretale/*"
}
```

**Benefits:**
- Only `foretale/*` secrets accessible
- Blast radius limited to application secrets
- Follows principle of least privilege

---

### Least Privilege Violations Summary

| Finding | Role 1 | Role 2 | Severity |
|---------|--------|--------|----------|
| **Unrestricted ecs:RunTask** | ✅ Violates | ✅ Violates | 🔴 CRITICAL |
| **Unrestricted RDS Data API** | N/A | ✅ Violates | 🔴 CRITICAL |
| **Overly Broad PassRole** | ✅ Violates (wild condition) | ❌ Does not violate | 🟡 HIGH |
| **Region-Locked Logs** | ✅ Violates portability | ❌ Does not violate | 🟡 HIGH |
| **Unrestricted EC2 Access** | N/A | ✅ Violates (ec2:* on *) | 🟡 MODERATE |

---

## 📋 SUMMARY TABLE COMPARISON

```
┌────────────────────────────────────────────────────────────────────┐
│                    COMPREHENSIVE COMPARISON                        │
├─────────────────────────────────┬────────────┬────────────────────┤
│ Aspect                          │ Role 1     │ Role 2             │
├─────────────────────────────────┼────────────┼────────────────────┤
│ Trust Relationship              │ IDENTICAL  │ IDENTICAL          │
│ Managed Policies                │ 1 custom   │ 1 AWS managed      │
│ Inline Policies                 │ 1          │ 2                  │
│ Total Permissions               │ 5          │ 19                 │
├─────────────────────────────────┼────────────┼────────────────────┤
│ CloudWatch Logs                 │ ✅ Limited │ ✅ Full            │
│ ECS Access                      │ ✅ RunTask | ✅ Run/Describe    │
│ VPC/EC2 Management              │ ❌ None    │ ✅ Full            │
│ RDS Data API                    │ ❌ None    │ ✅ Full            │
│ Secrets Manager                 │ ❌ None    │ ✅ Full            │
├─────────────────────────────────┼────────────┼────────────────────┤
│ Organizational Tags             │ ❌ None    │ ✅ 6 Tags          │
│ Region Portability              │ ❌ No      │ ✅ Yes             │
│ Least Privilege Compliance      │ ⚠️ Partial | ⚠️ Partial         │
│ Least Privilege Issues Count    │ 3          │ 3                  │
└─────────────────────────────────┴────────────┴────────────────────┘
```

---

## ✅ RECOMMENDATIONS

### Can Role 2 Replace Role 1?

**Assessment:** ✅ **YES, with modifications**

**Analysis:**
- Role 2 includes ALL permissions from Role 1
- Role 2 is more comprehensive and production-ready
- Role 2 has better least-privilege controls on PassRole
- Role 2 is globally portable (not region-locked)
- Role 2 has proper organizational tagging

### Migration Path

**For any Lambda functions currently using Role 1:**

1. **Immediate Action:** 
   - Migrate to Role 2: `foretale-dev-lambda-execution-role`
   - Both roles are in the same AWS account
   
2. **Validation:**
   - Test all ECS task invocations work with Role 2
   - Verify CloudWatch logs are properly written
   - Confirm no permission errors in Lambda execution

3. **Cleanup:**
   - Once migration complete and validated, decommission Role 1
   - Document in infrastructure-as-code which functions moved to Role 2

**Alternative:** If Role 1's ECS-only functionality is needed, create a new role based on Role 2 but remove RDS and Secrets Manager permissions.

---

### Security Hardening Recommendations

**Priority 1 (CRITICAL) - Both Roles:**

1. **Restrict ECS RunTask Resource Scope**
   ```json
   "Resource": "arn:aws:ecs:*:442426872653:cluster/foretale-*"
   ```

2. **Restrict RDS Data API Resource Scope (Role 2)**
   ```json
   "Resource": "arn:aws:rds:*:442426872653:cluster:foretale-*"
   ```

**Priority 2 (HIGH):**

3. **Restrict EC2 Permissions (Role 2)**
   - Scope to specific VPC and subnets instead of `*`
   - Consider using service control policies (SCPs)

4. **Add ECS Task Definition Restrictions**
   ```json
   "Resource": "arn:aws:ecs:*:442426872653:task-definition/foretale-*:*"
   ```

**Priority 3 (MODERATE):**

5. **Add Tags to Role 1** (if continuing to use it)
   - Match Role 2's tagging scheme
   - Enable cost center tracking

6. **Document Resource Boundaries**
   - Create access policy documentation
   - Define which services/functions use which roles

---

## 🎯 FINAL VERDICT

| Criteria | Verdict |
|----------|---------|
| **Can Role 2 replace Role 1?** | ✅ **YES** |
| **Role 2 is more secure?** | 🟡 **EQUALLY INSECURE** (both have critical wildcards) |
| **Role 2 is more complete?** | ✅ **YES** |
| **Role 2 is production-ready?** | 🟡 **MOSTLY** (needs RDS/ECS scoping) |
| **Recommend Role 2?** | ✅ **YES, after hardening** |

**Bottom Line:** Migrate to Role 2, but both roles require immediate security hardening of ECS and RDS permissions before production use.

---

## 📌 CHANGE LOG

- **No modifications made** - This is a read-only comparison analysis
- **All data gathered:** February 12, 2026
- **Verification:** Both roles confirmed to exist in account 442426872653

