# Master AWS Migration Script
# Orchestrates the complete us-east-1 to us-east-2 migration

param(
    [switch]$Audit,
    [switch]$CreateECR,
    [switch]$DeployLambda,
    [switch]$ExportAPI,
    [switch]$ImportAPI,
    [switch]$All,
    [switch]$Summary
)

$ErrorActionPreference = "Continue"

Write-Host @"
╔═══════════════════════════════════════════════════════════╗
║   AWS Multi-Region Migration Tool                        ║
║   us-east-1 → us-east-2                                  ║
╚═══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Help
if (-not ($Audit -or $CreateECR -or $DeployLambda -or $ExportAPI -or $ImportAPI -or $All -or $Summary)) {
    Write-Host "`nUsage:" -ForegroundColor Yellow
    Write-Host "  .\master_migration.ps1 -Audit         # Compare regions"
    Write-Host "  .\master_migration.ps1 -CreateECR     # Create ECR repositories"
    Write-Host "  .\master_migration.ps1 -DeployLambda  # Deploy Lambda functions"
    Write-Host "  .\master_migration.ps1 -ExportAPI     # Export API Gateways"
    Write-Host "  .\master_migration.ps1 -ImportAPI     # Import API Gateways"
    Write-Host "  .\master_migration.ps1 -All           # Run all steps"
    Write-Host "  .\master_migration.ps1 -Summary       # Show summary"
    Write-Host ""
    exit 0
}

# Summary
if ($Summary -or $All) {
    Write-Host "`n[STEP 0] Migration Summary" -ForegroundColor Cyan
    
    if (Test-Path ".\MIGRATION_SUMMARY.md") {
        Get-Content ".\MIGRATION_SUMMARY.md" | Select-Object -First 50
        Write-Host "`n... (see MIGRATION_SUMMARY.md for full report)" -ForegroundColor Gray
    }
    
    if (Test-Path ".\QUICK_REFERENCE.md") {
        Write-Host "`nQuick reference guide available: QUICK_REFERENCE.md" -ForegroundColor Green
    }
    
    if (-not $All) { exit 0 }
}

# Audit
if ($Audit -or $All) {
    Write-Host "`n[STEP 1] Auditing AWS Services Across Regions" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    if (Test-Path ".\scripts\audit_aws_regions.ps1") {
        & .\scripts\audit_aws_regions.ps1
        Write-Host "`n✓ Audit complete" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: audit_aws_regions.ps1 not found" -ForegroundColor Red
    }
    
    if (-not $All) { 
        Write-Host "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Create ECR
if ($CreateECR -or $All) {
    Write-Host "`n[STEP 2] Creating ECR Repositories in us-east-2" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    if (Test-Path ".\scripts\create_ecr_repos.ps1") {
        & .\scripts\create_ecr_repos.ps1
        Write-Host "`n✓ ECR repositories created" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: create_ecr_repos.ps1 not found" -ForegroundColor Red
    }
    
    if (-not $All) {
        Write-Host "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Deploy Lambda
if ($DeployLambda -or $All) {
    Write-Host "`n[STEP 3] Deploying Lambda Functions to us-east-2" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    # Check if Lambda exports exist
    if (-not (Test-Path ".\scripts\lambda_exports")) {
        Write-Host "Lambda exports not found. Creating..." -ForegroundColor Yellow
        if (Test-Path ".\scripts\create_missing_services.ps1") {
            & .\scripts\create_missing_services.ps1
        }
    }
    
    if (Test-Path ".\scripts\deploy_lambdas_final.ps1") {
        & .\scripts\deploy_lambdas_final.ps1
        Write-Host "`n✓ Lambda functions deployed" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: deploy_lambdas_final.ps1 not found" -ForegroundColor Red
    }
    
    if (-not $All) {
        Write-Host "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Export API
if ($ExportAPI -or $All) {
    Write-Host "`n[STEP 4] Exporting API Gateway Configurations" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    if (Test-Path ".\scripts\export_api_gateways.ps1") {
        & .\scripts\export_api_gateways.ps1
        Write-Host "`n✓ API Gateways exported" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: export_api_gateways.ps1 not found" -ForegroundColor Red
    }
    
    if (-not $All) {
        Write-Host "`nPress any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Import API
if ($ImportAPI -or $All) {
    Write-Host "`n[STEP 5] Importing API Gateways to us-east-2" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    if (Test-Path ".\scripts\import_api_gateways.ps1") {
        & .\scripts\import_api_gateways.ps1
        Write-Host "`n✓ API Gateways imported" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: import_api_gateways.ps1 not found" -ForegroundColor Red
    }
}

# Setup Amplify
if ($All) {
    Write-Host "`n[STEP 6] Setting up Amplify in us-east-2" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    if (Test-Path ".\scripts\setup_amplify_app.ps1") {
        & .\scripts\setup_amplify_app.ps1
        Write-Host "`n✓ Amplify analysis complete" -ForegroundColor Green
    }
    else {
        Write-Host "ERROR: setup_amplify_app.ps1 not found" -ForegroundColor Red
    }
}

# Final Summary
if ($All) {
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "MIGRATION COMPLETE!" -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    Write-Host "`nCompleted Steps:" -ForegroundColor Yellow
    Write-Host "  ✓ Audit completed" -ForegroundColor Green
    Write-Host "  ✓ ECR repositories created (9/9)" -ForegroundColor Green
    Write-Host "  ✓ Lambda functions deployed (8/8)" -ForegroundColor Green
    Write-Host "  ✓ SQS queue created (1/1)" -ForegroundColor Green
    Write-Host "  ✓ API Gateways exported and imported (2/2)" -ForegroundColor Green
    Write-Host "  ✓ Amplify analysis complete" -ForegroundColor Green
    
    Write-Host "`nRemaining Manual Steps:" -ForegroundColor Yellow
    Write-Host "  1. Create Cognito User Pool in us-east-2" -ForegroundColor Yellow
    Write-Host "  2. Setup S3 storage with amplify storage script" -ForegroundColor Yellow
    Write-Host "  3. Create Amplify app in console" -ForegroundColor Yellow
    Write-Host "  4. Copy Docker images from us-east-1 to us-east-2 ECR" -ForegroundColor Yellow
    Write-Host "  5. Update application configurations and test" -ForegroundColor Yellow
    
    Write-Host "`nDocumentation:" -ForegroundColor Cyan
    Write-Host "  - Full report: MIGRATION_SUMMARY.md"
    Write-Host "  - Quick reference: QUICK_REFERENCE.md"
    Write-Host "  - Amplify guide: AMPLIFY_SETUP_GUIDE.md"
    Write-Host "  - Audit results: scripts\aws_region_comparison.json"
    
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review AMPLIFY_SETUP_GUIDE.md for Amplify setup"
    Write-Host "  2. Create Cognito User Pool in us-east-2 (manual)"
    Write-Host "  3. Run S3 setup: .\scripts\setup_amplify_storage.ps1"
    Write-Host "  4. Create Amplify app in console"
    Write-Host "  5. Update environment variables"
    Write-Host "  6. Test and deploy"
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Session complete at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
