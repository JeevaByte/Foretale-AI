# Deploy Lambda Functions to us-east-2
# Uses the created IAM role

param(
    [string]$TargetRegion = "us-east-2",
    [string]$RoleArn = "arn:aws:iam::442426872653:role/LambdaExecRole-USEast2"
)

$ErrorActionPreference = "Continue"
$lambdaDir = Join-Path $PSScriptRoot "lambda_exports"

Write-Host "=== Lambda Function Deployment to $TargetRegion ===" -ForegroundColor Cyan
Write-Host "Using Role: $RoleArn`n" -ForegroundColor Yellow

# Wait for IAM propagation
Write-Host "Waiting 10 seconds for IAM propagation..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

$configFiles = Get-ChildItem -Path $lambdaDir -Filter "*_config.json"
Write-Host "Found $($configFiles.Count) functions to deploy`n" -ForegroundColor Cyan

$results = @()

foreach ($configFile in $configFiles) {
    $funcName = $configFile.BaseName -replace '_config$', ''
    $zipFile = Join-Path $lambdaDir "$funcName.zip"
    
    if (-not (Test-Path $zipFile)) {
        Write-Host "Skipping $funcName (no zip file)`n" -ForegroundColor Gray
        continue
    }
    
    Write-Host "Deploying: $funcName" -ForegroundColor Cyan
    
    try {
        $config = Get-Content $configFile.FullName | ConvertFrom-Json
        
        Write-Host "  Runtime: $($config.Runtime)"
        Write-Host "  Handler: $($config.Handler)"
        Write-Host "  Memory: $($config.MemorySize) MB"
        Write-Host "  Timeout: $($config.Timeout) seconds"
        
        # Check if function exists
        $existsCheck = aws lambda get-function --function-name $funcName --region $TargetRegion 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Function exists, update code
            Write-Host "  Status: Updating existing function..." -NoNewline
            
            $updateResult = aws lambda update-function-code `
                --function-name $funcName `
                --zip-file "fileb://$zipFile" `
                --region $TargetRegion `
                --output json 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " [SUCCESS]" -ForegroundColor Green
                $results += [PSCustomObject]@{
                    Function = $funcName
                    Status = "Updated"
                    Action = "Code updated"
                }
            }
            else {
                Write-Host " [FAILED]" -ForegroundColor Red
                Write-Host "  Error: $updateResult" -ForegroundColor Red
                $results += [PSCustomObject]@{
                    Function = $funcName
                    Status = "Failed"
                    Error = $updateResult
                }
            }
        }
        else {
            # Function doesn't exist, create it
            Write-Host "  Status: Creating new function..." -NoNewline
            
            $createResult = aws lambda create-function `
                --function-name $funcName `
                --runtime $config.Runtime `
                --role $RoleArn `
                --handler $config.Handler `
                --zip-file "fileb://$zipFile" `
                --region $TargetRegion `
                --timeout $config.Timeout `
                --memory-size $config.MemorySize `
                --output json 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " [SUCCESS]" -ForegroundColor Green
                
                # Parse result to get function ARN
                $funcData = $createResult | ConvertFrom-Json
                Write-Host "  ARN: $($funcData.FunctionArn)" -ForegroundColor Gray
                
                $results += [PSCustomObject]@{
                    Function = $funcName
                    Status = "Created"
                    ARN = $funcData.FunctionArn
                }
            }
            else {
                Write-Host " [FAILED]" -ForegroundColor Red
                Write-Host "  Error: $createResult" -ForegroundColor Red
                $results += [PSCustomObject]@{
                    Function = $funcName
                    Status = "Failed"
                    Error = $createResult
                }
            }
        }
    }
    catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Function = $funcName
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host "=== DEPLOYMENT SUMMARY ===" -ForegroundColor Cyan
$results | Format-Table Function, Status -AutoSize

$created = ($results | Where-Object {$_.Status -eq "Created"}).Count
$updated = ($results | Where-Object {$_.Status -eq "Updated"}).Count
$failed = ($results | Where-Object {$_.Status -eq "Failed"}).Count

Write-Host "`nCreated: $created" -ForegroundColor Green
Write-Host "Updated: $updated" -ForegroundColor Yellow
Write-Host "Failed: $failed" -ForegroundColor $(if($failed -gt 0){"Red"}else{"Green"})

# Save results
$resultsFile = Join-Path $lambdaDir "final_deployment_results.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsFile -Encoding UTF8
Write-Host "`nResults saved to: $resultsFile" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host "`nAll Lambda functions deployed successfully!" -ForegroundColor Green
}

Write-Host "`n=== COMPLETE ===" -ForegroundColor Green
