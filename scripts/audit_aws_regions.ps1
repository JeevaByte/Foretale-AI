# AWS Multi-Region Service Audit and Comparison Script
# Compares services between us-east-1 and us-east-2

$ErrorActionPreference = "Continue"
$region1 = "us-east-1"
$region2 = "us-east-2"

Write-Host "=== AWS Multi-Region Service Audit ===" -ForegroundColor Cyan
Write-Host "Comparing: $region1 vs $region2`n" -ForegroundColor Yellow

# Function to check service resources
function Get-ServiceResources {
    param(
        [string]$Region,
        [string]$ServiceName
    )
    
    $resources = @{
        Found = $false
        Count = 0
        Details = @()
    }
    
    try {
        switch ($ServiceName) {
            "EC2" {
                $instances = aws ec2 describe-instances --region $Region --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output json 2>$null | ConvertFrom-Json
                if ($instances -and $instances.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $instances.Count
                    $resources.Details = $instances
                }
            }
            "RDS" {
                $dbs = aws rds describe-db-instances --region $Region --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output json 2>$null | ConvertFrom-Json
                if ($dbs -and $dbs.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $dbs.Count
                    $resources.Details = $dbs
                }
            }
            "S3" {
                # S3 is global but buckets can have region constraints
                $buckets = aws s3api list-buckets --query 'Buckets[*].Name' --output json 2>$null | ConvertFrom-Json
                $regionBuckets = @()
                foreach ($bucket in $buckets) {
                    $location = aws s3api get-bucket-location --bucket $bucket --output text 2>$null
                    if ($location -eq $Region -or ($location -eq "None" -and $Region -eq "us-east-1")) {
                        $regionBuckets += $bucket
                    }
                }
                if ($regionBuckets.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $regionBuckets.Count
                    $resources.Details = $regionBuckets
                }
            }
            "Lambda" {
                $functions = aws lambda list-functions --region $Region --query 'Functions[*].[FunctionName,Runtime,LastModified]' --output json 2>$null | ConvertFrom-Json
                if ($functions -and $functions.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $functions.Count
                    $resources.Details = $functions
                }
            }
            "DynamoDB" {
                $tables = aws dynamodb list-tables --region $Region --query 'TableNames' --output json 2>$null | ConvertFrom-Json
                if ($tables -and $tables.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $tables.Count
                    $resources.Details = $tables
                }
            }
            "APIGateway" {
                $apis = aws apigateway get-rest-apis --region $Region --query 'items[*].[id,name,createdDate]' --output json 2>$null | ConvertFrom-Json
                if ($apis -and $apis.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $apis.Count
                    $resources.Details = $apis
                }
            }
            "SQS" {
                $queues = aws sqs list-queues --region $Region --query 'QueueUrls' --output json 2>$null | ConvertFrom-Json
                if ($queues -and $queues.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $queues.Count
                    $resources.Details = $queues
                }
            }
            "SNS" {
                $topics = aws sns list-topics --region $Region --query 'Topics[*].TopicArn' --output json 2>$null | ConvertFrom-Json
                if ($topics -and $topics.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $topics.Count
                    $resources.Details = $topics
                }
            }
            "ELB" {
                $lbs = aws elbv2 describe-load-balancers --region $Region --query 'LoadBalancers[*].[LoadBalancerName,Type,State.Code]' --output json 2>$null | ConvertFrom-Json
                if ($lbs -and $lbs.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $lbs.Count
                    $resources.Details = $lbs
                }
            }
            "VPC" {
                $vpcs = aws ec2 describe-vpcs --region $Region --query 'Vpcs[?!IsDefault].[VpcId,CidrBlock]' --output json 2>$null | ConvertFrom-Json
                if ($vpcs -and $vpcs.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $vpcs.Count
                    $resources.Details = $vpcs
                }
            }
            "ECR" {
                $repos = aws ecr describe-repositories --region $Region --query 'repositories[*].[repositoryName,repositoryUri]' --output json 2>$null | ConvertFrom-Json
                if ($repos -and $repos.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $repos.Count
                    $resources.Details = $repos
                }
            }
            "Amplify" {
                $apps = aws amplify list-apps --region $Region --query 'apps[*].[appId,name,platform]' --output json 2>$null | ConvertFrom-Json
                if ($apps -and $apps.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $apps.Count
                    $resources.Details = $apps
                }
            }
            "KMS" {
                $keys = aws kms list-keys --region $Region --query 'Keys[*].KeyId' --output json 2>$null | ConvertFrom-Json
                if ($keys -and $keys.Count -gt 0) {
                    # Filter out AWS managed keys
                    $customerKeys = @()
                    foreach ($key in $keys) {
                        $metadata = aws kms describe-key --region $Region --key-id $key --query 'KeyMetadata.KeyManager' --output text 2>$null
                        if ($metadata -eq "CUSTOMER") {
                            $customerKeys += $key
                        }
                    }
                    if ($customerKeys.Count -gt 0) {
                        $resources.Found = $true
                        $resources.Count = $customerKeys.Count
                        $resources.Details = $customerKeys
                    }
                }
            }
            "Glue" {
                $databases = aws glue get-databases --region $Region --query 'DatabaseList[*].Name' --output json 2>$null | ConvertFrom-Json
                if ($databases -and $databases.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $databases.Count
                    $resources.Details = $databases
                }
            }
            "CloudWatch" {
                $alarms = aws cloudwatch describe-alarms --region $Region --query 'MetricAlarms[*].[AlarmName,StateValue]' --output json 2>$null | ConvertFrom-Json
                if ($alarms -and $alarms.Count -gt 0) {
                    $resources.Found = $true
                    $resources.Count = $alarms.Count
                    $resources.Details = $alarms
                }
            }
        }
    }
    catch {
        $resources.Error = $_.Exception.Message
    }
    
    return $resources
}

# Services to check (based on user's list)
$services = @(
    @{Name="EC2"; Display="Amazon EC2"},
    @{Name="RDS"; Display="Amazon RDS"},
    @{Name="S3"; Display="Amazon S3"},
    @{Name="Lambda"; Display="AWS Lambda"},
    @{Name="DynamoDB"; Display="Amazon DynamoDB"},
    @{Name="APIGateway"; Display="Amazon API Gateway"},
    @{Name="SQS"; Display="Amazon SQS"},
    @{Name="SNS"; Display="Amazon SNS"},
    @{Name="ELB"; Display="Elastic Load Balancing"},
    @{Name="VPC"; Display="Amazon VPC"},
    @{Name="ECR"; Display="Amazon ECR"},
    @{Name="Amplify"; Display="AWS Amplify"},
    @{Name="KMS"; Display="AWS KMS"},
    @{Name="Glue"; Display="AWS Glue"},
    @{Name="CloudWatch"; Display="Amazon CloudWatch"}
)

# Compare services across regions
Write-Host "Scanning services in both regions..." -ForegroundColor Yellow

$comparison = @()

foreach ($service in $services) {
    Write-Host "  Checking $($service.Display)..." -NoNewline
    
    $r1 = Get-ServiceResources -Region $region1 -ServiceName $service.Name
    $r2 = Get-ServiceResources -Region $region2 -ServiceName $service.Name
    
    $status = ""
    $action = ""
    
    if ($r1.Found -and -not $r2.Found) {
        $status = "Missing in us-east-2"
        $action = "CREATE"
        Write-Host " [MISSING in us-east-2]" -ForegroundColor Red
    }
    elseif (-not $r1.Found -and $r2.Found) {
        $status = "Only in us-east-2"
        $action = "INFO"
        Write-Host " [Only in us-east-2]" -ForegroundColor Yellow
    }
    elseif ($r1.Found -and $r2.Found) {
        $status = "Present in both"
        $action = "VERIFY"
        Write-Host " [Both regions]" -ForegroundColor Green
    }
    else {
        $status = "Not found in either"
        $action = "SKIP"
        Write-Host " [None]" -ForegroundColor Gray
    }
    
    $comparison += [PSCustomObject]@{
        Service = $service.Display
        Status = $status
        Action = $action
        Region1Count = $r1.Count
        Region2Count = $r2.Count
        Region1Details = $r1.Details
        Region2Details = $r2.Details
    }
}

# Display summary
Write-Host "`n=== COMPARISON SUMMARY ===" -ForegroundColor Cyan
$comparison | Format-Table Service, Status, Action, Region1Count, Region2Count -AutoSize

# Services that need to be created in us-east-2
Write-Host "`n=== SERVICES TO CREATE IN us-east-2 ===" -ForegroundColor Red
$toCreate = $comparison | Where-Object { $_.Action -eq "CREATE" }

if ($toCreate.Count -eq 0) {
    Write-Host "All services from us-east-1 are present in us-east-2!" -ForegroundColor Green
}
else {
    foreach ($item in $toCreate) {
        Write-Host "`n$($item.Service):" -ForegroundColor Yellow
        Write-Host "  Resources in us-east-1: $($item.Region1Count)"
        Write-Host "  Details:" -ForegroundColor Gray
        $item.Region1Details | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
    }
}

# Export detailed report
$reportPath = Join-Path $PSScriptRoot "aws_region_comparison.json"
$comparison | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nDetailed report saved to: $reportPath" -ForegroundColor Cyan

# Generate migration commands
Write-Host "`n=== MIGRATION GUIDANCE ===" -ForegroundColor Cyan
Write-Host "To replicate services to us-east-2, consider these approaches:`n"

foreach ($item in $toCreate) {
    Write-Host "$($item.Service):" -ForegroundColor Yellow
    
    switch -Wildcard ($item.Service) {
        "*EC2*" {
            Write-Host "  - Create AMI from instances in us-east-1 and copy to us-east-2"
            Write-Host "  - Launch new instances from copied AMI"
        }
        "*RDS*" {
            Write-Host "  - Create snapshot of RDS instance in us-east-1"
            Write-Host "  - Copy snapshot to us-east-2"
            Write-Host "  - Restore from snapshot in us-east-2"
        }
        "*S3*" {
            Write-Host "  - Use S3 replication or aws s3 sync to replicate buckets"
        }
        "*Lambda*" {
            Write-Host "  - Download function code and redeploy to us-east-2"
            Write-Host "  - Or use SAM/CloudFormation for multi-region deployment"
        }
        "*DynamoDB*" {
            Write-Host "  - Enable DynamoDB Global Tables"
            Write-Host "  - Or export/import data to new table in us-east-2"
        }
        "*API Gateway*" {
            Write-Host "  - Export API definition and import to us-east-2"
            Write-Host "  - Or use CloudFormation/Terraform for IaC deployment"
        }
        "*SQS*" {
            Write-Host "  - Recreate queue configuration in us-east-2"
        }
        "*SNS*" {
            Write-Host "  - Recreate topics and subscriptions in us-east-2"
        }
        "*Load Balancing*" {
            Write-Host "  - Recreate load balancer configuration in us-east-2"
            Write-Host "  - Configure target groups with new region resources"
        }
        "*VPC*" {
            Write-Host "  - Create VPC with matching CIDR blocks in us-east-2"
            Write-Host "  - Set up VPC peering if needed"
        }
        "*ECR*" {
            Write-Host "  - Create repositories in us-east-2"
            Write-Host "  - Use 'docker pull/tag/push' to copy images"
        }
        "*Amplify*" {
            Write-Host "  - Create new Amplify app in us-east-2"
            Write-Host "  - Configure same backend resources"
        }
        "*KMS*" {
            Write-Host "  - Create new KMS keys in us-east-2 (keys cannot be copied)"
            Write-Host "  - Update applications to use region-specific keys"
        }
        "*Glue*" {
            Write-Host "  - Export Glue job scripts and recreate in us-east-2"
        }
        "*CloudWatch*" {
            Write-Host "  - Recreate alarms and dashboards in us-east-2"
        }
    }
    Write-Host ""
}

Write-Host "=== AUDIT COMPLETE ===" -ForegroundColor Green
