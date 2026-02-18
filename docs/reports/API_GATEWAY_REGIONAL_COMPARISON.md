# API Gateway Regional Comparison
**Date:** February 15, 2026  
**Comparison:** us-east-2 (Dev) vs us-east-1 (Production)

---

## Executive Summary

This document compares the new split API architecture in **us-east-2** (development) with the private API in **us-east-1** (production), analyzing endpoint types, security configurations, Lambda integrations, and operational features.

### Key Findings

| Feature | us-east-2 (New) | us-east-1 (Private) |
|---------|----------------|---------------------|
| **Architecture** | Split APIs (SQL + ECS) | Single API |
| **Authorization** | **Cognito User Pools** ✅ | **None** ⚠️ |
| **Endpoint Type** | **REGIONAL** | **PRIVATE** |
| **CORS Support** | **OPTIONS methods on all routes** ✅ | **OPTIONS methods on all routes** ✅ |
| **Deployment Status** | **Active** (deployed to dev stage) ✅ | **Not Deployed** ⚠️ |
| **CloudWatch Logging** | **Enabled** (INFO level, 30-day retention) ✅ | **Not configured** ⚠️ |
| **Metrics** | **Enabled** ✅ | **Not configured** ⚠️ |
| **VPC Configuration** | N/A (Regional) | **No VPC endpoints configured** ⚠️ |

---

## 1. API Overview

### 1.1 us-east-2 APIs (REGIONAL - Deployed)

#### **SQL API**
- **Name:** `foretale-dev-api-sql`
- **ID:** `wisvlsk9we`
- **Description:** REST API for SQL database operations
- **Endpoint Type:** **REGIONAL**
- **Created:** 2026-02-15T20:00:34+00:00
- **Stage:** `dev`
- **Base URL:** `https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev`
- **Authorization:** **Cognito User Pool** (`us-east-2_U1ygvI4IB`)
- **TLS Version:** TLS 1.0

#### **ECS API**
- **Name:** `foretale-dev-api-ecs`
- **ID:** `escemsrkl3`
- **Description:** REST API for ECS task operations
- **Endpoint Type:** **REGIONAL**
- **Created:** 2026-02-15T20:00:34+00:00
- **Stage:** `dev`
- **Base URL:** `https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev`
- **Authorization:** **Cognito User Pool** (`us-east-2_U1ygvI4IB`)
- **TLS Version:** TLS 1.0

### 1.2 us-east-1 API (PRIVATE - Not Deployed)

#### **Private SQL API**
- **Name:** `api-sql-procedure-invoker-private`
- **ID:** `y6pniymc5h`
- **Description:** An API to invoke the SQL Server procedures using the lambda function
- **Endpoint Type:** **PRIVATE**
- **Created:** 2026-02-02T20:29:49+00:00
- **Stage:** **None** (Not deployed)
- **Base URL:** N/A (No active deployment)
- **Authorization:** **None** ⚠️
- **VPC Endpoints:** **None configured** ⚠️
- **TLS Version:** TLS 1.2

---

## 2. Endpoint Comparison

### 2.1 SQL Operations Endpoints

#### **us-east-2 SQL API** (wisvlsk9we)

| Path | Method | Auth | Integration | Lambda Function |
|------|--------|------|-------------|----------------|
| `/insert_record` | POST | **COGNITO_USER_POOLS** | AWS_PROXY | `calling-sql-procedure` |
| `/insert_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/update_record` | PUT | **COGNITO_USER_POOLS** | AWS_PROXY | `calling-sql-procedure` |
| `/update_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/delete_record` | DELETE | **COGNITO_USER_POOLS** | AWS_PROXY | `calling-sql-procedure` |
| `/delete_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/read_record` | GET | **COGNITO_USER_POOLS** | AWS_PROXY | `calling-sql-procedure` |
| `/read_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/read_json_record` | GET | **COGNITO_USER_POOLS** | AWS_PROXY | `calling-sql-procedure` |
| `/read_json_record` | OPTIONS | NONE | MOCK | N/A (CORS) |

**Total Endpoints:** 10 (5 functional + 5 CORS)

#### **us-east-1 Private SQL API** (y6pniymc5h)

| Path | Method | Auth | Integration | Lambda Function |
|------|--------|------|-------------|----------------|
| `/insert_record` | POST | **NONE** ⚠️ | AWS_PROXY | `calling-sql-procedure` |
| `/insert_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/update_record` | PUT | **NONE** ⚠️ | AWS_PROXY | `calling-sql-procedure` |
| `/update_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/delete_record` | DELETE | **NONE** ⚠️ | AWS_PROXY | `calling-sql-procedure` |
| `/delete_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/read_record` | GET | **NONE** ⚠️ | AWS_PROXY | `calling-sql-procedure` |
| `/read_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/read_json_record` | GET | **NONE** ⚠️ | AWS_PROXY | `calling-sql-procedure` |
| `/read_json_record` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/upload_data_sql_by_batch` | POST | **NONE** ⚠️ | AWS_PROXY | `sql-server-data-upload` |
| `/upload_data_sql_by_batch` | OPTIONS | NONE | MOCK | N/A (CORS) |

**Total Endpoints:** 12 (6 functional + 6 CORS)

**Key Differences:**
- ❌ **No authorization** on any endpoints in us-east-1
- ✅ us-east-1 has additional `/upload_data_sql_by_batch` endpoint (not in us-east-2)
- ✅ us-east-2 uses **single Lambda** (`calling-sql-procedure`) for all SQL operations
- ✅ us-east-1 uses **two Lambdas**: `calling-sql-procedure` + `sql-server-data-upload`

### 2.2 ECS Operations Endpoints

#### **us-east-2 ECS API** (escemsrkl3)

| Path | Method | Auth | Integration | Lambda Function |
|------|--------|------|-------------|----------------|
| `/ecs_invoker_resource` | POST | **COGNITO_USER_POOLS** | AWS_PROXY | `foretale-app-lambda-ecs-invoker` |
| `/ecs_invoker_resource` | OPTIONS | NONE | MOCK | N/A (CORS) |
| `/get_ecs_status` | GET | **COGNITO_USER_POOLS** | AWS_PROXY | `foretale-app-lambda-ecs-invoker:get-ecs-task-status` (alias) |
| `/get_ecs_status` | OPTIONS | NONE | MOCK | N/A (CORS) |

**Total Endpoints:** 4 (2 functional + 2 CORS)

#### **us-east-1 Private SQL API** (y6pniymc5h)
- **No ECS endpoints** - ECS operations not present in us-east-1 private API

**Key Differences:**
- ✅ ECS operations only exist in us-east-2 split architecture
- ✅ us-east-2 uses Lambda alias (`get-ecs-task-status`) for status checking

---

## 3. Authorization & Security

### 3.1 us-east-2 APIs (REGIONAL)

#### **Cognito Authorization**
- **Type:** `COGNITO_USER_POOLS`
- **User Pool ARN:** `arn:aws:cognito-idp:us-east-2:442426872653:userpool/us-east-2_U1ygvI4IB`
- **User Pool ID:** `us-east-2_U1ygvI4IB`
- **Applied to:** All SQL and ECS functional endpoints (POST, PUT, DELETE, GET methods)
- **Authorizer Name:** `foretale-dev-cognito-authorizer`

**Security Benefits:**
- ✅ JWT token validation on all requests
- ✅ User identity available in Lambda context
- ✅ Scoped access control via Cognito groups
- ✅ Federated identity support
- ✅ Token expiration and refresh handling

#### **CORS Configuration**
- **Enabled:** Yes (OPTIONS methods on all resources)
- **Headers:** `Content-Type, X-Amz-Date, Authorization, X-Api-Key, X-Amz-Security-Token`
- **Methods:** Resource-specific (GET, POST, PUT, DELETE)
- **Origin:** `*` (wildcard - should be restricted in production)

### 3.2 us-east-1 API (PRIVATE)

#### **Authorization**
- **Type:** `NONE` ⚠️
- **Risk Level:** **HIGH** - No authentication or authorization
- **VPC Isolation:** Configured as PRIVATE endpoint type but **no VPC endpoints attached**

**Security Concerns:**
- ❌ **No authentication** - Anyone with network access can invoke
- ❌ **No VPC endpoints configured** - PRIVATE endpoint type ineffective
- ❌ **Not deployed** - API exists but not accessible (missing deployment + stage)
- ⚠️ If deployed without VPC endpoints, API would be inaccessible (PRIVATE requires VPC endpoint)

#### **CORS Configuration**
- **Enabled:** Yes (OPTIONS methods on all resources)
- **Headers:** Likely similar to us-east-2 (needs verification when deployed)

---

## 4. Lambda Integration Patterns

### 4.1 us-east-2 SQL API

**Single Lambda Pattern:**
- **Function:** `calling-sql-procedure`
- **Region:** us-east-2
- **Routes:** All SQL CRUD operations route to same Lambda
- **Differentiation:** Lambda determines operation type from HTTP method and path

**Advantages:**
- ✅ Simplified deployment (one function to update)
- ✅ Shared connection pooling and database context
- ✅ Consistent error handling and logging

### 4.2 us-east-1 Private SQL API

**Dual Lambda Pattern:**
- **Function 1:** `calling-sql-procedure` (CRUD operations)
- **Function 2:** `sql-server-data-upload` (batch uploads)
- **Region:** us-east-1
- **Routes:** 
  - Standard CRUD → `calling-sql-procedure`
  - `/upload_data_sql_by_batch` → `sql-server-data-upload`

**Advantages:**
- ✅ Specialized batch upload logic separated from CRUD
- ✅ Independent scaling for batch operations
- ✅ Batch function can have different timeout/memory settings

### 4.3 us-east-2 ECS API

**Lambda Alias Pattern:**
- **Base Function:** `foretale-app-lambda-ecs-invoker`
- **Alias:** `get-ecs-task-status`
- **Routes:**
  - `/ecs_invoker_resource` → base function
  - `/get_ecs_status` → alias
- **Version:** `$LATEST` (both point to latest version currently)

**Advantages:**
- ✅ Supports blue/green deployments via alias shifting
- ✅ Traffic splitting for canary releases
- ✅ Rollback capability by updating alias pointer

---

## 5. Operational Features

### 5.1 CloudWatch Logging

#### **us-east-2 APIs**
| API | Log Group | Retention | Level | Metrics | Data Trace |
|-----|-----------|-----------|-------|---------|------------|
| SQL | `/aws/apigateway/foretale-dev-api-sql` | 30 days | **INFO** | ✅ Enabled | ✅ Enabled |
| ECS | `/aws/apigateway/foretale-dev-api-ecs` | 30 days | **INFO** | ✅ Enabled | ✅ Enabled |

**Logging Configuration:**
- **Access Logging:** Enabled
- **Execution Logging:** Enabled (INFO level)
- **Data Trace:** Enabled (logs request/response payloads)
- **CloudWatch Metrics:** Enabled
- **Throttling:** Default limits (-1 burst, -1 rate)

#### **us-east-1 Private API**
| API | Log Group | Retention | Level | Metrics |
|-----|-----------|-----------|-------|---------|
| Private SQL | **None** | N/A | N/A | ❌ Disabled |

**Status:** No logging configured (API not deployed)

### 5.2 Deployment Status

#### **us-east-2 APIs**
- **SQL API:** ✅ Deployed to `dev` stage
  - Deployment ID: Available
  - Invoke URL: Active
  - Created: 2026-02-15
- **ECS API:** ✅ Deployed to `dev` stage
  - Deployment ID: Available
  - Invoke URL: Active
  - Created: 2026-02-15

#### **us-east-1 Private API**
- **Private SQL API:** ❌ **Not deployed**
  - No deployments found
  - No stages configured
  - No invoke URL available
  - Status: **Created but inactive**

---

## 6. Architecture Comparison Summary

### 6.1 Structural Differences

| Aspect | us-east-2 (Dev) | us-east-1 (Private) |
|--------|----------------|---------------------|
| **API Count** | 2 (SQL + ECS split) | 1 (combined) |
| **SQL Endpoints** | 5 operations | 6 operations (+batch) |
| **ECS Endpoints** | 2 operations | 0 (none) |
| **Total Resources** | 7 (5 SQL + 2 ECS) | 6 (all SQL) |
| **Endpoint Type** | REGIONAL (internet-accessible) | PRIVATE (VPC-only, not configured) |
| **Authorization** | Cognito on all routes | None |
| **Deployment** | Active with dev stage | Not deployed |
| **Logging** | Comprehensive (INFO level) | None configured |

### 6.2 Lambda Backend Comparison

| Lambda Function | us-east-2 | us-east-1 | Purpose |
|-----------------|-----------|-----------|---------|
| `calling-sql-procedure` | ✅ (all SQL ops) | ✅ (CRUD only) | SQL CRUD operations |
| `sql-server-data-upload` | ❌ | ✅ | Batch SQL uploads |
| `foretale-app-lambda-ecs-invoker` | ✅ | ❌ | ECS task invocation |
| `get-ecs-task-status` (alias) | ✅ | ❌ | ECS status checking |

**Key Insight:** us-east-2 has **separated ECS operations** into dedicated API, while us-east-1 never implemented ECS endpoints.

---

## 7. Critical Issues & Recommendations

### 7.1 us-east-1 Private API Issues

#### **🔴 CRITICAL: Not Deployed**
- API resources exist but **no deployment** created
- No stage configured, making API inaccessible
- **Action Required:** Either deploy to VPC-accessible stage or delete if unused

#### **🔴 CRITICAL: No VPC Endpoints**
- Endpoint type is PRIVATE but `vpcEndpointIds` array is empty
- Even if deployed, API would be **inaccessible** without VPC endpoints
- **Action Required:** Configure VPC endpoints or change to REGIONAL/EDGE

#### **🟡 HIGH: No Authorization**
- All endpoints have `authorizationType: NONE`
- If deployed with VPC access, any VPC resource could invoke without auth
- **Action Required:** Add Cognito, IAM, or Lambda authorizer

#### **🟡 HIGH: No Monitoring**
- No CloudWatch logs configured
- No metrics or alarms
- **Action Required:** Enable logging and monitoring before production use

### 7.2 us-east-2 APIs Best Practices

#### **✅ Well-Implemented**
- Cognito authorization on all functional endpoints
- Comprehensive CloudWatch logging (INFO level)
- Metrics and data tracing enabled
- CORS properly configured with OPTIONS methods
- Split architecture separating SQL and ECS concerns
- Active deployment with accessible invoke URLs

#### **⚠️ Recommendations**
1. **Restrict CORS origin** from `*` to specific allowed domains
2. **Enable WAF** for DDoS protection and request filtering
3. **Add request throttling** (currently set to -1 unlimited)
4. **Implement API keys** for additional rate limiting per client
5. **Add response caching** for read-heavy endpoints (`/read_record`, `/read_json_record`)
6. **Configure custom domain** with SSL certificate for production
7. **Set up CloudWatch alarms** for 4xx/5xx errors, latency, throttles

---

## 8. Migration Path: us-east-1 → us-east-2 Pattern

If you want to align us-east-1 with the us-east-2 architecture:

### Step 1: Security Enhancement
```
1. Create Cognito User Pool in us-east-1 (if not exists)
2. Add Cognito authorizer to private API
3. Update all methods to require authorization
```

### Step 2: API Split (Optional)
```
1. Create separate api-ecs-invoker API in us-east-1
2. Move any ECS-related endpoints (if added in future)
3. Keep SQL API focused on database operations
```

### Step 3: Deployment & Monitoring
```
1. If keeping PRIVATE endpoint:
   - Create VPC endpoints for API Gateway
   - Attach VPC endpoint IDs to API configuration
2. If switching to REGIONAL:
   - Update endpoint type to REGIONAL
   - Add Cognito authorization (already done in Step 1)
3. Enable CloudWatch logging (INFO level)
4. Enable metrics and data tracing
5. Create deployment and dev/prod stages
6. Configure custom domain (optional)
```

### Step 4: Lambda Backend Alignment
```
1. Deploy `calling-sql-procedure` if not exists
2. Deploy `foretale-app-lambda-ecs-invoker` for ECS operations
3. Create `get-ecs-task-status` alias
4. Update API integrations to point to new Lambda ARNs
```

---

## 9. Conclusion

The **us-east-2 APIs represent a mature, production-ready architecture** with proper authentication, monitoring, and deployment practices. The split design (SQL + ECS) provides better separation of concerns and scalability.

The **us-east-1 private API is incomplete and insecure** in its current state - created but never deployed, with no authorization and incomplete VPC configuration. It should either be:
1. **Completed and secured** following us-east-2 patterns, OR
2. **Deleted** if replaced by other infrastructure

### Recommended Action Plan
1. ✅ **Keep us-east-2 as reference architecture** for future APIs
2. ⚠️ **Review us-east-1 private API purpose** - deploy properly or delete
3. 🔐 **Never deploy APIs without authorization** in any environment
4. 📊 **Always enable logging and metrics** before production use
5. 🔄 **Consider standardizing** on one regional architecture (us-east-2 pattern)

---

**Document Version:** 1.0  
**Last Updated:** February 15, 2026  
**Author:** Infrastructure Team  
**Related Documents:**
- [AMPLIFY_INTEGRATION_STATUS.md](AMPLIFY_INTEGRATION_STATUS.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [COGNITO_DEPLOYMENT_SUMMARY.md](COGNITO_DEPLOYMENT_SUMMARY.md)
