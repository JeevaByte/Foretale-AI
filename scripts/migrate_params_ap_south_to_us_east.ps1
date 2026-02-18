################################################################################
# DynamoDB Params Table Migration Script
# Migrates 104 items from ap-south-1 to us-east-2
# Transforms schema from old format to new format
################################################################################

param(
    [switch]$DryRun = $false,
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DynamoDB Params Migration Tool" -ForegroundColor Cyan
Write-Host "ap-south-1 → us-east-2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$sourceRegion = "ap-south-1"
$targetRegion = "us-east-2"
$sourceTable = "params"
$targetTable = "foretale-app-dynamodb-params"
$backupFile = "$env:TEMP\params-migration-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Source: $sourceTable ($sourceRegion)" -ForegroundColor White
Write-Host "  Target: $targetTable ($targetRegion)" -ForegroundColor White
Write-Host "  Backup: $backupFile" -ForegroundColor White
Write-Host ""

# Step 1: Check if target table exists
Write-Host "[1/6] Checking target table..." -ForegroundColor Yellow
try {
    $targetTableInfo = aws dynamodb describe-table `
        --table-name $targetTable `
        --region $targetRegion `
        --output json 2>$null | ConvertFrom-Json
    
    if ($targetTableInfo.Table.TableStatus -eq "ACTIVE") {
        Write-Host "  ✓ Target table exists and is ACTIVE" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Target table status: $($targetTableInfo.Table.TableStatus)" -ForegroundColor Red
        Write-Host "  Please run 'terraform apply' first to create the table" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Target table does not exist" -ForegroundColor Red
    Write-Host "  Please run 'terraform apply' first to create the table" -ForegroundColor Red
    exit 1
}

# Step 2: Scan source table
Write-Host "[2/6] Scanning source table..." -ForegroundColor Yellow
try {
    $scanResult = aws dynamodb scan `
        --table-name $sourceTable `
        --region $sourceRegion `
        --output json | ConvertFrom-Json
    
    $itemCount = $scanResult.Items.Count
    Write-Host "  ✓ Found $itemCount items in source table" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to scan source table" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Backup source data
Write-Host "[3/6] Backing up source data..." -ForegroundColor Yellow
try {
    $scanResult | ConvertTo-Json -Depth 10 | Out-File -FilePath $backupFile -Encoding UTF8
    Write-Host "  ✓ Backup saved to: $backupFile" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed to save backup" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Transform data
Write-Host "[4/6] Transforming data schema..." -ForegroundColor Yellow
$currentTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$transformedItems = @()

foreach ($item in $scanResult.Items) {
    # Extract values from old schema
    $pk = $item.PK.S
    $group = $item.GROUP.S
    $value = $item.VALUE.S
    
    # Create new schema item
    $newItem = @{
        "PK" = @{ "S" = $pk }
        "SK" = @{ "S" = "v1.0" }  # Default version
        "paramType" = @{ "S" = $group.ToLower() }
        "createdAt" = @{ "N" = $currentTimestamp.ToString() }
        "value" = @{ "S" = $value }
        "migrated" = @{ "BOOL" = $true }
        "migratedFrom" = @{ "S" = "ap-south-1" }
        "migratedAt" = @{ "N" = $currentTimestamp.ToString() }
        "originalGroup" = @{ "S" = $group }
    }
    
    $transformedItems += $newItem
}

Write-Host "  ✓ Transformed $($transformedItems.Count) items" -ForegroundColor Green
Write-Host ""
Write-Host "  Sample transformed item:" -ForegroundColor Cyan
$transformedItems[0] | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Would migrate $($transformedItems.Count) items" -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual migration" -ForegroundColor Yellow
    exit 0
}

# Step 5: Confirm migration
if (-not $Force) {
    Write-Host "Ready to migrate $($transformedItems.Count) items to $targetTable ($targetRegion)" -ForegroundColor Yellow
    Write-Host ""
    $confirmation = Read-Host "Proceed with migration? (yes/no)"
    
    if ($confirmation -ne "yes") {
        Write-Host "Migration cancelled" -ForegroundColor Yellow
        exit 0
    }
}

# Step 6: Write to target table
Write-Host "[5/6] Writing items to target table..." -ForegroundColor Yellow
$batchSize = 25  # DynamoDB batch write limit
$totalBatches = [Math]::Ceiling($transformedItems.Count / $batchSize)
$successCount = 0
$failedCount = 0

for ($i = 0; $i -lt $transformedItems.Count; $i += $batchSize) {
    $batchNum = [Math]::Floor($i / $batchSize) + 1
    $batch = $transformedItems[$i..([Math]::Min($i + $batchSize - 1, $transformedItems.Count - 1))]
    
    Write-Host "  Processing batch $batchNum/$totalBatches ($($batch.Count) items)..." -ForegroundColor Cyan
    
    # Create batch write request
    $requests = @()
    foreach ($item in $batch) {
        $requests += @{
            "PutRequest" = @{
                "Item" = $item
            }
        }
    }
    
    $batchWriteInput = @{
        $targetTable = $requests
    } | ConvertTo-Json -Depth 10 -Compress
    
    try {
        $result = aws dynamodb batch-write-item `
            --request-items $batchWriteInput `
            --region $targetRegion `
            --output json 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $successCount += $batch.Count
            Write-Host "    ✓ Batch $batchNum completed ($successCount/$($transformedItems.Count))" -ForegroundColor Green
        } else {
            $failedCount += $batch.Count
            Write-Host "    ✗ Batch $batchNum failed" -ForegroundColor Red
            Write-Host "    Error: $result" -ForegroundColor Red
        }
        
        # Throttle to avoid rate limits
        Start-Sleep -Milliseconds 100
    } catch {
        $failedCount += $batch.Count
        Write-Host "    ✗ Batch $batchNum failed" -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor Red
    }
}

# Step 6: Verify migration
Write-Host "[6/6] Verifying migration..." -ForegroundColor Yellow
try {
    $targetScan = aws dynamodb scan `
        --table-name $targetTable `
        --region $targetRegion `
        --select COUNT `
        --output json | ConvertFrom-Json
    
    $targetCount = $targetScan.Count
    Write-Host "  ✓ Target table now has $targetCount items" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Could not verify target count" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Migration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Source items:      $itemCount" -ForegroundColor White
Write-Host "Migrated items:    $successCount" -ForegroundColor Green
Write-Host "Failed items:      $failedCount" -ForegroundColor $(if ($failedCount -gt 0) { "Red" } else { "Green" })
Write-Host "Target item count: $targetCount" -ForegroundColor White
Write-Host "Backup location:   $backupFile" -ForegroundColor White
Write-Host ""

if ($successCount -eq $itemCount) {
    Write-Host "✓ Migration completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Verify data in AWS Console" -ForegroundColor White
    Write-Host "2. Test application with new table" -ForegroundColor White
    Write-Host "3. Update application to use us-east-2" -ForegroundColor White
    Write-Host "4. Optionally delete ap-south-1 table after verification" -ForegroundColor White
} else {
    Write-Host "⚠ Migration completed with errors" -ForegroundColor Yellow
    Write-Host "Review failed items and retry if needed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Verification commands:" -ForegroundColor Cyan
Write-Host "aws dynamodb scan --table-name $targetTable --region $targetRegion --output table" -ForegroundColor White
Write-Host ""
}
