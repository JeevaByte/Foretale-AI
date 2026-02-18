# Create API Gateways in us-east-2
# Exports and prepares API Gateway configurations

param(
    [string]$SourceRegion = "us-east-1",
    [string]$TargetRegion = "us-east-2"
)

$ErrorActionPreference = "Continue"
$exportDir = Join-Path $PSScriptRoot "api_gateway_exports"

if (-not (Test-Path $exportDir)) {
    New-Item -ItemType Directory -Path $exportDir | Out-Null
}

Write-Host "=== API Gateway Export and Migration ===" -ForegroundColor Cyan

$apis = @(
    @{Id="itpkscu97c"; Name="api-ecs-task-invoker"},
    @{Id="uq56kj6m5f"; Name="api-sql-procedure-invoker"}
)

foreach ($api in $apis) {
    Write-Host "`nProcessing API: $($api.Name)" -ForegroundColor Yellow
    Write-Host "  API ID: $($api.Id)"
    
    # Get API details
    Write-Host "  Fetching API details..." -NoNewline
    $apiDetails = aws apigateway get-rest-api --rest-api-id $($api.Id) --region $SourceRegion --output json 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $detailsFile = Join-Path $exportDir "$($api.Name)_details.json"
        $apiDetails | Out-File -FilePath $detailsFile -Encoding UTF8
        Write-Host " [Saved]" -ForegroundColor Green
    }
    
    # Export as Swagger/OpenAPI
    Write-Host "  Exporting API definition..." -NoNewline
    $swaggerFile = Join-Path $exportDir "$($api.Name)_swagger.json"
    
    $export = aws apigateway get-export `
        --rest-api-id $($api.Id) `
        --stage-name prod `
        --export-type swagger `
        --accepts application/json `
        --region $SourceRegion 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $export | Out-File -FilePath $swaggerFile -Encoding UTF8
        Write-Host " [Exported]" -ForegroundColor Green
        Write-Host "  File: $swaggerFile" -ForegroundColor Gray
    }
    else {
        # Try with 'oas30' format
        Write-Host " [Trying OAS3.0...]" -ForegroundColor Yellow
        $oasFile = Join-Path $exportDir "$($api.Name)_oas30.json"
        
        $oas = aws apigateway get-export `
            --rest-api-id $($api.Id) `
            --stage-name prod `
            --export-type oas30 `
            --accepts application/json `
            --region $SourceRegion 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $oas | Out-File -FilePath $oasFile -Encoding UTF8
            Write-Host "  [Exported as OAS3.0]" -ForegroundColor Green
            Write-Host "  File: $oasFile" -ForegroundColor Gray
        }
    }
    
    # Get stages
    Write-Host "  Fetching stages..." -NoNewline
    $stages = aws apigateway get-stages --rest-api-id $($api.Id) --region $SourceRegion --output json 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $stagesFile = Join-Path $exportDir "$($api.Name)_stages.json"
        $stages | Out-File -FilePath $stagesFile -Encoding UTF8
        Write-Host " [Saved]" -ForegroundColor Green
    }
    
    # Get resources
    Write-Host "  Fetching resources..." -NoNewline
    $resources = aws apigateway get-resources --rest-api-id $($api.Id) --region $SourceRegion --output json 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $resourcesFile = Join-Path $exportDir "$($api.Name)_resources.json"
        $resources | Out-File -FilePath $resourcesFile -Encoding UTF8
        Write-Host " [Saved]" -ForegroundColor Green
    }
}

Write-Host "`n=== IMPORT INSTRUCTIONS ===" -ForegroundColor Cyan
Write-Host "To import these APIs to $TargetRegion, use one of these methods:`n"

Write-Host "Method 1: AWS CLI Import" -ForegroundColor Yellow
foreach ($api in $apis) {
    $swaggerFile = Join-Path $exportDir "$($api.Name)_swagger.json"
    if (Test-Path $swaggerFile) {
        Write-Host "`nImport $($api.Name):"
        Write-Host "  aws apigateway import-rest-api \" -ForegroundColor Gray
        Write-Host "    --body file://$swaggerFile \" -ForegroundColor Gray
        Write-Host "    --region $TargetRegion" -ForegroundColor Gray
    }
}

Write-Host "`n`nMethod 2: AWS Console" -ForegroundColor Yellow
Write-Host "1. Navigate to API Gateway console in $TargetRegion"
Write-Host "2. Click 'Create API' > 'REST API' > 'Import'"
Write-Host "3. Upload the exported Swagger/OAS file"
Write-Host "4. Configure integration endpoints (Lambda functions)"
Write-Host "5. Deploy to a stage"

Write-Host "`n`nMethod 3: Using Terraform/CloudFormation" -ForegroundColor Yellow
Write-Host "Convert the exported definitions to IaC for repeatable deployment"

Write-Host "`n`nIMPORTANT NOTES:" -ForegroundColor Red
Write-Host "- Update Lambda function ARNs in the API definitions to use us-east-2 functions"
Write-Host "- Reconfigure authorization if using Cognito or IAM"
Write-Host "- Update custom domain names if applicable"
Write-Host "- Test all endpoints after import"

Write-Host "`nExported files are in: $exportDir" -ForegroundColor Cyan
Write-Host "`n=== EXPORT COMPLETE ===" -ForegroundColor Green
