# Force delete all S3 buckets in us-east-2 region
# This script removes all objects, versions, and delete markers before deleting buckets

$ErrorActionPreference = 'Continue'
$region = 'us-east-2'

$buckets = @(
    'amplify-foretaleapplication-dev-18d56-deployment-us-east-2',
    'amplify-foretaleapplication-dev-c6950-deployment-us-east-2',
    'foretale-dev-analytics',
    'foretale-dev-analytics-us-east-2',
    'foretale-dev-app-storage',
    'foretale-dev-app-storage-us-east-2',
    'foretale-dev-backups',
    'foretale-dev-backups-us-east-2',
    'foretale-dev-user-uploads',
    'foretale-dev-user-uploads-us-east-2',
    'foretale-dev-vector-db-us-east-2',
    'foretale-lambda-layer-uploads-with-versioning-us-east-2',
    'foretale-s3-bucket31e03-dev-us-east-2',
    'foretale-s3-bucket8a4b6-dev-us-east-2',
    'foretale-s3-bucketc6950-dev-us-east-2'
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "S3 Bucket Deletion Script" -ForegroundColor Cyan
Write-Host "Region: $region" -ForegroundColor Cyan
Write-Host "Total Buckets: $($buckets.Count)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$successCount = 0
$failedBuckets = @()

foreach ($bucket in $buckets) {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Processing: $bucket" -ForegroundColor Yellow
    
    try {
        # Check if bucket exists
        $null = aws s3api head-bucket --bucket $bucket --region $region 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  └─ Bucket doesn't exist (already deleted)" -ForegroundColor Gray
            $successCount++
            continue
        }
        
        Write-Host "  ├─ Suspending versioning..." -ForegroundColor White
        aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Suspended --region $region 2>&1 | Out-Null
        
        Write-Host "  ├─ Deleting all objects and versions..." -ForegroundColor White
        aws s3 rm "s3://$bucket" --recursive --region $region 2>&1 | Out-Null
        
        # Delete all versions
        $versions = aws s3api list-object-versions --bucket $bucket --region $region --output json 2>&1 | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($versions.Versions) {
            Write-Host "  ├─ Found $($versions.Versions.Count) versions to delete..." -ForegroundColor White
            foreach ($version in $versions.Versions) {
                aws s3api delete-object --bucket $bucket --key $version.Key --version-id $version.VersionId --region $region 2>&1 | Out-Null
            }
        }
        
        # Delete all delete markers
        if ($versions.DeleteMarkers) {
            Write-Host "  ├─ Found $($versions.DeleteMarkers.Count) delete markers to remove..." -ForegroundColor White
            foreach ($marker in $versions.DeleteMarkers) {
                aws s3api delete-object --bucket $bucket --key $marker.Key --version-id $marker.VersionId --region $region 2>&1 | Out-Null
            }
        }
        
        Write-Host "  ├─ Deleting bucket..." -ForegroundColor White
        aws s3api delete-bucket --bucket $bucket --region $region 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  └─ ✅ Successfully deleted!" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  └─ ❌ Failed to delete bucket" -ForegroundColor Red
            $failedBuckets += $bucket
        }
    }
    catch {
        Write-Host "  └─ ❌ Error: $_" -ForegroundColor Red
        $failedBuckets += $bucket
    }
    
    Write-Host ""
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Deletion Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total buckets: $($buckets.Count)" -ForegroundColor White
Write-Host "Successfully deleted: $successCount" -ForegroundColor Green
Write-Host "Failed: $($failedBuckets.Count)" -ForegroundColor Red

if ($failedBuckets.Count -gt 0) {
    Write-Host "`nFailed buckets:" -ForegroundColor Red
    $failedBuckets | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
} else {
    Write-Host "`n✅ All buckets deleted successfully!" -ForegroundColor Green
}
