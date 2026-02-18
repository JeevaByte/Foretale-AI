# Setup Cognito User Pool for Amplify in us-east-2
# Replicates Cognito configuration from us-east-1

param(
    [string]$SourceRegion = "us-east-1",
    [string]$TargetRegion = "us-east-2",
    [string]$AppName = "foretale"
)

$ErrorActionPreference = "Continue"

Write-Host "=== Cognito User Pool Setup for $TargetRegion ===" -ForegroundColor Cyan

# Step 1: Get source user pool
Write-Host "`n[Step 1] Finding source User Pool..." -ForegroundColor Yellow

$userPools = aws cognito-idp list-user-pools --max-results 60 --region $SourceRegion --output json | ConvertFrom-Json
$sourcePool = $userPools.UserPools | Where-Object { $_.Name -like "*$AppName*" -or $_.Name -like "*foretale*" } | Select-Object -First 1

if (-not $sourcePool) {
    Write-Host "ERROR: No User Pool found matching '$AppName' in $SourceRegion" -ForegroundColor Red
    exit 1
}

Write-Host "Found source pool: $($sourcePool.Name) (ID: $($sourcePool.Id))" -ForegroundColor Green

# Step 2: Get source pool details
Write-Host "`n[Step 2] Fetching source pool configuration..." -ForegroundColor Yellow

$poolDetail = aws cognito-idp describe-user-pool --user-pool-id $($sourcePool.Id) --region $SourceRegion --output json | ConvertFrom-Json
$pool = $poolDetail.UserPool

Write-Host "Pool Configuration:" -ForegroundColor Green
Write-Host "  Name: $($pool.Name)"
Write-Host "  MFA: $($pool.MfaConfiguration)"
$emailEnabled = if ($pool.EmailVerificationMessage -ne $null) { "Enabled" } else { "Disabled" }
$smsEnabled = if ($pool.SmsVerificationMessage -ne $null) { "Enabled" } else { "Disabled" }
Write-Host "  Email Verification: $emailEnabled"
Write-Host "  SMS Verification: $smsEnabled"

# Step 3: Create policies
Write-Host "`n[Step 3] Creating Cognito User Pool in $TargetRegion..." -ForegroundColor Yellow

# Build password policy
$passwordPolicy = @{
    MinimumLength = $pool.Policies.PasswordPolicy.MinimumLength
    RequireUppercase = $pool.Policies.PasswordPolicy.RequireUppercase
    RequireLowercase = $pool.Policies.PasswordPolicy.RequireLowercase
    RequireNumbers = $pool.Policies.PasswordPolicy.RequireNumbers
    RequireSymbols = $pool.Policies.PasswordPolicy.RequireSymbols
}

Write-Host "Password Policy:" -ForegroundColor Gray
Write-Host "  Minimum Length: $($passwordPolicy.MinimumLength)"
Write-Host "  Uppercase: $($passwordPolicy.RequireUppercase)"
Write-Host "  Lowercase: $($passwordPolicy.RequireLowercase)"
Write-Host "  Numbers: $($passwordPolicy.RequireNumbers)"
Write-Host "  Symbols: $($passwordPolicy.RequireSymbols)"

# Create user pool in target region
$poolName = "$($pool.Name)-${TargetRegion}"
Write-Host "`nCreating pool: $poolName" -NoNewline

$createPoolCmd = @(
    "--pool-name", $poolName,
    "--policies", "PasswordPolicy=$($passwordPolicy | ConvertTo-Json -Compress)",
    "--region", $TargetRegion,
    "--output", "json"
)

# Add optional attributes
if ($pool.AutoVerifiedAttributes) {
    $createPoolCmd += "--auto-verified-attributes"
    $createPoolCmd += ($pool.AutoVerifiedAttributes -join ',')
}

try {
    $newPool = aws cognito-idp create-user-pool @createPoolCmd | ConvertFrom-Json
    $newPoolId = $newPool.UserPool.Id
    
    Write-Host " [Created]" -ForegroundColor Green
    Write-Host "  New Pool ID: $newPoolId" -ForegroundColor Cyan
}
catch {
    Write-Host " [Failed]" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Create user pool client
Write-Host "`n[Step 4] Creating User Pool Client..." -ForegroundColor Yellow

$clients = aws cognito-idp list-user-pool-clients --user-pool-id $($sourcePool.Id) --region $SourceRegion --output json | ConvertFrom-Json
$sourceClient = $clients.UserPoolClients | Select-Object -First 1

if ($sourceClient) {
    $clientDetail = aws cognito-idp describe-user-pool-client `
        --user-pool-id $($sourcePool.Id) `
        --client-id $($sourceClient.ClientId) `
        --region $SourceRegion `
        --output json | ConvertFrom-Json
    
    $client = $clientDetail.UserPoolClient
    
    Write-Host "Creating client: $($client.ClientName)" -NoNewline
    
    $clientCmd = @(
        "--user-pool-id", $newPoolId,
        "--client-name", $client.ClientName,
        "--region", $TargetRegion,
        "--output", "json"
    )
    
    # Add client settings
    if ($client.ExplicitAuthFlows) {
        $clientCmd += "--explicit-auth-flows"
        $clientCmd += ($client.ExplicitAuthFlows -join ' ')
    }
    
    if ($client.AllowedOAuthFlows) {
        $clientCmd += "--allowed-o-auth-flows"
        $clientCmd += ($client.AllowedOAuthFlows -join ' ')
    }
    
    if ($client.CallbackURLs) {
        $clientCmd += "--callback-urls"
        $clientCmd += ($client.CallbackURLs -join ' ')
    }
    
    try {
        $newClient = aws cognito-idp create-user-pool-client @clientCmd | ConvertFrom-Json
        
        Write-Host " [Created]" -ForegroundColor Green
        Write-Host "  Client ID: $($newClient.UserPoolClient.ClientId)" -ForegroundColor Cyan
        Write-Host "  Client Name: $($newClient.UserPoolClient.ClientName)" -ForegroundColor Gray
    }
    catch {
        Write-Host " [Failed]" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Step 5: Create Identity Pool
Write-Host "`n[Step 5] Creating Cognito Identity Pool..." -ForegroundColor Yellow

$identityPools = aws cognito-identity list-identity-pools --max-results 60 --region $SourceRegion --output json | ConvertFrom-Json
$sourceIdentityPool = $identityPools.IdentityPools | Where-Object { $_.IdentityPoolName -like "*$AppName*" } | Select-Object -First 1

if ($sourceIdentityPool) {
    Write-Host "Found source identity pool: $($sourceIdentityPool.IdentityPoolName)" -ForegroundColor Green
    
    $identityPoolDetail = aws cognito-identity describe-identity-pool `
        --identity-pool-id $($sourceIdentityPool.IdentityPoolId) `
        --region $SourceRegion `
        --output json | ConvertFrom-Json
    
    $identityPoolName = "$($sourceIdentityPool.IdentityPoolName)-${TargetRegion}"
    Write-Host "Creating identity pool: $identityPoolName" -NoNewline
    
    try {
        $newIdentityPool = aws cognito-identity create-identity-pool `
            --identity-pool-name $identityPoolName `
            --allow-unauthenticated-identities `
            --region $TargetRegion `
            --output json | ConvertFrom-Json
        
        Write-Host " [Created]" -ForegroundColor Green
        Write-Host "  Identity Pool ID: $($newIdentityPool.IdentityPoolId)" -ForegroundColor Cyan
    }
    catch {
        Write-Host " [Failed]" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "No Identity Pool found in source" -ForegroundColor Yellow
}

# Step 6: Summary and configuration
Write-Host "`n[Step 6] Configuration Summary" -ForegroundColor Cyan
Write-Host "=" * 60

Write-Host @"

SOURCE CONFIGURATION:
  Pool ID: $($sourcePool.Id)
  Pool Name: $($sourcePool.Name)
  Region: $SourceRegion

NEW CONFIGURATION:
  Pool ID: $newPoolId
  Pool Name: $poolName
  Region: $TargetRegion

UPDATE YOUR AMPLIFY CONFIG:

amplify/backend/auth/*/parameters.json should contain:

{
  "userPoolId": "$newPoolId",
  "userPoolName": "$poolName",
  "region": "$TargetRegion",
  "mfaConfiguration": "$($pool.MfaConfiguration)",
  "passwordPolicy": $($passwordPolicy | ConvertTo-Json -Compress)
}

UPDATE APPLICATION CONFIG:

In your amplify configuration or environment variables:

COGNITO_USER_POOL_ID=$newPoolId
COGNITO_CLIENT_ID=$(Get the client ID from above)
COGNITO_REGION=$TargetRegion
COGNITO_DOMAIN=dev-foretale-${TargetRegion#-}.auth.${TargetRegion}.amazoncognito.com

NEXT STEPS:

1. Configure OAuth domain (optional but recommended):
   aws cognito-idp create-user-pool-domain \
     --domain "dev-foretale-${TargetRegion#-}" \
     --user-pool-id $newPoolId \
     --region $TargetRegion

2. Setup email configuration for password resets:
   aws cognito-idp update-user-pool \
     --user-pool-id $newPoolId \
     --email-configuration SourceArn=arn:aws:ses:${TargetRegion}:ACCOUNT_ID:identity/YOUR_EMAIL \
     --region $TargetRegion

3. Import users from source pool (if needed):
   - Export users from $($sourcePool.Id)
   - Import to $newPoolId
   
4. Update Amplify app with new pool ID

"@

# Save configuration
$configFile = Join-Path $PSScriptRoot "cognito_config_${TargetRegion}.json"
$cognitoConfig = @{
    sourcePoolId = $sourcePool.Id
    sourcePoolName = $sourcePool.Name
    sourceRegion = $SourceRegion
    newPoolId = $newPoolId
    newPoolName = $poolName
    targetRegion = $TargetRegion
    passwordPolicy = $passwordPolicy
}

$cognitoConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8

Write-Host "`nConfiguration saved to: $configFile" -ForegroundColor Green
Write-Host "`n=== COGNITO SETUP COMPLETE ===" -ForegroundColor Green
