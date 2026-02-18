# CI/CD Pipeline for ForeTale Application
## Automated Docker Build, Security Scan, and ECS Deployment

This module implements a complete CI/CD pipeline following industry best practices for containerized applications.

---

## Architecture Overview

```
┌─────────────────┐
│  CodeCommit     │  1. Developer pushes code
│  Repository     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  EventBridge    │  2. Triggers on branch push
│  Rule           │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    CodePipeline                              │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Source   │→ │  Build   │→ │ Security │→ │ Approval │   │
│  │          │  │          │  │   Scan   │  │(Prod)    │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                     │        │
│                                      ┌──────────────┘       │
│                                      ▼                       │
│                               ┌──────────┐                  │
│                               │  Deploy  │                  │
│                               │  to ECS  │                  │
│                               └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
┌─────────────────┐          ┌─────────────────┐
│  ECR Repository │          │  ECS Service    │
│  (Immutable)    │          │  (Blue/Green)   │
└─────────────────┘          └─────────────────┘
```

---

## Pipeline Stages

### Stage 1: Source Control
- **Provider**: AWS CodeCommit (or GitHub/GitLab via webhook)
- **Trigger**: EventBridge rule on branch push
- **Branch**: Configurable (default: main)
- **Features**:
  - Automatic trigger on code commit
  - No polling (event-driven)
  - Full commit history tracking

### Stage 2: Build
- **Tool**: AWS CodeBuild
- **Container**: `aws/codebuild/standard:7.0`
- **Steps**:
  1. ECR login
  2. Docker build
  3. Tag with commit hash (immutable)
  4. Tag with `latest`
  5. Push both tags to ECR
  6. Generate `imagedefinitions.json`
- **Build Time**: ~5-10 minutes
- **Artifacts**: Docker image + deployment manifest

### Stage 3: Security Scan
- **Tools**: 
  - **Trivy**: Open-source vulnerability scanner
  - **ECR Native Scanning**: AWS-managed scanning
- **Checks**:
  - HIGH and CRITICAL vulnerabilities
  - OS package vulnerabilities
  - Application dependencies
  - Known CVEs
- **Outputs**:
  - JSON report uploaded to S3
  - CodeBuild test report
  - SNS notification if critical issues found
- **Action**: 
  - Continues on warnings (dev/staging)
  - Fails on CRITICAL vulnerabilities (production - configurable)

### Stage 4: Manual Approval (Production Only)
- **When**: Only for `environment = prod`
- **Notification**: SNS email to approvers
- **Approval Required**: Before deployment to production
- **Timeout**: 7 days (configurable)

### Stage 5: Deploy to ECS
- **Provider**: AWS ECS (Blue/Green deployment)
- **Strategy**: Rolling update or Blue/Green
- **Steps**:
  1. Register new task definition
  2. Update ECS service
  3. Health check validation
  4. Automatic rollback on failure
- **Deployment Timeout**: 15 minutes
- **Zero Downtime**: Yes

---

## Key Features

### 1. **Immutable ECR Tags**
- Image tags cannot be overwritten
- Each build gets unique tag (commit hash)
- `latest` tag always points to most recent build
- Enables reliable rollbacks

### 2. **Automated Security Scanning**
- **ECR Scan**: Automatic on push
- **Trivy**: Deep vulnerability analysis
- **Severity Levels**: HIGH, CRITICAL
- **Reports**: Stored in S3 for compliance

### 3. **Infrastructure as Code**
- Fully Terraform-managed
- Version-controlled pipeline configuration
- Reproducible across environments
- Easy to audit and modify

### 4. **Audit Logging**
- CloudWatch Logs for all build stages
- Pipeline execution history
- CloudTrail integration
- Retained for 365 days (audit logs)

### 5. **Notifications**
- SNS topic for pipeline events
- Email notifications on:
  - Build failures
  - Security issues
  - Approval requests
  - Deployment success/failure

### 6. **KMS Encryption**
- Artifacts encrypted at rest
- ECR images encrypted
- Secrets encrypted in transit
- Compliant with security standards

---

## Usage

### Deploy the CI/CD Module

```hcl
module "ci_cd" {
  source = "./modules/ci_cd"

  environment         = "prod"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  kms_key_arn         = module.kms.key_arn
  ecs_cluster_name    = module.ecs.cluster_name
  ecs_service_name    = module.ecs.service_name
  notification_email  = "devops@foretale.com"
  branch_name         = "main"
}
```

### Push Code to Trigger Pipeline

```bash
# Clone the CodeCommit repository
git clone <codecommit-clone-url>

# Make changes
echo "FROM nginx:alpine" > Dockerfile
git add Dockerfile
git commit -m "Update Dockerfile"

# Push to trigger pipeline
git push origin main
```

### Monitor Pipeline Execution

```bash
# Check pipeline status
aws codepipeline get-pipeline-state --name foretale-pipeline-prod

# View build logs
aws logs tail /aws/codebuild/foretale-build-prod --follow

# Check security scan results
aws s3 cp s3://foretale-codepipeline-artifacts-prod-<account-id>/security-scans/trivy-report-<commit-hash>.json - | jq .
```

---

## Security Best Practices Implemented

### ✅ **Immutable Infrastructure**
- Tags cannot be modified once pushed
- Each deployment is versioned
- Easy rollback to previous versions

### ✅ **Least Privilege IAM**
- Separate roles for CodePipeline, CodeBuild, EventBridge
- Minimal permissions required
- No wildcard permissions except where necessary

### ✅ **Secrets Management**
- No secrets in buildspec files
- Secrets Manager integration
- KMS encryption for all sensitive data

### ✅ **Network Isolation**
- CodeBuild runs in private subnets
- No internet access without NAT Gateway
- Security groups restrict traffic

### ✅ **Compliance & Audit**
- CloudWatch Logs retained for 365 days
- CloudTrail integration
- All actions logged and traceable

### ✅ **Vulnerability Management**
- Automated scanning on every build
- HIGH and CRITICAL severity alerts
- Reports stored for compliance

---

## Cost Optimization

### Build Costs
- **CodeBuild**: ~$0.005/min (MEDIUM instance)
- **Typical Build**: 5-10 minutes = $0.03-$0.05
- **Monthly (10 builds/day)**: ~$15-$30

### Storage Costs
- **ECR**: First 10GB free, then $0.10/GB
- **S3 Artifacts**: ~$0.023/GB
- **CloudWatch Logs**: $0.50/GB ingested

### Pipeline Execution
- **CodePipeline**: $1/active pipeline/month
- **Free Tier**: First 1 pipeline free

**Total Monthly Cost (Dev)**: ~$20-$50
**Total Monthly Cost (Prod)**: ~$50-$100

---

## Troubleshooting

### Build Fails at Docker Build Stage
```bash
# Check CodeBuild logs
aws logs tail /aws/codebuild/foretale-build-prod --follow

# Common issues:
# - Missing Dockerfile
# - Docker build context errors
# - Insufficient memory (increase compute type)
```

### Security Scan Fails
```bash
# View scan results
aws s3 cp s3://foretale-codepipeline-artifacts-prod-<account-id>/security-scans/trivy-report-latest.json - | jq .

# To temporarily bypass CRITICAL vulnerability check:
# Edit buildspec_scan.yml and comment out "exit 1" line
```

### Deployment Fails
```bash
# Check ECS service events
aws ecs describe-services --cluster <cluster-name> --services <service-name> --query 'services[0].events[0:5]'

# Common issues:
# - Health check failures
# - Insufficient capacity
# - Invalid task definition
```

### Pipeline Stuck at Approval Stage
```bash
# Approve manually
aws codepipeline put-approval-result \
  --pipeline-name foretale-pipeline-prod \
  --stage-name ManualApproval \
  --action-name ApprovalAction \
  --result status=Approved,summary="Approved by DevOps" \
  --token <token-from-sns-email>
```

---

## Outputs

| Output | Description |
|--------|-------------|
| `ecr_repository_url` | ECR repository URL for Docker push |
| `codecommit_repository_url` | CodeCommit clone URL (HTTPS) |
| `codepipeline_name` | Pipeline name |
| `codebuild_build_project_name` | Build project name |
| `codebuild_scan_project_name` | Security scan project name |
| `pipeline_notification_topic_arn` | SNS topic for notifications |

---

## Integration with GitHub Actions (Alternative)

If using GitHub instead of CodeCommit, create `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy to ECR/ECS

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-2

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: foretale-app-prod
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ steps.login-ecr.outputs.registry }}/foretale-app-prod:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Deploy to Amazon ECS
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: task-definition.json
          service: foretale-service-prod
          cluster: foretale-cluster-prod
          wait-for-service-stability: true
```

---

## Maintenance

### Regular Tasks
- **Weekly**: Review security scan reports
- **Monthly**: Update CodeBuild base image
- **Quarterly**: Review IAM permissions
- **Annually**: Audit CloudWatch Logs retention

### Updates
To update the pipeline configuration:
1. Modify Terraform code
2. Run `terraform plan` to review changes
3. Run `terraform apply` to update infrastructure
4. Test with a non-production deployment

---

## License
This CI/CD module is part of the ForeTale infrastructure and follows the same licensing as the main project.
