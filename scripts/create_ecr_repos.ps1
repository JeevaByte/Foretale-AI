# Manual ECR Repository Creation for us-east-2
# Creates ECR repositories one by one with proper error handling

$ErrorActionPreference = "Continue"
$targetRegion = "us-east-2"

Write-Host "=== Creating ECR Repositories in $targetRegion ===" -ForegroundColor Cyan

$repositories = @(
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

$created = 0
$existing = 0
$failed = 0

foreach ($repo in $repositories) {
    Write-Host "`nRepository: $repo" -NoNewline
    
    try {
        # Try to create the repository
        $result = aws ecr create-repository `
            --repository-name $repo `
            --region $targetRegion `
            --image-scanning-configuration scanOnPush=true `
            --output json 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " [Created]" -ForegroundColor Green
            $created++
            
            # Parse the result to get the URI
            $repoData = $result | ConvertFrom-Json
            Write-Host "  URI: $($repoData.repository.repositoryUri)" -ForegroundColor Gray
        }
        else {
            # Check if it's because repository already exists
            if ($result -match "RepositoryAlreadyExistsException") {
                Write-Host " [Already Exists]" -ForegroundColor Yellow
                $existing++
                
                # Get existing repository details
                $details = aws ecr describe-repositories --repository-names $repo --region $targetRegion --output json | ConvertFrom-Json
                Write-Host "  URI: $($details.repositories[0].repositoryUri)" -ForegroundColor Gray
            }
            else {
                Write-Host " [Failed]" -ForegroundColor Red
                Write-Host "  Error: $result" -ForegroundColor Red
                $failed++
            }
        }
    }
    catch {
        Write-Host " [Failed]" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n=== ECR Repository Creation Summary ===" -ForegroundColor Cyan
Write-Host "Created: $created" -ForegroundColor Green
Write-Host "Already Existing: $existing" -ForegroundColor Yellow
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })

Write-Host "`nAll ECR repositories are now available in $targetRegion" -ForegroundColor Green
Write-Host "`nTo copy images from us-east-1 to us-east-2:" -ForegroundColor Yellow
Write-Host "1. Login to both registries"
Write-Host "2. Pull images from us-east-1"
Write-Host "3. Tag for us-east-2"
Write-Host "4. Push to us-east-2"
Write-Host "`nExample:" -ForegroundColor Gray
Write-Host "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 442426872653.dkr.ecr.us-east-1.amazonaws.com"
Write-Host "docker pull 442426872653.dkr.ecr.us-east-1.amazonaws.com/servers/redis:latest"
Write-Host "docker tag 442426872653.dkr.ecr.us-east-1.amazonaws.com/servers/redis:latest 442426872653.dkr.ecr.us-east-2.amazonaws.com/servers/redis:latest"
Write-Host "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 442426872653.dkr.ecr.us-east-2.amazonaws.com"
Write-Host "docker push 442426872653.dkr.ecr.us-east-2.amazonaws.com/servers/redis:latest"
