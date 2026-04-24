# API Gateway Testing Guide - us-east-2 Region

## Overview

This guide covers testing all **four API Gateways** deployed in **us-east-2**:

1. **api-sql-procedure-invoker** (OLD) - No auth, prod stage
2. **api-ecs-task-invoker** (OLD) - No auth, prod stage  
3. **foretale-dev-api-sql** (NEW) - Cognito auth, dev stage
4. **foretale-dev-api-ecs** (NEW) - Cognito auth, dev stage

---

## Quick Start

### Option 1: Automated Testing Script

```powershell
# Navigate to scripts directory
cd scripts

# Run full test suite with Cognito authentication
.\test_api_gateways.ps1

# Skip Cognito-protected APIs (test only OLD APIs without auth)
.\test_api_gateways.ps1 -SkipCognito

# Provide credentials via parameters
.\test_api_gateways.ps1 -CognitoUsername "your-user" -CognitoPassword "your-pass"
```

The script will:
- ✅ Test all endpoints on all APIs
- ✅ Check CORS configuration
- ✅ Measure response times
- ✅ Authenticate with Cognito (for NEW APIs)
- ✅ Generate detailed test report
- ✅ Export results to CSV

---

## API Inventory

### 1. OLD SQL API (No Authorization)

**Details:**
- **Name:** `api-sql-procedure-invoker`
- **ID:** `c52bhyyc4c`
- **Stage:** `prod`
- **Base URL:** `https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod`
- **Authorization:** ❌ None (open)
- **Created:** 2026-01-29

**Endpoints:**
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/insert_record` | Insert data into SQL table |
| GET | `/read_record` | Read data from SQL table |
| PUT | `/update_record` | Update existing SQL record |
| DELETE | `/delete_record` | Delete SQL record |
| GET | `/read_json_record` | Read JSON-formatted SQL record |

### 2. OLD ECS API (No Authorization)

**Details:**
- **Name:** `api-ecs-task-invoker`
- **ID:** `6pz582qld4`
- **Stage:** `prod`
- **Base URL:** `https://6pz582qld4.execute-api.us-east-2.amazonaws.com/prod`
- **Authorization:** ❌ None (open)
- **Created:** 2026-01-29

**Endpoints:**
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/ecs_invoker_resource` | Invoke ECS task |

### 3. NEW SQL API (Cognito Authorization)

**Details:**
- **Name:** `foretale-dev-api-sql`
- **ID:** `wisvlsk9we`
- **Stage:** `dev`
- **Base URL:** `https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev`
- **Authorization:** ✅ Cognito User Pools (`us-east-2_U1ygvI4IB`)
- **Created:** 2026-02-15 (Today)
- **Logging:** Enabled (INFO level, 30-day retention)

**Endpoints:**
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/insert_record` | Insert data into SQL table |
| GET | `/read_record` | Read data from SQL table |
| PUT | `/update_record` | Update existing SQL record |
| DELETE | `/delete_record` | Delete SQL record |
| GET | `/read_json_record` | Read JSON-formatted SQL record |

### 4. NEW ECS API (Cognito Authorization)

**Details:**
- **Name:** `foretale-dev-api-ecs`
- **ID:** `escemsrkl3`
- **Stage:** `dev`
- **Base URL:** `https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev`
- **Authorization:** ✅ Cognito User Pools (`us-east-2_U1ygvI4IB`)
- **Created:** 2026-02-15 (Today)
- **Logging:** Enabled (INFO level, 30-day retention)

**Endpoints:**
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/ecs_invoker_resource` | Invoke ECS task |
| GET | `/get_ecs_status` | Get ECS task status |

---

## Manual Testing

### Prerequisites

**For OLD APIs (No Auth):**
- ✅ Any HTTP client (curl, Postman, PowerShell)

**For NEW APIs (Cognito Auth):**
- ✅ Valid Cognito user credentials
- ✅ Cognito User Pool ID: `us-east-2_U1ygvI4IB`
- ✅ Client ID: `51q2l852bfkr0hbneg6tg247g7`

---

### Step 1: Get Cognito Token (NEW APIs Only)

```powershell
# Authenticate with Cognito
$username = "your-cognito-username"
$password = "your-cognito-password"

$authResponse = aws cognito-idp initiate-auth `
    --auth-flow USER_PASSWORD_AUTH `
    --client-id 51q2l852bfkr0hbneg6tg247g7 `
    --auth-parameters USERNAME=$username,PASSWORD=$password `
    --region us-east-2 | ConvertFrom-Json

$token = $authResponse.AuthenticationResult.IdToken
Write-Output "Token: $token"
```

**Alternative using AWS CLI:**
```bash
aws cognito-idp initiate-auth \
    --auth-flow USER_PASSWORD_AUTH \
    --client-id 51q2l852bfkr0hbneg6tg247g7 \
    --auth-parameters USERNAME=your-user,PASSWORD=your-pass \
    --region us-east-2
```

---

### Step 2: Test OLD APIs (No Authorization)

#### Test OLD SQL API - Insert Record

```powershell
$body = @{
    table = "test_table"
    data = @{
        name = "Test Record"
        value = 123
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod/insert_record" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body $body
```

#### Test OLD SQL API - Read Record

```powershell
Invoke-WebRequest -Uri "https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod/read_record?table=test_table&id=1" `
    -Method GET
```

#### Test OLD ECS API - Invoke Task

```powershell
$body = @{
    task = "my-ecs-task"
    parameters = @{
        key1 = "value1"
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://6pz582qld4.execute-api.us-east-2.amazonaws.com/prod/ecs_invoker_resource" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body $body
```

---

### Step 3: Test NEW APIs (With Cognito Authorization)

**Important:** Replace `$token` with your Cognito ID token from Step 1.

#### Test NEW SQL API - Insert Record

```powershell
$body = @{
    table = "test_table"
    data = @{
        name = "Test Record"
        value = 123
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/insert_record" `
    -Method POST `
    -Headers @{
        "Content-Type" = "application/json"
        "Authorization" = $token
    } `
    -Body $body
```

#### Test NEW SQL API - Read Record

```powershell
Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/read_record?table=test_table&id=1" `
    -Method GET `
    -Headers @{"Authorization" = $token}
```

#### Test NEW SQL API - Update Record

```powershell
$body = @{
    table = "test_table"
    id = 1
    data = @{
        name = "Updated Record"
        value = 456
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/update_record" `
    -Method PUT `
    -Headers @{
        "Content-Type" = "application/json"
        "Authorization" = $token
    } `
    -Body $body
```

#### Test NEW SQL API - Delete Record

```powershell
$body = @{
    table = "test_table"
    id = 1
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/delete_record" `
    -Method DELETE `
    -Headers @{
        "Content-Type" = "application/json"
        "Authorization" = $token
    } `
    -Body $body
```

#### Test NEW ECS API - Invoke Task

```powershell
$body = @{
    task = "my-ecs-task"
    parameters = @{
        key1 = "value1"
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev/ecs_invoker_resource" `
    -Method POST `
    -Headers @{
        "Content-Type" = "application/json"
        "Authorization" = $token
    } `
    -Body $body
```

#### Test NEW ECS API - Get Task Status

```powershell
Invoke-WebRequest -Uri "https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev/get_ecs_status?taskId=your-task-id" `
    -Method GET `
    -Headers @{"Authorization" = $token}
```

---

### Step 4: Test CORS Preflight (All APIs)

```powershell
# Test NEW SQL API CORS
Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/insert_record" `
    -Method OPTIONS `
    -Headers @{
        "Origin" = "https://example.com"
        "Access-Control-Request-Method" = "POST"
        "Access-Control-Request-Headers" = "content-type,authorization"
    }
```

**Expected CORS Headers:**
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: OPTIONS,POST` (or relevant method)
- `Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token`

---

## Testing with cURL

### OLD SQL API (No Auth)

```bash
# Insert record
curl -X POST https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod/insert_record \
  -H "Content-Type: application/json" \
  -d '{"table":"test_table","data":{"name":"Test","value":123}}'

# Read record
curl -X GET "https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod/read_record?table=test_table&id=1"
```

### NEW SQL API (With Auth)

```bash
# Get token first
TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id 51q2l852bfkr0hbneg6tg247g7 \
  --auth-parameters USERNAME=your-user,PASSWORD=your-pass \
  --region us-east-2 \
  --query 'AuthenticationResult.IdToken' \
  --output text)

# Insert record with token
curl -X POST https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/insert_record \
  -H "Content-Type: application/json" \
  -H "Authorization: $TOKEN" \
  -d '{"table":"test_table","data":{"name":"Test","value":123}}'

# Read record with token
curl -X GET "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/read_record?table=test_table&id=1" \
  -H "Authorization: $TOKEN"
```

---

## Testing with Postman

### Collection Setup

**1. Create Environment:**
```
OLD_SQL_URL: https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod
OLD_ECS_URL: https://6pz582qld4.execute-api.us-east-2.amazonaws.com/prod
NEW_SQL_URL: https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev
NEW_ECS_URL: https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev
COGNITO_TOKEN: <paste your token here>
```

**2. Create Requests:**

- **OLD SQL - Insert:** POST `{{OLD_SQL_URL}}/insert_record`
- **NEW SQL - Insert:** POST `{{NEW_SQL_URL}}/insert_record` 
  - Add header: `Authorization: {{COGNITO_TOKEN}}`
- **NEW ECS - Invoke:** POST `{{NEW_ECS_URL}}/ecs_invoker_resource`
  - Add header: `Authorization: {{COGNITO_TOKEN}}`

---

## Expected Responses

### Success Responses

**SQL Insert (200 OK):**
```json
{
  "statusCode": 200,
  "message": "Record inserted successfully",
  "recordId": 123
}
```

**SQL Read (200 OK):**
```json
{
  "statusCode": 200,
  "data": {
    "id": 1,
    "name": "Test Record",
    "value": 123
  }
}
```

**ECS Invoke (200 OK):**
```json
{
  "statusCode": 200,
  "taskArn": "arn:aws:ecs:us-east-2:...",
  "status": "PENDING"
}
```

### Error Responses

**Missing Authorization (401 Unauthorized):**
```json
{
  "message": "Unauthorized"
}
```

**Invalid Token (403 Forbidden):**
```json
{
  "message": "User is not authorized to access this resource"
}
```

**Lambda Error (502 Bad Gateway):**
```json
{
  "message": "Internal server error"
}
```

---

## Monitoring Test Results

### Check CloudWatch Logs (NEW APIs Only)

```powershell
# SQL API logs
aws logs tail /aws/apigateway/foretale-dev-api-sql --region us-east-2 --follow

# ECS API logs
aws logs tail /aws/apigateway/foretale-dev-api-ecs --region us-east-2 --follow
```

### Check API Gateway Metrics

```powershell
# Get recent invocation count for NEW SQL API
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

## Troubleshooting

### Issue: 401 Unauthorized on NEW APIs

**Cause:** Missing or invalid Cognito token

**Solution:**
1. Verify you're using the correct Cognito credentials
2. Ensure the token hasn't expired (default: 1 hour)
3. Get a fresh token using the authentication command
4. Check token is in `Authorization` header (not `Bearer` prefix needed)

### Issue: 403 Forbidden on NEW APIs

**Cause:** Valid token but user not authorized

**Solution:**
1. Verify user exists in Cognito pool `us-east-2_U1ygvI4IB`
2. Check user is in correct Cognito groups (if applicable)
3. Verify authorizer configuration on API Gateway

### Issue: CORS Errors in Browser

**Cause:** Missing CORS headers

**Solution:**
1. Verify OPTIONS method returns proper CORS headers
2. Check `Access-Control-Allow-Origin` is present
3. Ensure preflight request succeeds before actual request

### Issue: Connection Timeout

**Cause:** Lambda function timeout or cold start

**Solution:**
1. Check Lambda function timeout settings (should be 900s)
2. Wait for Lambda warm-up and retry
3. Check VPC security groups allow Lambda → RDS connection

### Issue: 502 Bad Gateway

**Cause:** Lambda function error

**Solution:**
1. Check Lambda CloudWatch logs:
   ```powershell
   aws logs tail /aws/foretale-app/lambda/main --region us-east-2 --follow
   ```
2. Verify RDS connection string is correct
3. Check Secrets Manager access (IAM permissions)

---

## Performance Testing

### Load Test with ApacheBench

```bash
# Test OLD SQL API (no auth)
ab -n 100 -c 10 -p body.json -T application/json \
  https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod/insert_record

# Test NEW SQL API (with auth - requires token in header file)
ab -n 100 -c 10 -H "Authorization: YOUR_TOKEN" -p body.json -T application/json \
  https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/insert_record
```

### Measure Response Times

```powershell
$times = @()
1..10 | ForEach-Object {
    $start = Get-Date
    Invoke-WebRequest -Uri "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/read_record" `
        -Headers @{"Authorization"=$token} -UseBasicParsing | Out-Null
    $duration = (Get-Date) - $start
    $times += $duration.TotalMilliseconds
}

Write-Output "Average: $([math]::Round(($times | Measure-Object -Average).Average, 2))ms"
Write-Output "Min: $([math]::Round(($times | Measure-Object -Minimum).Minimum, 2))ms"
Write-Output "Max: $([math]::Round(($times | Measure-Object -Maximum).Maximum, 2))ms"
```

---

## Cleanup After Testing

```powershell
# Delete test records from database (if needed)
# Run SQL cleanup via Lambda or direct RDS connection
```

---

## Summary Checklist

- [ ] Get Cognito token for NEW APIs
- [ ] Test OLD SQL API endpoints (no auth)
- [ ] Test OLD ECS API endpoint (no auth)
- [ ] Test NEW SQL API endpoints (with Cognito)
- [ ] Test NEW ECS API endpoints (with Cognito)
- [ ] Verify CORS on all APIs
- [ ] Check CloudWatch logs for errors
- [ ] Monitor API Gateway metrics
- [ ] Performance test critical endpoints
- [ ] Document any issues or unexpected behavior

---

**Last Updated:** February 15, 2026  
**Region:** us-east-2  
**Related Files:**
- [test_api_gateways.ps1](../scripts/test_api_gateways.ps1) - Automated test script
- [API_GATEWAY_REGIONAL_COMPARISON.md](API_GATEWAY_REGIONAL_COMPARISON.md) - Architecture comparison
