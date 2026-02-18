#!/usr/bin/env powershell
# Migrate DynamoDB params table from ap-south-1 to us-east-2

$ErrorActionPreference = "Continue"
$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DynamoDB Params Table Migration" -ForegroundColor Cyan
Write-Host "Source: params (ap-south-1)" -ForegroundColor Cyan
Write-Host "Target: foretale-app-dynamodb-params (us-east-2)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Scan source table
Write-Host "[1/4] Scanning source table..." -ForegroundColor Yellow
$scanOutput = aws dynamodb scan --table-name params --region ap-south-1 --output json

if ($LASTEXITCODE -ne 0) {
    Write-Host "X Failed to scan source table" -ForegroundColor Red
    exit 1
}

$scanResult = $scanOutput | ConvertFrom-Json
$totalItems = $scanResult.Items.Count
Write-Host "OK Found $totalItems items to migrate`n" -ForegroundColor Green

# Prepare migration
Write-Host "[2/4] Preparing migration..." -ForegroundColor Yellow
$success = 0
$failed = 0
$failedItems = @()

# Migrate each item
Write-Host "[3/4] Migrating items...`n" -ForegroundColor Yellow

foreach ($item in $scanResult.Items) {
    $pk = $item.PK.S
    $group = $item.GROUP.S
    $value = $item.VALUE.S
    
    # Use AWS CLI with direct item format
    $null = aws dynamodb put-item --table-name foretale-app-dynamodb-params `
        --item "PK={S=$pk},SK={S=v1.0},paramType={S=$($group.ToLower())},createdAt={N=$timestamp},value={S=$value},migrated={BOOL=true},migratedFrom={S=ap-south-1},originalGroup={S=$group}" `
        --region us-east-2 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $success = $success + 1
        if (($success % 10) -eq 0) {
            Write-Host "  OK Migrated $success / $totalItems items..." -ForegroundColor Green
        }
    }
    else {
        $failed = $failed + 1
        $failedItems = $failedItems + $pk
        Write-Host "  X Failed: $pk" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n[4/4] Migration Summary:" -ForegroundColor Yellow
Write-Host "  Total items: $totalItems" -ForegroundColor Cyan
Write-Host "  Successful: $success" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($failed -gt 0) {
    Write-Host "`nFailed items:" -ForegroundColor Red
    foreach ($item in $failedItems) {
        Write-Host "  - $item" -ForegroundColor Red
    }
}

# Verify migration
Write-Host "`nVerifying migration..." -ForegroundColor Yellow
$verifyResult = aws dynamodb scan --table-name foretale-app-dynamodb-params --region us-east-2 --select COUNT --output json | ConvertFrom-Json
$targetCount = $verifyResult.Count

Write-Host "  Source: $totalItems items" -ForegroundColor Cyan
Write-Host "  Target: $targetCount items" -ForegroundColor Cyan

if ($targetCount -eq $totalItems) {
    Write-Host "`nMigration completed successfully!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`nMigration incomplete. Please review failed items." -ForegroundColor Yellow
    exit 1
}
