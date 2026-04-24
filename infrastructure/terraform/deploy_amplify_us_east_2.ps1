# Deploy Amplify app to us-east-2 via Terraform
# Usage: .\deploy_amplify_us_east_2.ps1

param(
    [Parameter(Mandatory = $false)]
    [string]$GitHubToken = $env:GITHUB_TOKEN,
    
    [Parameter(Mandatory = $false)]
    [string]$Region = "us-east-2"
)

if ([string]::IsNullOrEmpty($GitHubToken)) {
    Write-Host "ERROR: GitHub token not provided" -ForegroundColor Red
    Write-Host ""
    Write-Host "Create a GitHub Personal Access Token (PAT):"
    Write-Host "  1. Go to: https://github.com/settings/tokens"
    Write-Host "  2. Click 'Generate new token' -> 'Generate new token (classic)'"
    Write-Host "  3. Select scope: 'repo' (Full control of private repositories)"
    Write-Host "  4. Copy the token"
    Write-Host ""
    Write-Host "Then run:"
    Write-Host "  `$env:GITHUB_TOKEN = 'ghp_xxxx...'"
    Write-Host "  .\deploy_amplify_us_east_2.ps1"
    Write-Host ""
    Write-Host "Or pass directly:"
    Write-Host "  .\deploy_amplify_us_east_2.ps1 -GitHubToken 'ghp_xxxx...'"
    exit 1
}

Write-Host "Deploying Amplify app to $Region..." -ForegroundColor Green
Write-Host ""

# Plan
Write-Host "Running terraform plan..." -ForegroundColor Cyan
terraform plan `
    -var="github_token=$GitHubToken" `
    -var="aws_region=$Region" `
    -out=tfplan_amplify

Write-Host ""
Write-Host "Review the plan above." -ForegroundColor Yellow
$confirm = Read-Host "Type 'yes' to apply"

if ($confirm -ne "yes") {
    Write-Host "Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

# Apply
Write-Host "Applying Terraform configuration..." -ForegroundColor Cyan
terraform apply tfplan_amplify

Write-Host ""
Write-Host "Amplify app deployment complete!" -ForegroundColor Green
Write-Host ""
terraform output -json | ConvertFrom-Json | Select-Object -Property amplify_app_id_us_east_2, amplify_default_domain_us_east_2 | Format-List
