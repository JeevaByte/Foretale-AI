# Setup S3 Storage for Amplify in us-east-2
# Replicates S3 bucket configuration from us-east-1

param(
    [string]$SourceRegion = "us-east-1",
    [string]$TargetRegion = "us-east-2",
    [string]$AppName = "foretale"
)

$ErrorActionPreference = "Continue"

Write-Host "=== S3 Storage Setup for $TargetRegion ===" -ForegroundColor Cyan

# Step 1: Find source bucket
Write-Host "`n[Step 1] Finding source S3 bucket..." -ForegroundColor Yellow

$buckets = aws s3api list-buckets --output json | ConvertFrom-Json
$sourceBucket = $buckets.Buckets | Where-Object { $_.Name -like "*$AppName*" -or $_.Name -like "*foretale*" } | Select-Object -First 1

if (-not $sourceBucket) {
    Write-Host "ERROR: No S3 bucket found matching '$AppName'" -ForegroundColor Red
    exit 1
}

Write-Host "Found source bucket: $($sourceBucket.Name)" -ForegroundColor Green

# Step 2: Get source bucket configuration
Write-Host "`n[Step 2] Fetching source bucket configuration..." -ForegroundColor Yellow

# Get bucket location
$location = aws s3api get-bucket-location --bucket $($sourceBucket.Name) --output json | ConvertFrom-Json
Write-Host "  Region: $($location.LocationConstraint)" -ForegroundColor Gray

# Get bucket versioning
$versioning = aws s3api get-bucket-versioning --bucket $($sourceBucket.Name) --output json | ConvertFrom-Json
Write-Host "  Versioning: $($versioning.Status)" -ForegroundColor Gray

# Get CORS
$cors = aws s3api get-bucket-cors --bucket $($sourceBucket.Name) 2>$null
Write-Host "  CORS: $($cors ? 'Enabled' : 'Not configured')" -ForegroundColor Gray

# Step 3: Create target bucket
Write-Host "`n[Step 3] Creating target S3 bucket..." -ForegroundColor Yellow

$newBucketName = "$($sourceBucket.Name -replace "-us-east-1$", "")-${TargetRegion}"
$newBucketName = $newBucketName.ToLower() -replace "[^a-z0-9-]", ""

Write-Host "Creating bucket: $newBucketName" -NoNewline

try {
    if ($TargetRegion -eq "us-east-1") {
        # us-east-1 doesn't need LocationConstraint
        aws s3api create-bucket --bucket $newBucketName --region $TargetRegion | Out-Null
    }
    else {
        aws s3api create-bucket `
            --bucket $newBucketName `
            --region $TargetRegion `
            --create-bucket-configuration LocationConstraint=$TargetRegion | Out-Null
    }
    
    Write-Host " [Created]" -ForegroundColor Green
}
catch {
    Write-Host " [Failed]" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Configure bucket settings
Write-Host "`n[Step 4] Configuring bucket settings..." -ForegroundColor Yellow

# Enable versioning
Write-Host "  Enabling versioning..." -NoNewline
aws s3api put-bucket-versioning `
    --bucket $newBucketName `
    --versioning-configuration Status=Enabled `
    --region $TargetRegion | Out-Null
Write-Host " [OK]" -ForegroundColor Green

# Block public access
Write-Host "  Blocking public access..." -NoNewline
aws s3api put-public-access-block `
    --bucket $newBucketName `
    --public-access-block-configuration @"
{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
}
"@ --region $TargetRegion | Out-Null
Write-Host " [OK]" -ForegroundColor Green

# Enable encryption
Write-Host "  Enabling server-side encryption..." -NoNewline
aws s3api put-bucket-encryption `
    --bucket $newBucketName `
    --server-side-encryption-configuration @"
{
    "Rules": [
        {
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }
    ]
}
"@ --region $TargetRegion | Out-Null
Write-Host " [OK]" -ForegroundColor Green

# Step 5: Configure CORS
Write-Host "`n[Step 5] Configuring CORS..." -NoNewline

$corsConfig = @"
{
    "CORSRules": [
        {
            "AllowedHeaders": [
                "*"
            ],
            "AllowedMethods": [
                "GET",
                "PUT",
                "POST",
                "DELETE",
                "HEAD"
            ],
            "AllowedOrigins": [
                "*"
            ],
            "ExposeHeaders": [
                "ETag",
                "x-amz-version-id"
            ],
            "MaxAgeSeconds": 3000
        }
    ]
}
"@

aws s3api put-bucket-cors `
    --bucket $newBucketName `
    --cors-configuration $corsConfig `
    --region $TargetRegion | Out-Null

Write-Host " [Configured]" -ForegroundColor Green

# Step 6: Setup lifecycle policies
Write-Host "`n[Step 6] Setting up lifecycle policies..." -ForegroundColor Yellow

$lifecycleConfig = @"
{
    "Rules": [
        {
            "Id": "DeleteOldVersions",
            "NoncurrentVersionExpiration": {
                "NoncurrentDays": 90
            },
            "Status": "Enabled"
        },
        {
            "Id": "DeleteIncompleteMultipart",
            "AbortIncompleteMultipartUpload": {
                "DaysAfterInitiation": 7
            },
            "Status": "Enabled"
        }
    ]
}
"@

try {
    aws s3api put-bucket-lifecycle-configuration `
        --bucket $newBucketName `
        --lifecycle-configuration $lifecycleConfig `
        --region $TargetRegion | Out-Null
    
    Write-Host "  Lifecycle policies configured" -ForegroundColor Green
}
catch {
    Write-Host "  Lifecycle policy error: $_" -ForegroundColor Yellow
}

# Step 7: Copy data (optional)
Write-Host "`n[Step 7] Data replication options..." -ForegroundColor Yellow

Write-Host @"

To copy data from $($sourceBucket.Name) to $newBucketName:

Option 1: AWS S3 Sync (Recommended)
  aws s3 sync s3://$($sourceBucket.Name) s3://$newBucketName --region $TargetRegion --source-region $SourceRegion

Option 2: Cross-region replication (for ongoing sync)
  1. Enable versioning (already done)
  2. Setup replication role
  3. Configure replication rule
  
  aws s3api put-bucket-replication \
    --bucket $($sourceBucket.Name) \
    --replication-configuration file://replication-config.json \
    --region $SourceRegion

Option 3: Manual file upload
  aws s3 cp LOCAL_FILE s3://$newBucketName/KEY

"@

# Step 8: Setup IAM policy for bucket access
Write-Host "`n[Step 8] Setting up IAM policy..." -ForegroundColor Yellow

$bucketPolicy = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAmplifyAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::${newBucketName}/*"
        },
        {
            "Sid": "AllowListBucket",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${newBucketName}"
        }
    ]
}
"@

Write-Host @"

To allow Amplify and your application to access this bucket, attach this policy to your Lambda execution role:

\`\`\`json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::${newBucketName}/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${newBucketName}"
        }
    ]
}
\`\`\`

"@

# Step 9: Summary
Write-Host "`n[Step 9] Configuration Summary" -ForegroundColor Cyan
Write-Host "=" * 60

Write-Host @"

SOURCE BUCKET:
  Name: $($sourceBucket.Name)
  Region: $($location.LocationConstraint)

NEW BUCKET:
  Name: $newBucketName
  Region: $TargetRegion

BUCKET CONFIGURATION:
  Versioning: Enabled
  Encryption: AES256
  CORS: Enabled
  Public Access: Blocked
  Lifecycle: Configured

UPDATE YOUR AMPLIFY CONFIG:

storage:
  s3:
    bucket: $newBucketName
    region: $TargetRegion
    level: public  # or 'protected' / 'private'

ENVIRONMENT VARIABLES:

STORAGE_BUCKET=$newBucketName
STORAGE_REGION=$TargetRegion
STORAGE_LEVEL=public

NEXT STEPS:

1. Copy data from source bucket (optional):
   aws s3 sync s3://$($sourceBucket.Name) s3://$newBucketName --region $TargetRegion

2. Attach IAM policy to your Lambda execution role

3. Update your application code with new bucket name

4. Test file upload/download operations

"@

# Save configuration
$configFile = Join-Path $PSScriptRoot "s3_config_${TargetRegion}.json"
$s3Config = @{
    sourceBucket = $sourceBucket.Name
    sourceRegion = $SourceRegion
    newBucket = $newBucketName
    targetRegion = $TargetRegion
    configuration = @{
        versioning = "Enabled"
        encryption = "AES256"
        cors = "Enabled"
        publicAccessBlock = "Enabled"
    }
}

$s3Config | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8

Write-Host "`nConfiguration saved to: $configFile" -ForegroundColor Green
Write-Host "`n=== S3 SETUP COMPLETE ===" -ForegroundColor Green
