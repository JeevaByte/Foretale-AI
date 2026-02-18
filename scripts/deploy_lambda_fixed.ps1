# Create IAM role for Lambda and deploy functions
# Fixed version with proper trust policy

param(
    [string]$TargetRegion = "us-east-2"
)

$ErrorActionPreference = "Continue"
$lambdaDir = Join-Path $PSScriptRoot "lambda_exports"

Write-Host "=== Lambda Deployment Setup ===" -ForegroundColor Cyan

# Step 1: Create IAM Role
Write-Host "`n[Step 1] Creating IAM Execution Role..." -ForegroundColor Yellow

$trustPolicyJson = @'
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
'@

$trustPolicyFile = Join-Path $env:TEMP "lambda-trust-policy.json"
$trustPolicyJson | Out-File -FilePath $trustPolicyFile -Encoding UTF8 -NoNewline

$roleName = "LambdaExecutionRole-USEast2-Migration"

# Check if role exists
$existingRole = aws iam get-role --role-name $roleName 2>$null
if ($LASTEXITCODE -eq 0) {
    $roleData = $existingRole | ConvertFrom-Json
    $roleArn = $roleData.Role.Arn
    Write-Host "Using existing role: $roleArn" -ForegroundColor Green
}
else {
    # Create new role
    Write-Host "Creating new role: $roleName" -NoNewline
    $createResult = aws iam create-role `
        --role-name $roleName `
        --assume-role-policy-document "file://$trustPolicyFile" `
        --description "Lambda execution role for us-east-2 migration" `
        --output json
    
    if ($LASTEXITCODE -eq 0) {
        $roleData = $createResult | ConvertFrom-Json
        $roleArn = $roleData.Role.Arn
        Write-Host " [Created]" -ForegroundColor Green
        
        # Attach policies
        Write-Host "Attaching policies..." -NoNewline
        aws iam attach-role-policy `
            --role-name $roleName `
            --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" | Out-Null
        
        aws iam attach-role-policy `
            --role-name $roleName `
            --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" | Out-Null
        
        Write-Host " [Done]" -ForegroundColor Green
        
        Write-Host "Waiting 15 seconds for IAM propagation..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
    }
    else {
        Write-Host " [Failed]" -ForegroundColor Red
        Write-Host "Error creating role. Please create manually and provide ARN."
        exit 1
    }
}

Write-Host "Role ARN: $roleArn`n" -ForegroundColor Cyan

# Step 2: Deploy Lambda Functions
Write-Host "[Step 2] Deploying Lambda Functions..." -ForegroundColor Yellow

$configFiles = Get-ChildItem -Path $lambdaDir -Filter "*_config.json"
$results = @()

foreach ($configFile in $configFiles) {
    $funcName = $configFile.BaseName -replace '_config$', ''
    $zipFile = Join-Path $lambdaDir "$funcName.zip"
    
    if (-not (Test-Path $zipFile)) {
        Write-Host "  Skipping $funcName (no zip file)" -ForegroundColor Gray
        continue
    }
    
    Write-Host "`n  Deploying: $funcName" -NoNewline
    
    try {
        $config = Get-Content $configFile.FullName | ConvertFrom-Json
        
        # Check if exists
        $exists = aws lambda get-function --function-name $funcName --region $TargetRegion 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            # Update existing
            aws lambda update-function-code `
                --function-name $funcName `
                --zip-file "fileb://$zipFile" `
                --region $TargetRegion `
                --output json 2>&1 | Out-Null
            
            Write-Host " [Updated]" -ForegroundColor Yellow
            $results += [PSCustomObject]@{Function=$funcName; Status="Updated"}
        }
        else {
            # Create new
            $createCmd = @"
aws lambda create-function \
  --function-name "$funcName" \
  --runtime "$($config.Runtime)" \
  --role "$roleArn" \
  --handler "$($config.Handler)" \
  --zip-file "fileb://$zipFile" \
  --region "$TargetRegion" \
  --timeout $($config.Timeout) \
  --memory-size $($config.MemorySize) \
  --output json
"@
            
            $result = Invoke-Expression $createCmd.Replace('\', '') 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " [Created]" -ForegroundColor Green
                $results += [PSCustomObject]@{Function=$funcName; Status="Created"}
            }
            else {
                Write-Host " [Failed]" -ForegroundColor Red
                Write-Host "    Error: $result" -ForegroundColor Gray
                $results += [PSCustomObject]@{Function=$funcName; Status="Failed"; Error=$result}
            }
        }
    }
    catch {
        Write-Host " [Failed]" -ForegroundColor Red
        $results += [PSCustomObject]@{Function=$funcName; Status="Failed"; Error=$_.Exception.Message}
    }
}

# Summary
Write-Host "`n=== DEPLOYMENT SUMMARY ===" -ForegroundColor Cyan
$results | Format-Table Function, Status -AutoSize

$success = ($results | Where-Object {$_.Status -in @("Created","Updated")}).Count
$failed = ($results | Where-Object {$_.Status -eq "Failed"}).Count

Write-Host "`nSuccessful: $success" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if($failed -gt 0){"Red"}else{"Green"})

Write-Host "`n=== COMPLETE ===" -ForegroundColor Green
