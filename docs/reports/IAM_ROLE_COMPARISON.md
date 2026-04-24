# IAM Role Comparison Report

**Generated:** February 12, 2026

## Executive Summary

This report compares two IAM roles used for Lambda function execution across AWS regions:
- **Role 1:** `ecs-task-invoker-role-eq44ntlp` (us-east-1)
- **Role 2:** `foretale-dev-lambda-execution-role` (us-east-2)

---

## 1️⃣ Trust Relationship (Assume Role Policy)

### Role 1: ecs-task-invoker-role-eq44ntlp

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Analysis:**
- ✅ **Principal:** `lambda.amazonaws.com` (Only Lambda service)
- ✅ **Action:** `sts:AssumeRole` (Standard assume role)
- ✅ **Conditions:** None (Any Lambda function can assume)

---

### Role 2: foretale-dev-lambda-execution-role

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Analysis:**
- ✅ **Principal:** `lambda.amazonaws.com` (Only Lambda service)
- ✅ **Action:** `sts:AssumeRole` (Standard assume role)
- ✅ **Conditions:** None (Any Lambda function can assume)

---

### Trust Relationship Comparison

| Aspect | Role 1 | Role 2 | Difference |
|--------|--------|--------|-----------|
| **Principal Service** | lambda.amazonaws.com | lambda.amazonaws.com | ✅ **IDENTICAL** |
| **Action** | sts:AssumeRole | sts:AssumeRole | ✅ **IDENTICAL** |
| **Conditions** | None | None | ✅ **IDENTICAL** |

**Conclusion:** Both roles have **identical trust relationships** - both allow any Lambda service to assume them without conditions.

---

## 2️⃣ Attached Managed Policies

### Role 1: ecs-task-invoker-role-eq44ntlp

**Attached AWS Managed Policies:** None

**Attached Customer Managed Policies:**
1. `AWSLambdaBasicExecutionRole-1fbd37d6-ab8b-4533-ac8d-b91db295e9e2`
   - **Type:** Customer Managed Policy
   - **Path:** `/service-role/`
   - **Created:** May 21, 2025
   - **ARN:** `arn:aws:iam::442426872653:policy/service-role/AWSLambdaBasicExecutionRole-1fbd37d6-ab8b-4533-ac8d-b91db295e9e2`

**Policy Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:us-east-1:442426872653:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:us-east-1:442426872653:log-group:/aws/lambda/ecs-task-invoker:*"
      ]
    }
  ]
}
```

---

### Role 2: foretale-dev-lambda-execution-role

**Attached AWS Managed Policies:**
1. `AWSLambdaVPCAccessExecutionRole`
   - **Type:** AWS Managed Policy
   - **Path:** `/service-role/`
   - **Version:** v3 (Latest: v3)
   - **ARN:** `arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole`
   - **Permissions Scopes:** VPC access + CloudWatch Logs

**Attached Customer Managed Policies:** None

**AWS Managed Policy Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSLambdaVPCAccessExecutionPermissions",
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
  ]
}
```

---

### Managed Policies Comparison

| Aspect | Role 1 | Role 2 | Difference |
|--------|--------|--------|-----------|
| **AWS Managed Policies** | None | 1 (AWSLambdaVPCAccessExecutionRole) | ⚠️ **DIFFERENT** |
| **Customer Managed Policies** | 1 (AWSLambdaBasicExecutionRole) | None | ⚠️ **DIFFERENT** |
| **Total Managed Policies** | 1 | 1 | ✅ Same count |
| **CloudWatch Logs** | ✅ Yes (via custom policy) | ✅ Yes (via AWS policy) | ✅ Both have it |
| **VPC Access** | ❌ No | ✅ Yes (EC2 actions) | ⚠️ **DIFFERENT** |

**Key Insight:** Role 1 focuses on basic logging, while Role 2 includes VPC network interface management capabilities.

---

## 3️⃣ Inline Policies

### Role 1: ecs-task-invoker-role-eq44ntlp

**Inline Policy Count:** 1

#### Inline Policy: AllowRunAllECSTasks

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ecs:RunTask",
      "Resource": "*"
    },
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
  ]
}
```

**Permissions:**
- ✅ `ecs:RunTask` on all resources (broad)
- ✅ `iam:PassRole` on all resources (with condition)

---

### Role 2: foretale-dev-lambda-execution-role

**Inline Policy Count:** 2

#### Inline Policy 1: foretale-dev-lambda-ecs-invoke

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

**Permissions:**
- ✅ `ecs:RunTask` on all resources
- ✅ `ecs:DescribeTasks` on all resources
- ✅ `ecs:StopTask` on all resources
- ✅ `iam:PassRole` restricted to 2 specific roles

#### Inline Policy 2: foretale-dev-lambda-rds-access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:*:*:secret:foretale/*"
    }
  ]
}
```

**Permissions:**
- ✅ RDS Data API actions on all resources
- ✅ Secrets Manager access restricted to `foretale/*` secrets

---

### Inline Policies Comparison

| Aspect | Role 1 | Role 2 | Difference |
|--------|--------|--------|-----------|
| **Number of Inline Policies** | 1 | 2 | ⚠️ **Role 2 has more** |
| **ECS Actions** | RunTask (broad) | RunTask, DescribeTasks, StopTask | ⚠️ **Role 2 more granular** |
| **ECS Resource Scope** | * (all resources) | * (all resources) | ✅ Both broad |
| **IAM PassRole** | * with condition | Restricted to 2 specific roles | ⚠️ **Role 2 more restrictive** |
| **RDS Access** | ❌ None | ✅ RDS Data API (5 actions) | ⚠️ **Only Role 2** |
| **Secrets Manager** | ❌ None | ✅ GetSecretValue (foretale/*) | ⚠️ **Only Role 2** |

**Critical Difference:** Role 2 has database and secrets management capabilities that Role 1 lacks.

---

## 4️⃣ Permissions Scope Analysis

### Wildcard Usage

| Category | Role 1 | Role 2 | Risk Level |
|----------|--------|--------|-----------|
| **ECS Resources** | `ecs:RunTask` on `*` | `ecs:*` on `*` | 🔴 **Both Broad** |
| **IAM PassRole** | `iam:PassRole` on `*` | `iam:PassRole` on specific 2 roles | 🟡 **Role 1 Overly Broad** |
| **RDS Resources** | None | `rds-data:*` on `*` | 🔴 **Role 2 Broad** |
| **Secrets Manager** | None | GetSecretValue on `foretale/*` | 🟢 **Role 2 Restricted** |

---

### Service-Specific Permissions

#### Role 1: ecs-task-invoker-role-eq44ntlp
- **Enabled Services:**
  - ✅ CloudWatch Logs (basic)
  - ✅ ECS (RunTask)
  - ✅ IAM (PassRole)

- **Missing Services:**
  - ❌ RDS
  - ❌ Secrets Manager
  - ❌ EC2 (VPC)

#### Role 2: foretale-dev-lambda-execution-role
- **Enabled Services:**
  - ✅ CloudWatch Logs (comprehensive)
  - ✅ ECS (RunTask, DescribeTasks, StopTask)
  - ✅ IAM (PassRole)
  - ✅ RDS (Data API)
  - ✅ Secrets Manager
  - ✅ EC2 (VPC)

- **Missing Services:**
  - ❌ None (more comprehensive)

---

### Over-Permissioned Access Analysis

| Issue | Role 1 | Role 2 | Severity |
|-------|--------|--------|----------|
| **Unrestricted ECS RunTask** | ✅ Yes - can run any task | ✅ Yes - can run any task | 🔴 **CRITICAL** |
| **Unrestricted IAM PassRole** | ✅ Yes - with condition only | ❌ No - scoped to 2 roles | 🟡 **HIGH** |
| **Unrestricted RDS Access** | N/A | ✅ Yes - all RDS operations | 🔴 **HIGH** |
| **CloudWatch Log Scope** | 🟡 Specific to ecs-task-invoker | 🟢 Comprehensive VPC + Logs | 🟢 **GOOD** |

---

## 5️⃣ Role Configuration

### Basic Configuration

| Aspect | Role 1 | Role 2 | 
|--------|--------|--------|
| **Role Name** | `ecs-task-invoker-role-eq44ntlp` | `foretale-dev-lambda-execution-role` |
| **Role Path** | `/service-role/` | `/` (root) |
| **Max Session Duration** | 3600 seconds (1 hour) | 3600 seconds (1 hour) |
| **ARN** | `arn:aws:iam::442426872653:role/service-role/ecs-task-invoker-role-eq44ntlp` | `arn:aws:iam::442426872653:role/foretale-dev-lambda-execution-role` |
| **Created Date** | May 21, 2025 (06:45:53 UTC) | January 20, 2026 (18:52:30 UTC) |
| **Account ID** | 442426872653 | 442426872653 |

### Tags

#### Role 1: ecs-task-invoker-role-eq44ntlp
- **Tags:** None

#### Role 2: foretale-dev-lambda-execution-role
- **Tags:**
  - `Application`: ForeTale
  - `CostCenter`: Engineering
  - `Name`: foretale-dev-lambda-execution-role
  - `Compliance`: None
  - `Owner`: DevOps Team
  - `Environment`: (present)

**Observation:** Role 2 is better tagged for organizational tracking and billing allocation.

### Permissions Boundary

| Role | Boundary Policy | Status |
|------|-----------------|--------|
| **Role 1** | None | ✅ No boundary |
| **Role 2** | None | ✅ No boundary |

---

## 📊 Summary Table

| Category | Role 1 | Role 2 | Winner |
|----------|--------|--------|--------|
| **Trust Relationships** | Identical | Identical | 🟢 **TIE** |
| **Managed Policies** | 1 custom | 1 AWS managed | ⚠️ **Different Purpose** |
| **Inline Policies** | 1 (ECS focused) | 2 (ECS + RDS) | 📌 **Different Scope** |
| **Tagging** | None | 6 tags | 🟢 **Role 2 Better** |
| **Permission Scope** | Basic | Comprehensive | 🟢 **Role 2 More Complete** |
| **VPC Support** | No | Yes | 🟢 **Role 2** |
| **Database Support** | No | Yes | 🟢 **Role 2** |
| **Secrets Mgmt** | No | Yes | 🟢 **Role 2** |

---

## 🚨 Security Recommendations

### Critical Issues

1. **Unrestricted ECS RunTask in Both Roles**
   - ⚠️ **Issue:** Both roles allow `ecs:RunTask` on `*` resources
   - **Risk:** Can launch any task in any cluster
   - **Recommendation:** Restrict to specific cluster ARNs
   ```json
   "Resource": [
     "arn:aws:ecs:us-east-2:442426872653:cluster/foretale-*",
     "arn:aws:ecs:us-east-2:442426872653:task-definition/foretale-*:*"
   ]
   ```

2. **Unrestricted RDS Data API Access (Role 2)**
   - ⚠️ **Issue:** `rds-data:*` allowed on all resources
   - **Risk:** Can execute any SQL statement on any Aurora cluster
   - **Recommendation:** Restrict to specific database ARNs

3. **Unrestricted IAM PassRole (Role 1)**
   - ⚠️ **Issue:** `iam:PassRole` on `*` with weak condition
   - **Risk:** Could potentially pass elevated roles
   - **Recommendation:** Migrate to Role 2's approach - scope to specific roles

### Moderate Issues

4. **CloudWatch Log Groups - Path Differences (Role 1)**
   - ⚠️ **Issue:** Role 1 logs to region-specific path `/aws/lambda/ecs-task-invoker`
   - ⚠️ **Issue:** Role 1 is region-locked to us-east-1
   - **Recommendation:** Make role portable across regions

5. **Missing Tags on Role 1**
   - ⚠️ **Issue:** Role 1 has no tags for cost allocation
   - **Recommendation:** Add tags matching Role 2's tagging scheme

---

## 🎯 Key Findings

### Strengths of Role 1
- ✅ Focused, minimal permissions
- ✅ Region-specific CloudWatch logging
- ✅ Simple inline policy

### Weaknesses of Role 1
- ❌ No VPC access
- ❌ No database capabilities
- ❌ No secrets management
- ❌ Overly broad IAM PassRole
- ❌ No organizational tags
- ❌ Region-locked permissions

### Strengths of Role 2
- ✅ Comprehensive AWS managed policy (VPC + Logs)
- ✅ RDS Data API support
- ✅ Secrets Manager integration
- ✅ More restrictive IAM PassRole scoping
- ✅ Comprehensive tagging
- ✅ Portable across resources

### Weaknesses of Role 2
- ❌ Overly broad ECS RunTask (same as Role 1)
- ❌ Overly broad RDS Data API access
- ❌ Comprehensive permissions may be more than needed

---

## 💡 Conclusion

**Role 2 (`foretale-dev-lambda-execution-role`)** is more comprehensive and production-ready for a modern Lambda-based application with:
- Database access requirements
- Secrets management needs
- VPC execution requirements
- Better security boundaries on IAM PassRole
- Proper organizational tagging

**Role 1 (`ecs-task-invoker-role-eq44ntlp`)** appears to be a legacy role focused solely on ECS task invocation without broader application requirements.

**Recommendation:** Migrate any remaining functions using Role 1 to the comprehensive Role 2, but first implement least-privilege refinements on both roles' ECS and RDS permissions.
