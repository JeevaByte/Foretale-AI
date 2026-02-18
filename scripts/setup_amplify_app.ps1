# AWS Amplify Setup for us-east-2
# Creates Amplify app with backend resources matching us-east-1

param(
    [string]$AppName = "foretaleapplication",
    [string]$TargetRegion = "us-east-2",
    [string]$GitRepo = "",  # Git repository URL
    [string]$GitBranch = "main",
    [string]$SourceRegion = "us-east-1"
)

$ErrorActionPreference = "Continue"

Write-Host "=== AWS Amplify Setup for us-east-2 ===" -ForegroundColor Cyan
Write-Host "App: $AppName" -ForegroundColor Yellow
Write-Host "Target Region: $TargetRegion`n" -ForegroundColor Yellow

# Step 1: Fetch source Amplify app details
Write-Host "[Step 1] Fetching source Amplify app details..." -ForegroundColor Cyan

$sourceApps = aws amplify list-apps --region $SourceRegion --output json | ConvertFrom-Json
$sourceApp = $sourceApps.apps | Where-Object { $_.name -eq $AppName }

if (-not $sourceApp) {
    Write-Host "ERROR: Source app '$AppName' not found in $SourceRegion" -ForegroundColor Red
    exit 1
}

Write-Host "Found source app: $($sourceApp.appId)" -ForegroundColor Green
Write-Host "  Name: $($sourceApp.name)"
Write-Host "  Platform: $($sourceApp.platform)"
Write-Host "  Repository: $($sourceApp.repository)"
Write-Host ""

# Step 2: Get source branches and environments
Write-Host "[Step 2] Fetching source branches..." -ForegroundColor Cyan

$branches = aws amplify list-branches --app-id $($sourceApp.appId) --region $SourceRegion --output json | ConvertFrom-Json

if ($branches.branches.Count -gt 0) {
    Write-Host "Found $($branches.branches.Count) branches:" -ForegroundColor Green
    $branches.branches | ForEach-Object { 
        Write-Host "  - $($_.branchName) (Status: $($_.status))"
    }
}
Write-Host ""

# Step 3: Get Cognito User Pool and Identity Pool details
Write-Host "[Step 3] Fetching Cognito configuration..." -ForegroundColor Cyan

$amplifyConfig = @{
    sourceRegion = $SourceRegion
    targetRegion = $TargetRegion
    appName = $AppName
    authentication = @{}
    storage = @{}
    api = @{}
}

# Find Cognito User Pools
$userPools = aws cognito-idp list-user-pools --max-results 60 --region $SourceRegion --output json | ConvertFrom-Json
$appUserPools = $userPools.UserPools | Where-Object { $_.Name -like "*$AppName*" -or $_.Name -like "*foretale*" }

if ($appUserPools) {
    Write-Host "Found Cognito User Pool(s):" -ForegroundColor Green
    foreach ($pool in $appUserPools) {
        Write-Host "  - $($pool.Name) (ID: $($pool.Id))" -ForegroundColor Gray
        
        # Get pool details
        $poolDetail = aws cognito-idp describe-user-pool --user-pool-id $($pool.Id) --region $SourceRegion --output json | ConvertFrom-Json
        
        $amplifyConfig.authentication += @{
            userPoolId = $pool.Id
            userPoolName = $pool.Name
            policies = @{
                passwordPolicy = $poolDetail.UserPool.Policies.PasswordPolicy
                mfaConfiguration = $poolDetail.UserPool.MfaConfiguration
            }
        }
        
        # Get user pool clients
        $clients = aws cognito-idp list-user-pool-clients --user-pool-id $($pool.Id) --region $SourceRegion --output json | ConvertFrom-Json
        if ($clients.UserPoolClients) {
            Write-Host "    Clients:" -ForegroundColor Gray
            foreach ($client in $clients.UserPoolClients) {
                Write-Host "      - $($client.ClientName) (ID: $($client.ClientId))" -ForegroundColor Gray
            }
        }
    }
} else {
    Write-Host "No Cognito User Pools found matching app name" -ForegroundColor Yellow
}

Write-Host ""

# Step 4: Get S3 bucket for storage
Write-Host "[Step 4] Fetching S3 storage configuration..." -ForegroundColor Cyan

$buckets = aws s3api list-buckets --output json | ConvertFrom-Json
$appBuckets = $buckets.Buckets | Where-Object { $_.Name -like "*$AppName*" -or $_.Name -like "*foretale*" }

if ($appBuckets) {
    Write-Host "Found S3 bucket(s):" -ForegroundColor Green
    foreach ($bucket in $appBuckets) {
        Write-Host "  - $($bucket.Name)" -ForegroundColor Gray
        
        # Get bucket location
        $location = aws s3api get-bucket-location --bucket $($bucket.Name) --output json | ConvertFrom-Json
        Write-Host "    Region: $($location.LocationConstraint)" -ForegroundColor Gray
        
        $amplifyConfig.storage += @{
            bucketName = $bucket.Name
            region = $location.LocationConstraint
        }
    }
} else {
    Write-Host "No S3 buckets found" -ForegroundColor Yellow
}

Write-Host ""

# Step 5: Get API Gateway endpoints
Write-Host "[Step 5] Fetching API Gateway configuration..." -ForegroundColor Cyan

$apis = aws apigateway get-rest-apis --region $SourceRegion --output json | ConvertFrom-Json

if ($apis.items) {
    $appApis = $apis.items | Where-Object { $_.name -like "*$AppName*" -or $_.name -like "*foretale*" }
    
    if ($appApis) {
        Write-Host "Found API Gateway(s):" -ForegroundColor Green
        foreach ($api in $appApis) {
            Write-Host "  - $($api.name) (ID: $($api.id))" -ForegroundColor Gray
            
            $stages = aws apigateway get-stages --rest-api-id $($api.id) --region $SourceRegion --output json | ConvertFrom-Json
            if ($stages.item) {
                Write-Host "    Stages:" -ForegroundColor Gray
                foreach ($stage in $stages.item) {
                    $endpoint = "https://$($api.id).execute-api.$SourceRegion.amazonaws.com/$($stage.stageName)"
                    Write-Host "      - $($stage.stageName): $endpoint" -ForegroundColor Gray
                }
            }
            
            $amplifyConfig.api += @{
                apiId = $api.id
                apiName = $api.name
                region = $SourceRegion
            }
        }
    } else {
        Write-Host "No API Gateways found matching app name" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 6: Display migration plan
Write-Host "[Step 6] Migration Plan for us-east-2" -ForegroundColor Cyan

Write-Host @"

COGNITO USER POOLS:
  1. Create new User Pool in $TargetRegion matching source configuration
  2. Copy user pool policies and settings
  3. Recreate user pool clients with same configuration

STORAGE (S3):
  1. Replicate buckets to $TargetRegion
  2. Copy bucket policies and permissions
  3. Set up cross-region replication if needed

API GATEWAY:
  1. Import API definitions to $TargetRegion
  2. Update Lambda integration ARNs
  3. Deploy to 'prod' stage

AMPLIFY:
  1. Create new Amplify app in $TargetRegion
  2. Connect to same Git repository
  3. Configure environment variables
  4. Set backend resources for $TargetRegion

"@

# Step 7: Save configuration
Write-Host "[Step 7] Saving configuration..." -ForegroundColor Cyan

$configFile = Join-Path $PSScriptRoot "amplify_config_${TargetRegion}.json"
$amplifyConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8

Write-Host "Configuration saved to: $configFile" -ForegroundColor Green

# Step 8: Create Amplify app via CLI
Write-Host "`n[Step 8] Creating Amplify App in Console..." -ForegroundColor Yellow

Write-Host @"

MANUAL STEPS - AWS Amplify Console:

1. Navigate to: https://${TargetRegion}.console.aws.amazon.com/amplify/

2. Click "Create app" or "New app"

3. Choose "Host web app" if deploying frontend, or "Build an app" for full stack

4. Connect to Git repository:
   - Repository: $($sourceApp.repository)
   - Branch: $GitBranch (or your main branch)
   - App name: ${AppName}-useast2

5. Configure build settings:
   - Copy build configuration from us-east-1
   - Update environment variables for $TargetRegion

6. Add backend resources:
   
   A. AUTHENTICATION (Cognito):
      - Create User Pool in $TargetRegion
      - Import source pool configuration
      - Create app clients matching source

   B. STORAGE (S3):
      - Create S3 bucket in $TargetRegion
      - Configure CORS policies
      - Set up IAM permissions

   C. API:
      - Import API Gateway from us-east-2
      - Update Lambda integration ARNs
      - Deploy to 'prod' stage

7. Deploy

PROGRAMMATIC SETUP (Alternative):

If using AWS Amplify CLI:

\`\`\`powershell
# Initialize Amplify project (if not already done)
cd YOUR_PROJECT_DIR
amplify init

# Add authentication
amplify add auth

# Add storage
amplify add storage

# Add API
amplify add api

# Push to cloud
amplify push
\`\`\`

"@

Write-Host "For detailed Amplify configuration, see:" -ForegroundColor Cyan
Write-Host "  $configFile" -ForegroundColor Gray

# Step 9: Prepare environment variables
Write-Host "`n[Step 9] Preparing environment configuration..." -ForegroundColor Yellow

$envConfig = @{
    REGION = $TargetRegion
    SOURCE_REGION = $SourceRegion
    APP_NAME = $AppName
    API_ENDPOINT = ""  # Will be set after API import
    STORAGE_BUCKET = ""  # Will be set after S3 replication
    USER_POOL_ID = ""  # Will be set after Cognito creation
    APP_CLIENT_ID = ""  # Will be set after client creation
}

$envFile = Join-Path $PSScriptRoot ".env.${TargetRegion}"
$envContent = ($envConfig.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "`n"
$envContent | Out-File -FilePath $envFile -Encoding UTF8

Write-Host "Environment template created: $envFile" -ForegroundColor Green

Write-Host @"

Update this file with actual values after creating resources in ${TargetRegion}:

\`\`\`
REGION=us-east-2
SOURCE_REGION=us-east-1
APP_NAME=foretaleapplication
API_ENDPOINT=https://API_ID.execute-api.us-east-2.amazonaws.com/prod
STORAGE_BUCKET=foretale-storage-us-east-2
USER_POOL_ID=us-east-2_XXXXXXXXX
APP_CLIENT_ID=XXXXXXXXXXXXXXXXXXXXXXXXXX
\`\`\`

"@

# Step 10: Summary and next steps
Write-Host "`n[Step 10] Summary" -ForegroundColor Cyan
Write-Host "=" * 60

Write-Host "`nConfiguration Details:" -ForegroundColor Yellow
Write-Host "  Source App: $($sourceApp.appId) ($($sourceApp.name))"
Write-Host "  Source Region: $SourceRegion"
Write-Host "  Target Region: $TargetRegion"
Write-Host "  Repository: $($sourceApp.repository)"
Write-Host ""

Write-Host "Resources Detected:" -ForegroundColor Yellow
Write-Host "  User Pools: $($appUserPools.Count)"
Write-Host "  S3 Buckets: $($appBuckets.Count)"
Write-Host "  API Gateways: $($appApis.Count)"
Write-Host ""

Write-Host "Generated Files:" -ForegroundColor Yellow
Write-Host "  1. $configFile"
Write-Host "  2. $envFile"
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Run: .\setup_amplify_cognito.ps1 (Create Cognito resources)"
Write-Host "  2. Run: .\setup_amplify_storage.ps1 (Setup S3)"
Write-Host "  3. Run: .\setup_amplify_api.ps1 (Configure API)"
Write-Host "  4. Create Amplify app in Console (see instructions above)"
Write-Host "  5. Update environment variables in $envFile"
Write-Host "  6. Deploy to Amplify"
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Gray
Write-Host "  - AWS Amplify: https://docs.amplify.aws/"
Write-Host "  - Cognito User Pools: https://docs.aws.amazon.com/cognito/latest/developerguide/user-pools.html"
Write-Host "  - S3 Cross-Region Replication: https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html"
Write-Host ""

Write-Host "=== SETUP COMPLETE ===" -ForegroundColor Green
