################################################################################
# Lambda Deployment Script
# Packages and deploys Lambda functions to AWS
################################################################################

param(
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-2",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "insert_record", "update_record", "delete_record", "read_record", "read_json_record", "ecs_invoker")]
    [string]$FunctionName = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipPackage = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$UpdateCode = $false
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Get workspace root
$WorkspaceRoot = Split-Path -Parent $PSScriptRoot
$LambdaDir = Join-Path $WorkspaceRoot "lambda"
$TerraformDir = Join-Path $WorkspaceRoot "terraform"
$TerraformModuleLambdaDir = Join-Path $TerraformDir "modules\lambda"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Lambda Function Deployment Script" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Define Lambda functions
$LambdaFunctions = @(
    "insert_record",
    "update_record",
    "delete_record",
    "read_record",
    "read_json_record",
    "ecs_invoker"
)

# Filter functions based on parameter
if ($FunctionName -ne "all") {
    $LambdaFunctions = @($FunctionName)
}

Write-Host "Functions to deploy: $($LambdaFunctions -join ', ')" -ForegroundColor Yellow
Write-Host ""

################################################################################
# Function: Package Lambda Function
################################################################################
function Package-LambdaFunction {
    param(
        [string]$FunctionName
    )
    
    Write-Host ">>> Packaging $FunctionName..." -ForegroundColor Green
    
    $FunctionDir = Join-Path $LambdaDir $FunctionName
    $ZipFile = Join-Path $TerraformModuleLambdaDir "$FunctionName.zip"
    
    # Check if function directory exists
    if (-not (Test-Path $FunctionDir)) {
        Write-Host "ERROR: Function directory not found: $FunctionDir" -ForegroundColor Red
        return $false
    }
    
    # Remove old zip if exists
    if (Test-Path $ZipFile) {
        Remove-Item $ZipFile -Force
        Write-Host "    Removed old zip file" -ForegroundColor Gray
    }
    
    # Create zip file
    try {
        # Get all Python files in the function directory
        $Files = Get-ChildItem -Path $FunctionDir -Filter "*.py" -File
        
        if ($Files.Count -eq 0) {
            Write-Host "ERROR: No Python files found in $FunctionDir" -ForegroundColor Red
            return $false
        }
        
        # Create zip archive
        Compress-Archive -Path (Join-Path $FunctionDir "*") -DestinationPath $ZipFile -Force
        
        $ZipSize = (Get-Item $ZipFile).Length / 1KB
        Write-Host "    Created: $ZipFile ($([math]::Round($ZipSize, 2)) KB)" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "ERROR: Failed to create zip file: $_" -ForegroundColor Red
        return $false
    }
}

################################################################################
# Function: Update Lambda Function Code via AWS CLI
################################################################################
function Update-LambdaFunctionCode {
    param(
        [string]$FunctionName
    )
    
    Write-Host ">>> Updating $FunctionName code in AWS..." -ForegroundColor Green
    
    $ZipFile = Join-Path $TerraformModuleLambdaDir "$FunctionName.zip"
    $AwsFunctionName = "foretale-app-lambda-$($FunctionName.Replace('_', '-'))"
    
    # Check if zip exists
    if (-not (Test-Path $ZipFile)) {
        Write-Host "ERROR: Zip file not found: $ZipFile" -ForegroundColor Red
        return $false
    }
    
    try {
        # Update Lambda function code
        aws lambda update-function-code `
            --function-name $AwsFunctionName `
            --zip-file "fileb://$ZipFile" `
            --region $Region `
            --no-cli-pager
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    Successfully updated $AwsFunctionName" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "ERROR: Failed to update Lambda function (exit code: $LASTEXITCODE)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "ERROR: Failed to update Lambda function: $_" -ForegroundColor Red
        return $false
    }
}

################################################################################
# Main Deployment Logic
################################################################################

$SuccessCount = 0
$FailureCount = 0

foreach ($Function in $LambdaFunctions) {
    Write-Host ""
    Write-Host "------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Processing: $Function" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------------" -ForegroundColor Cyan
    
    # Package function
    if (-not $SkipPackage) {
        $PackageSuccess = Package-LambdaFunction -FunctionName $Function
        
        if (-not $PackageSuccess) {
            Write-Host "FAILED: Packaging $Function" -ForegroundColor Red
            $FailureCount++
            continue
        }
    }
    else {
        Write-Host "Skipping packaging (SkipPackage flag set)" -ForegroundColor Yellow
    }
    
    # Update code in AWS if requested
    if ($UpdateCode) {
        $UpdateSuccess = Update-LambdaFunctionCode -FunctionName $Function
        
        if ($UpdateSuccess) {
            $SuccessCount++
        }
        else {
            $FailureCount++
        }
    }
    else {
        Write-Host ">>> Code packaged successfully (use -UpdateCode to deploy to AWS)" -ForegroundColor Yellow
        $SuccessCount++
    }
}

################################################################################
# Summary
################################################################################

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Successful: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailureCount" -ForegroundColor $(if ($FailureCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($UpdateCode -eq $false) {
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Navigate to terraform directory: cd terraform" -ForegroundColor White
    Write-Host "2. Deploy infrastructure: terraform apply" -ForegroundColor White
    Write-Host "3. Or update code only: .\scripts\deploy_lambda.ps1 -UpdateCode" -ForegroundColor White
}

Write-Host "==================================================================" -ForegroundColor Cyan

# Exit with appropriate code
if ($FailureCount -gt 0) {
    exit 1
}
exit 0
