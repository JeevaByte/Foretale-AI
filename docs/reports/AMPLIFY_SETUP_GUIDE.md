# AWS Amplify Setup for us-east-2 - Complete Guide

## Overview

This guide provides step-by-step instructions to set up AWS Amplify in us-east-2 with backend resources matching the foretaleapplication in us-east-1.

## Current Status

### ✅ Completed
- **Analysis**: Source app configuration documented
- **Cognito**: Identity Pool created (us-east-2:4b9dd439-eae0-4ad7-aae1-1c2ef9a6843a)
- **Lambda**: 8 functions deployed to us-east-2
- **ECR**: 9 repositories created in us-east-2
- **SQS**: Queue created in us-east-2

### ⏳ In Progress
- **Cognito User Pool**: Creating with proper configuration
- **S3 Storage**: Preparing for replication
- **API Gateway**: Imported to us-east-2

---

## Phase 1: Create Cognito User Pool (Manual)

The automated script has issues with AWS CLI parameter formatting. Follow these manual steps:

### Step 1: Create User Pool via Console

```
1. Go to: https://us-east-2.console.aws.amazon.com/cognito/
2. Click "Create user pool"
3. Name: foretaleapplication6f8acf89_userpool_6f8acf89-dev-us-east-2
4. Keep default settings, click "Create"
```

### Step 2: Configure Password Policy

```powershell
# Get the new pool ID first (replace with actual ID)
$POOL_ID = "us-east-2_XXXXX"

aws cognito-idp update-user-pool `
  --user-pool-id $POOL_ID `
  --policies '{
    "PasswordPolicy": {
      "MinimumLength": 8,
      "RequireUppercase": false,
      "RequireLowercase": false,
      "RequireNumbers": false,
      "RequireSymbols": false
    }
  }' `
  --region us-east-2
```

### Step 3: Create User Pool Client

```powershell
aws cognito-idp create-user-pool-client `
  --user-pool-id $POOL_ID `
  --client-name "foreta6f8acf89_app_clientWeb" `
  --explicit-auth-flows "ADMIN_NO_SRP_AUTH" "USER_PASSWORD_AUTH" `
  --supported-identity-providers "COGNITO" `
  --callback-urls "https://yourdomain.com/callback" `
  --logout-urls "https://yourdomain.com/logout" `
  --region us-east-2
```

**Save the returned ClientId for later use.**

### Step 4: Create OAuth Domain (Optional)

```powershell
aws cognito-idp create-user-pool-domain `
  --domain "foretale-app" `
  --user-pool-id $POOL_ID `
  --region us-east-2
```

---

## Phase 2: Setup S3 Storage

Run the automated S3 setup script:

```powershell
.\scripts\setup_amplify_storage.ps1
```

**Key Buckets Created:**
- `foretale-dev-app-storage` → `foretale-dev-app-storage-us-east-2`
- `foretale-dev-user-uploads` → `foretale-dev-user-uploads-us-east-2`
- `foretale-dev-backups` → `foretale-dev-backups-us-east-2`

### Copy Data

```powershell
# Copy main application storage
aws s3 sync s3://foretale-dev-app-storage `
  s3://foretale-dev-app-storage-us-east-2 `
  --region us-east-2

# Copy user uploads
aws s3 sync s3://foretale-dev-user-uploads `
  s3://foretale-dev-user-uploads-us-east-2 `
  --region us-east-2

# Copy backups
aws s3 sync s3://foretale-dev-backups `
  s3://foretale-dev-backups-us-east-2 `
  --region us-east-2
```

---

## Phase 3: Create Amplify App

### Step 1: Create App in Console

```
1. Navigate to: https://us-east-2.console.aws.amazon.com/amplify/
2. Click "Create app"
3. Choose "Host web app"
4. Connect to Git:
   - Repository: https://github.com/bharath-arcot-babu/foretale_application
   - Branch: main
   - App name: foretaleapplication-us-east-2
5. Review build settings and click "Save and deploy"
```

### Step 2: Configure Backend Resources

After app is created:

#### Add Authentication

```
1. In Amplify console, click "Backend" → "Authentication"
2. Click "Create or configure"
3. Select "Cognito" → "Continue"
4. Configure with user pool ID from Phase 1
5. Save
```

#### Add Storage

```
1. Click "Backend" → "Storage"
2. Click "Create or configure"
3. Select "S3" → "Continue"
4. Select bucket: foretale-dev-app-storage-us-east-2
5. Configure permissions for the app
6. Save
```

#### Add API

```
1. Click "Backend" → "API"
2. Click "Create or configure"
3. API type: REST API
4. Select API: api-ecs-task-invoker
5. Configure Lambda integration
6. Save
```

---

## Phase 4: Update Environment Variables

### Backend Environment Variables

Set these in Amplify console (App > Environments):

```
REGION=us-east-2
COGNITO_USER_POOL_ID=us-east-2_XXXXX
COGNITO_CLIENT_ID=XXXXXXXXX
COGNITO_IDENTITY_POOL_ID=us-east-2:XXXXX-XXXXX-XXXXX
STORAGE_BUCKET=foretale-dev-app-storage-us-east-2
API_ENDPOINT=https://API_ID.execute-api.us-east-2.amazonaws.com/prod
API_REGION=us-east-2
LAMBDA_REGION=us-east-2
```

### Frontend Environment Variables

In your Flutter/Web app, update:

```dart
const String awsRegion = 'us-east-2';
const String cognitoUserPoolId = 'us-east-2_XXXXX';
const String cognitoClientId = 'XXXXXXXXX';
const String s3Bucket = 'foretale-dev-app-storage-us-east-2';
const String apiEndpoint = 'https://API_ID.execute-api.us-east-2.amazonaws.com/prod';
```

Or in amplifyconfiguration.json:

```json
{
  "auth": {
    "config": {
      "userPoolId": "us-east-2_XXXXX",
      "userPoolWebClientId": "XXXXXXXXX",
      "region": "us-east-2"
    }
  },
  "storage": {
    "config": {
      "bucket": "foretale-dev-app-storage-us-east-2",
      "region": "us-east-2"
    }
  },
  "api": {
    "config": {
      "endpoint": "https://API_ID.execute-api.us-east-2.amazonaws.com/prod",
      "region": "us-east-2"
    }
  }
}
```

---

## Phase 5: Testing

### Test Cognito Authentication

```powershell
# Initiate auth
aws cognito-idp admin-initiate-auth `
  --user-pool-id us-east-2_XXXXX `
  --client-id XXXXXXXXX `
  --auth-flow ADMIN_NO_SRP_AUTH `
  --auth-parameters USERNAME=testuser,PASSWORD=TestPass123 `
  --region us-east-2
```

### Test S3 Access

```powershell
# List bucket contents
aws s3 ls s3://foretale-dev-app-storage-us-east-2 --region us-east-2

# Upload test file
aws s3 cp test.txt s3://foretale-dev-app-storage-us-east-2/ --region us-east-2
```

### Test API Gateway

```powershell
# Test Lambda invocation via API
$API_URL = "https://API_ID.execute-api.us-east-2.amazonaws.com/prod/YOUR_PATH"

Invoke-WebRequest -Uri $API_URL `
  -Headers @{"Authorization"="Bearer YOUR_TOKEN"} `
  -Method GET
```

### Test Amplify Deployment

```
1. Go to Amplify console
2. Check Amplify Frontend > Deployments
3. Should show successful build for main branch
4. Test the live URL: https://main.XXXXX.amplifyapp.com
```

---

## Configuration Files

### Generated Files

- `scripts/amplify_config_us-east-2.json` - Source configuration analysis
- `scripts/cognito_config_us-east-2.json` - Cognito user pool details
- `scripts/s3_config_us-east-2.json` - S3 bucket configuration
- `scripts/.env.us-east-2` - Environment variables template

### Update These Files

1. **amplifyconfiguration.json** (in app root)
   - Update all region references to us-east-2
   - Update resource IDs to us-east-2 versions

2. **.amplifyrc** (if using Amplify CLI)
   - Update region and environment settings

3. **backend/auth/[resource]/parameters.json**
   - Update Cognito pool ID

4. **backend/storage/[resource]/parameters.json**
   - Update S3 bucket name

---

## Troubleshooting

### Issue: Cognito Authentication Fails

**Solution:**
1. Verify user pool ID is correct
2. Check user pool client ID matches
3. Ensure callback URLs are configured
4. Verify user exists in pool (check console)

```powershell
# List users
aws cognito-idp list-users --user-pool-id us-east-2_XXXXX --region us-east-2
```

### Issue: S3 Access Denied

**Solution:**
1. Check IAM permissions for Lambda execution role
2. Verify bucket policy allows access
3. Ensure bucket exists in us-east-2

```powershell
# Verify bucket
aws s3api head-bucket --bucket foretale-dev-app-storage-us-east-2 --region us-east-2
```

### Issue: API Gateway Not Working

**Solution:**
1. Verify API was imported to us-east-2
2. Check Lambda integration ARNs point to us-east-2 functions
3. Verify API deployment is active

```powershell
# List APIs
aws apigateway get-rest-apis --region us-east-2
```

### Issue: Amplify Deployment Fails

**Solution:**
1. Check build logs in Amplify console
2. Verify environment variables are set
3. Check for code errors related to region references

---

## Resource IDs Reference

| Resource | us-east-1 | us-east-2 |
|----------|-----------|-----------|
| Cognito Pool | us-east-1_GJdwG2sgM | us-east-2_XXXXX (to be created) |
| Identity Pool | us-east-1:xxxxxxxx-xxxx-xxxx | us-east-2:4b9dd439-eae0-4ad7-aae1-1c2ef9a6843a |
| App Storage Bucket | foretale-dev-app-storage | foretale-dev-app-storage-us-east-2 |
| API Gateway | (in us-east-1) | (imported to us-east-2) |
| Lambda Functions | (in us-east-1) | (all 8 deployed in us-east-2) |

---

## Deployment Checklist

- [ ] Cognito User Pool created in us-east-2
- [ ] Cognito User Pool Client created
- [ ] Cognito Identity Pool created (already done)
- [ ] S3 buckets created in us-east-2
- [ ] S3 data synced from us-east-1
- [ ] Amplify app created in us-east-2
- [ ] Backend resources configured in Amplify
- [ ] Environment variables updated
- [ ] Application code updated for us-east-2
- [ ] Cognito authentication tested
- [ ] S3 access tested
- [ ] API Gateway tested
- [ ] Amplify deployment successful
- [ ] End-to-end testing completed

---

## Next Steps

1. **Create Cognito User Pool** (Manual steps above)
2. **Run S3 setup**: `.\scripts\setup_amplify_storage.ps1`
3. **Create Amplify app** in console
4. **Test all components**
5. **Update application code** for us-east-2
6. **Deploy** via Amplify

---

## Support Resources

- [AWS Amplify Documentation](https://docs.amplify.aws/)
- [Cognito Developer Guide](https://docs.aws.amazon.com/cognito/latest/developerguide/)
- [S3 User Guide](https://docs.aws.amazon.com/s3/latest/userguide/)
- [API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/userguide/)

---

**Last Updated:** 2026-01-28
**Status:** Configuration Guide Complete
**Next Phase:** Manual Cognito Setup & Amplify Deployment
