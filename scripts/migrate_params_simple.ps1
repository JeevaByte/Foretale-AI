# DynamoDB Params Migration: ap-south-1 → us-east-2
# Simple and direct migration script

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DynamoDB Params Migration" -ForegroundColor Cyan
Write-Host "ap-south-1 → us-east-2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$sourceRegion = "ap-south-1"
$targetRegion = "us-east-2"
$sourceTable = "params"
$targetTable = "foretale-app-dynamodb-params"

# Step 1: Check target table
Write-Host "[1/5] Checking target table..." -ForegroundColor Yellow
$checkTable = aws dynamodb describe-table --table-name $targetTable --region $targetRegion 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Target table does not exist. Run 'terraform apply' first." -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Target table exists" -ForegroundColor Green

# Step 2: Scan source table
Write-Host "[2/5] Scanning source table..." -ForegroundColor Yellow
$scanResult = aws dynamodb scan --table-name $sourceTable --region $sourceRegion --output json | ConvertFrom-Json
$itemCount = $scanResult.Items.Count
Write-Host "  ✓ Found $itemCount items" -ForegroundColor Green

# Step 3: Backup
Write-Host "[3/5] Creating backup..." -ForegroundColor Yellow
$backupFile = "$env:TEMP\params-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$scanResult | ConvertTo-Json -Depth 10 | Out-File -FilePath $backupFile -Encoding UTF8
Write-Host "  ✓ Backup saved: $backupFile" -ForegroundColor Green

# Step 4: Transform and migrate
Write-Host "[4/5] Migrating items..." -ForegroundColor Yellow
$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$success = 0
$failed = 0

foreach ($item in $scanResult.Items) {
    $pk = $item.PK.S
    $group = $item.GROUP.S
    $value = $item.VALUE.S
    
    # Create JSON for put-item
    $newItem = @"
{
    "PK": {"S": "$pk"},
    "SK": {"S": "v1.0"},
    "paramType": {"S": "$($group.ToLower())"},
    "createdAt": {"N": "$timestamp"},
    "value": {"S": "$value"},
    "migrated": {"BOOL": true},
    "migratedFrom": {"S": "ap-south-1"},
    "originalGroup": {"S": "$group"}
}
"@
    
    # Write to target table
    $result = aws dynamodb put-item `
        --table-name $targetTable `
        --region $targetRegion `
        --item $newItem 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $success++
        if ($success % 10 -eq 0) {
            Write-Host "    Progress: $success/$itemCount" -ForegroundColor Cyan
        }
    } else {
        $failed++
        Write-Host "    ✗ Failed: $pk - $result" -ForegroundColor Red
    }
}

# Step 5: Verify
Write-Host "[5/5] Verifying migration..." -ForegroundColor Yellow
$targetScan = aws dynamodb scan --table-name $targetTable --region $targetRegion --select COUNT --output json | ConvertFrom-Json
Write-Host "  ✓ Target table now has $($targetScan.Count) items" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Migration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Source items:  $itemCount" -ForegroundColor White
Write-Host "Migrated:      $success" -ForegroundColor Green
Write-Host "Failed:        $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "Target count:  $($targetScan.Count)" -ForegroundColor White
Write-Host "Backup:        $backupFile" -ForegroundColor White
Write-Host ""

if ($success -eq $itemCount) {
    Write-Host "✓ Migration completed successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠ Migration completed with errors" -ForegroundColor Yellow
}
