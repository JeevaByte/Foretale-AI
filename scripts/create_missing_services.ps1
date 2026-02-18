# AWS Service Creation Script for us-east-2
# Creates missing services based on audit results

$ErrorActionPreference = "Stop"
$sourceRegion = "us-east-1"
$targetRegion = "us-east-2"

Write-Host "=== AWS Service Replication to us-east-2 ===" -ForegroundColor Cyan
Write-Host "This script will create missing services in $targetRegion`n" -ForegroundColor Yellow

# Track progress
$successCount = 0
$failureCount = 0
$results = @()

# ========================================
# 1. Create ECR Repositories
# ========================================
Write-Host "`n[1/5] Creating ECR Repositories..." -ForegroundColor Cyan

$ecrRepos = @(
    "servers/redis/sync",
    "servers/mcp",
    "servers/embedding/sync",
    "invoke/bg/job",
    "uploads/ecr-csv-upload",
    "servers/embedding",
    "servers/redis",
    "servers/deepai",
    "invoke/db/process"
)

foreach ($repo in $ecrRepos) {
    try {
        Write-Host "  Creating repository: $repo" -NoNewline
        
        # Check if already exists
        $exists = aws ecr describe-repositories --repository-names $repo --region $targetRegion 2>$null
        if ($exists) {
            Write-Host " [Already Exists]" -ForegroundColor Yellow
        }
        else {
            # Create repository
            aws ecr create-repository --repository-name $repo --region $targetRegion --output json | Out-Null
            Write-Host " [Created]" -ForegroundColor Green
            $successCount++
        }
        
        # Copy image from source region (optional - uncomment if needed)
        # Write-Host "    Copying images..." -NoNewline
        # $sourceImage = "442426872653.dkr.ecr.$sourceRegion.amazonaws.com/$repo"
        # $targetImage = "442426872653.dkr.ecr.$targetRegion.amazonaws.com/$repo"
        # aws ecr get-login-password --region $sourceRegion | docker login --username AWS --password-stdin $sourceImage
        # docker pull $sourceImage:latest
        # docker tag $sourceImage:latest $targetImage:latest
        # aws ecr get-login-password --region $targetRegion | docker login --username AWS --password-stdin $targetImage
        # docker push $targetImage:latest
        # Write-Host " [Copied]" -ForegroundColor Green
        
        $results += [PSCustomObject]@{
            Service = "ECR"
            Resource = $repo
            Status = "Success"
        }
    }
    catch {
        Write-Host " [Failed: $($_.Exception.Message)]" -ForegroundColor Red
        $failureCount++
        $results += [PSCustomObject]@{
            Service = "ECR"
            Resource = $repo
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

# ========================================
# 2. Create SQS Queues
# ========================================
Write-Host "`n[2/5] Creating SQS Queues..." -ForegroundColor Cyan

$sqsQueues = @("sqs-controls-execution")

foreach ($queueName in $sqsQueues) {
    try {
        Write-Host "  Creating queue: $queueName" -NoNewline
        
        # Get queue attributes from source region
        $sourceQueueUrl = "https://sqs.$sourceRegion.amazonaws.com/442426872653/$queueName"
        $attributes = aws sqs get-queue-attributes --queue-url $sourceQueueUrl --attribute-names All --region $sourceRegion --output json | ConvertFrom-Json
        
        # Create queue in target region
        $createParams = @(
            "--queue-name", $queueName,
            "--region", $targetRegion
        )
        
        # Add attributes
        if ($attributes.Attributes.VisibilityTimeout) {
            $createParams += "--attributes"
            $createParams += "VisibilityTimeout=$($attributes.Attributes.VisibilityTimeout)"
        }
        
        aws sqs create-queue @createParams | Out-Null
        Write-Host " [Created]" -ForegroundColor Green
        $successCount++
        
        $results += [PSCustomObject]@{
            Service = "SQS"
            Resource = $queueName
            Status = "Success"
        }
    }
    catch {
        Write-Host " [Failed: $($_.Exception.Message)]" -ForegroundColor Red
        $failureCount++
        $results += [PSCustomObject]@{
            Service = "SQS"
            Resource = $queueName
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

# ========================================
# 3. Export and Create API Gateways
# ========================================
Write-Host "`n[3/5] Creating API Gateways..." -ForegroundColor Cyan

$apiGateways = @(
    @{Id="itpkscu97c"; Name="api-ecs-task-invoker"},
    @{Id="uq56kj6m5f"; Name="api-sql-procedure-invoker"}
)

foreach ($api in $apiGateways) {
    try {
        Write-Host "  Exporting API: $($api.Name)" -NoNewline
        
        # Export API from source region
        $exportFile = Join-Path $PSScriptRoot "$($api.Name)_export.json"
        aws apigateway get-export --rest-api-id $($api.Id) --stage-name prod --export-type swagger --region $sourceRegion $exportFile 2>$null
        
        if (Test-Path $exportFile) {
            Write-Host " [Exported]" -ForegroundColor Green
            Write-Host "    API definition saved to: $exportFile"
            Write-Host "    Manual import required: aws apigateway import-rest-api --body file://$exportFile --region $targetRegion"
            
            $results += [PSCustomObject]@{
                Service = "API Gateway"
                Resource = $api.Name
                Status = "Exported (Manual import needed)"
            }
        }
        else {
            Write-Host " [Export Failed]" -ForegroundColor Red
        }
    }
    catch {
        Write-Host " [Failed: $($_.Exception.Message)]" -ForegroundColor Red
        $failureCount++
        $results += [PSCustomObject]@{
            Service = "API Gateway"
            Resource = $api.Name
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

# ========================================
# 4. Package and Deploy Lambda Functions
# ========================================
Write-Host "`n[4/5] Preparing Lambda Functions..." -ForegroundColor Cyan

$lambdaFunctions = @(
    @{Name="sql-server-data-upload"; Runtime="python3.12"},
    @{Name="amplify-login-custom-message-de15b5e1"; Runtime="nodejs20.x"},
    @{Name="amplify-login-verify-auth-challenge-de15b5e1"; Runtime="nodejs20.x"},
    @{Name="ecs-task-invoker"; Runtime="python3.12"},
    @{Name="calling-sql-procedure"; Runtime="python3.12"},
    @{Name="amplify-login-create-auth-challenge-de15b5e1"; Runtime="nodejs20.x"},
    @{Name="amplify-foretaleapplicati-UpdateRolesWithIDPFuncti-huPwKhw8QOI3"; Runtime="nodejs22.x"},
    @{Name="amplify-login-define-auth-challenge-de15b5e1"; Runtime="nodejs20.x"}
)

$lambdaDir = Join-Path $PSScriptRoot "lambda_exports"
if (-not (Test-Path $lambdaDir)) {
    New-Item -ItemType Directory -Path $lambdaDir | Out-Null
}

foreach ($func in $lambdaFunctions) {
    try {
        Write-Host "  Downloading function: $($func.Name)" -NoNewline
        
        # Get function configuration
        $funcConfig = aws lambda get-function --function-name $($func.Name) --region $sourceRegion --output json | ConvertFrom-Json
        
        # Download function code
        $codeUrl = $funcConfig.Code.Location
        $zipFile = Join-Path $lambdaDir "$($func.Name).zip"
        Invoke-WebRequest -Uri $codeUrl -OutFile $zipFile
        
        Write-Host " [Downloaded]" -ForegroundColor Green
        
        # Save configuration for deployment
        $configFile = Join-Path $lambdaDir "$($func.Name)_config.json"
        $funcConfig.Configuration | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8
        
        Write-Host "    Code: $zipFile"
        Write-Host "    Config: $configFile"
        
        $results += [PSCustomObject]@{
            Service = "Lambda"
            Resource = $func.Name
            Status = "Downloaded (Ready for deployment)"
        }
    }
    catch {
        Write-Host " [Failed: $($_.Exception.Message)]" -ForegroundColor Red
        $failureCount++
        $results += [PSCustomObject]@{
            Service = "Lambda"
            Resource = $func.Name
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
}

# ========================================
# 5. Amplify App Information
# ========================================
Write-Host "`n[5/5] Amplify App..." -ForegroundColor Cyan
Write-Host "  Amplify apps require manual recreation in the target region" -ForegroundColor Yellow
Write-Host "  App ID in us-east-1: dntg2jkpeiynq"
Write-Host "  Name: foretaleapplication"
Write-Host "  Platform: WEB"
Write-Host "`n  Steps to recreate:"
Write-Host "    1. Navigate to AWS Amplify Console in us-east-2"
Write-Host "    2. Create new app with same configuration"
Write-Host "    3. Connect to same repository"
Write-Host "    4. Configure backend resources (Cognito, API, etc.)"

$results += [PSCustomObject]@{
    Service = "Amplify"
    Resource = "foretaleapplication"
    Status = "Manual recreation required"
}

# ========================================
# Summary Report
# ========================================
Write-Host "`n=== MIGRATION SUMMARY ===" -ForegroundColor Cyan
$results | Format-Table Service, Resource, Status -AutoSize

Write-Host "`nSuccessful operations: $successCount" -ForegroundColor Green
Write-Host "Failed operations: $failureCount" -ForegroundColor $(if ($failureCount -gt 0) { "Red" } else { "Green" })

# Save detailed results
$resultsFile = Join-Path $PSScriptRoot "migration_results.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsFile -Encoding UTF8
Write-Host "`nDetailed results saved to: $resultsFile" -ForegroundColor Cyan

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Review downloaded Lambda function configurations"
Write-Host "2. Deploy Lambda functions using the deploy_lambda_functions.ps1 script"
Write-Host "3. Import API Gateway definitions"
Write-Host "4. Configure Amplify app manually"
Write-Host "5. Update application configurations to use us-east-2 endpoints"
Write-Host "`n=== COMPLETE ===" -ForegroundColor Green
