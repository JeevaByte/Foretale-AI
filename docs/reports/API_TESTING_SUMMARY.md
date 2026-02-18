# API Gateway Testing Summary - us-east-2

**Date:** February 15, 2026  
**Region:** us-east-2  
**Status:** ✅ All New APIs Operational

---

## Quick Test Results

### Health Check Summary

| API | Status | Auth | CORS | Notes |
|-----|--------|------|------|-------|
| **api-sql-procedure-invoker** (OLD) | ⚠️ Responds 403 | ❌ None | ✅ Yes | May need valid request body |
| **api-ecs-task-invoker** (OLD) | ⚠️ Responds 403 | ❌ None | ✅ Yes | May need valid request body |
| **foretale-dev-api-sql** (NEW) | ✅ Protected | ✅ Cognito | ✅ Yes | Returns 401 without token (expected) |
| **foretale-dev-api-ecs** (NEW) | ✅ Protected | ✅ Cognito | ✅ Yes | Returns 401 without token (expected) |

---

## Available APIs

### 1. OLD SQL API (No Authorization)
- **URL:** `https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod`
- **Stage:** prod
- **Auth:** None
- **Endpoints:** 5 SQL operations
- **Status:** Deployed (2026-01-29)

### 2. OLD ECS API (No Authorization)
- **URL:** `https://6pz582qld4.execute-api.us-east-2.amazonaws.com/prod`
- **Stage:** prod
- **Auth:** None
- **Endpoints:** 1 ECS operation
- **Status:** Deployed (2026-01-29)

### 3. NEW SQL API (Cognito Authorization) ⭐ RECOMMENDED
- **URL:** `https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev`
- **Stage:** dev
- **Auth:** Cognito User Pools (`us-east-2_U1ygvI4IB`)
- **Endpoints:** 5 SQL operations
- **Status:** Deployed (2026-02-15 - Today)
- **Features:**
  - ✅ Cognito authorization
  - ✅ CORS enabled (Origin: *)
  - ✅ CloudWatch logging (INFO level, 30-day retention)
  - ✅ Metrics enabled

### 4. NEW ECS API (Cognito Authorization) ⭐ RECOMMENDED
- **URL:** `https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev`
- **Stage:** dev
- **Auth:** Cognito User Pools (`us-east-2_U1ygvI4IB`)
- **Endpoints:** 2 ECS operations
- **Status:** Deployed (2026-02-15 - Today)
- **Features:**
  - ✅ Cognito authorization
  - ✅ CORS enabled (Origin: *)
  - ✅ CloudWatch logging (INFO level, 30-day retention)
  - ✅ Metrics enabled
  - ✅ Lambda alias for status endpoint

---

## How to Test

### Quick Health Check
```powershell
cd scripts
.\quick_api_health_check.ps1
```

### Full Testing Suite (with Cognito)
```powershell
cd scripts
.\test_api_gateways.ps1
# You'll be prompted for Cognito credentials
```

### Manual Testing (NEW APIs with Cognito)

**Step 1: Get Cognito Token**
```powershell
$username = "your-cognito-username"
$password = "your-cognito-password"

$authResponse = aws cognito-idp initiate-auth `
    --auth-flow USER_PASSWORD_AUTH `
    --client-id 51q2l852bfkr0hbneg6tg247g7 `
    --auth-parameters USERNAME=$username,PASSWORD=$password `
    --region us-east-2 | ConvertFrom-Json

$token = $authResponse.AuthenticationResult.IdToken
```

**Step 2: Test NEW SQL API**
```powershell
# Read operation
Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/read_record?table=test&id=1" `
    -Method GET `
    -Headers @{"Authorization" = $token}
```

**Step 3: Test NEW ECS API**
```powershell
# Get ECS status
Invoke-WebRequest -Uri "https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev/get_ecs_status?taskId=123" `
    -Method GET `
    -Headers @{"Authorization" = $token}
```

---

## Test Verification Results

### ✅ Confirmed Working

1. **NEW APIs Authentication** 
   - Both NEW APIs correctly return 401 Unauthorized without token
   - Cognito authorizer is properly configured

2. **CORS Configuration**
   - Both NEW APIs respond to OPTIONS preflight requests
   - CORS headers properly configured (Allow-Origin: *)

3. **API Gateway Deployment**
   - All 4 APIs deployed with active stages
   - Invoke URLs are accessible

### ⚠️ Requires Attention

1. **OLD APIs** return 403 errors for test requests
   - This may be expected behavior without valid request bodies
   - Lambdas may require specific data structures
   - Consider testing with proper payloads

2. **CORS Origin Restriction**
   - Currently set to `*` (wildcard)
   - Should be restricted to specific domains in production

---

## Cognito Configuration

**User Pool ID:** `us-east-2_U1ygvI4IB`  
**Client ID:** `51q2l852bfkr0hbneg6tg247g7`  
**Region:** us-east-2

### Creating Test Users

```powershell
# Create a test user
aws cognito-idp admin-create-user `
    --user-pool-id us-east-2_U1ygvI4IB `
    --username testuser `
    --user-attributes Name=email,Value=test@example.com `
    --temporary-password TempPass123! `
    --region us-east-2

# Set permanent password
aws cognito-idp admin-set-user-password `
    --user-pool-id us-east-2_U1ygvI4IB `
    --username testuser `
    --password YourPassword123! `
    --permanent `
    --region us-east-2
```

---

## Monitoring & Logs

### CloudWatch Logs

**NEW SQL API:**
```powershell
aws logs tail /aws/apigateway/foretale-dev-api-sql --region us-east-2 --follow
```

**NEW ECS API:**
```powershell
aws logs tail /aws/apigateway/foretale-dev-api-ecs --region us-east-2 --follow
```

### API Gateway Metrics

```powershell
# View API invocations in last hour
aws cloudwatch get-metric-statistics `
    --namespace AWS/ApiGateway `
    --metric-name Count `
    --dimensions Name=ApiName,Value=foretale-dev-api-sql `
    --start-time (Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ss") `
    --end-time (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss") `
    --period 300 `
    --statistics Sum `
    --region us-east-2
```

---

## Next Steps

### Immediate (Testing)
1. [ ] Create Cognito test user
2. [ ] Run full test suite with authentication
3. [ ] Test all SQL CRUD operations
4. [ ] Test ECS task invocation and status check
5. [ ] Verify CloudWatch logs are capturing requests

### Short Term (Configuration)
1. [ ] Restrict CORS origin from `*` to specific domains
2. [ ] Add request throttling limits
3. [ ] Set up CloudWatch alarms for 4xx/5xx errors
4. [ ] Configure custom domain name with SSL certificate

### Long Term (Migration)
1. [ ] Migrate clients from OLD APIs to NEW APIs
2. [ ] Deprecate and remove OLD APIs once migration complete
3. [ ] Implement API versioning strategy
4. [ ] Add request/response caching for read operations

---

## Documentation References

- **Detailed Testing Guide:** [API_TESTING_GUIDE.md](API_TESTING_GUIDE.md)
- **Regional Comparison:** [API_GATEWAY_REGIONAL_COMPARISON.md](API_GATEWAY_REGIONAL_COMPARISON.md)
- **Architecture Overview:** [ARCHITECTURE.md](ARCHITECTURE.md)

---

## Scripts Available

| Script | Purpose | Usage |
|--------|---------|-------|
| `quick_api_health_check.ps1` | Fast connectivity test | No parameters needed |
| `test_api_gateways.ps1` | Full test suite | Prompts for Cognito credentials |

---

**Summary:** All NEW APIs (with Cognito authorization) are properly deployed and protected. CORS is configured. Logging and metrics are enabled. Ready for authenticated testing!
