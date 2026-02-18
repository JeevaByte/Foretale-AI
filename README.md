# ForeTale Application

A Flutter-based cross-platform application with comprehensive AWS infrastructure deployment across multiple regions.

## Overview

ForeTale is a modern Flutter application with a robust AWS backend infrastructure deployed across **multiple regions** (us-east-2 primary, us-east-1 secondary) for high availability and disaster recovery.

## Architecture

### Application Stack
- **Frontend**: Flutter (iOS, Android, Web, Desktop)
- **Backend**: AWS Lambda, API Gateway, DynamoDB
- **Authentication**: Amazon Cognito
- **Storage**: Amazon S3 (Vector embeddings, assets)
- **Real-time**: WebSocket API Gateway

### Infrastructure Stack

```
┌─────────────────────────────────────────┐
│    Multi-Region Deployment (Terraform)  │
├──────────────────┬──────────────────────┤
│   us-east-2      │      us-east-1       │
│   (Primary)      │      (Secondary)     │
├──────────────────┼──────────────────────┤
│ VPC              │ VPC                  │
│ ├─ Private Subs  │ ├─ Private Subs      │
│ ├─ ALB (Private) │ ├─ ALB (Private)     │
│ └─ ASG (1-10)    │ └─ ASG (1-10)        │
│    EC2 (t4g)     │    EC2 (t4g)         │
├──────────────────┼──────────────────────┤
│ Lambda Layer     │ Lambda Layer         │
│ API Gateway      │ API Gateway          │
│ DynamoDB         │ DynamoDB             │
│ Cognito          │ Cognito              │
│ S3               │ S3                   │
└──────────────────┴──────────────────────┘
```

### Key Features

- **Multi-Region Deployment**: Synchronized infrastructure in us-east-2 and us-east-1
- **Auto Scaling**: ASG configured for 1-10 instances, scales based on demand
- **Private Network**: All resources in private subnets (no public IPs)
- **Load Balancing**: Internal Application Load Balancer (ALB)
- **Security**: Restrictive security groups, IAM policies, encrypted EBS volumes
- **Infrastructure as Code**: Complete Terraform configuration for repeatability
- **Cognito Integration**: User authentication and authorization
- **Serverless Functions**: Lambda functions for business logic
- **Real-time Communication**: WebSocket API Gateway integration

## Project Structure

```
foretale_application-main/
├── infrastructure/               # Infrastructure as Code
│   ├── terraform/               # us-east-2 (Primary) Terraform configs
│   │   ├── main.tf              # Main resource definitions
│   │   ├── variables.tf         # Variable definitions
│   │   ├── outputs.tf           # Output definitions
│   │   ├── modules/             # Terraform modules
│   │   │   ├── vpc/             # VPC & networking
│   │   │   ├── autoscaling/     # ASG configuration
│   │   │   ├── security_groups/ # Security rules
│   │   │   ├── alb/             # Load balancer
│   │   │   ├── cognito/         # Cognito setup
│   │   │   ├── lambda/          # Lambda layers
│   │   │   ├── dynamodb/        # Database tables
│   │   │   └── ...
│   │   └── terraform.tfvars     # Region-specific variables
│   │
│   ├── terraform-us-east-1/     # us-east-1 (Secondary) Terraform configs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── modules/             # Same module structure
│   │   └── terraform.tfvars     # Region-specific overrides
│   │
│   ├── lambda/                  # Lambda function code
│   │   ├── embeddings/          # Embedding generation functions
│   │   ├── processing/          # Data processing functions
│   │   └── ...
│   │
│   └── kubernetes/              # Kubernetes configs (optional)
│
├── lib/                         # Flutter application code
│   ├── main.dart               # Application entry point
│   ├── config/                 # Configuration & constants
│   ├── core/                   # Core business logic
│   ├── models/                 # Data models
│   └── ui/                     # UI screens & widgets
│
├── native/                     # Native platform code
│   ├── android/                # Android native code
│   ├── ios/                    # iOS native code
│   ├── web/                    # Web platform
│   ├── windows/                # Windows platform
│   ├── macos/                  # macOS platform
│   └── linux/                  # Linux platform
│
├── docs/                       # Documentation
│   ├── deployment/             # Deployment guides
│   ├── terraform/              # Terraform documentation
│   ├── amplify/                # AWS Amplify docs
│   └── reports/                # Analysis & status reports
│
├── scripts/                    # Utility scripts
│   ├── deploy_lambda.ps1       # Lambda deployment scripts
│   ├── migrate_dynamodb_params.py  # Data migration
│   └── ...
│
├── assets/                     # Flutter assets
│   └── images/
│       ├── icons/
│       └── logo/
│
├── config/                     # Application configuration
├── pubspec.yaml               # Dart/Flutter dependencies
└── README.md                  # This file
```

## Prerequisites

### For Flutter Development
- Flutter SDK (latest stable)
- Dart SDK
- iOS deployment target: 12.0+
- Android minimum API: 21
- macOS minimum version: 10.11

### For Infrastructure Management
- Terraform 1.0+
- AWS CLI v2
- AWS credentials configured locally
- PowerShell 5.1+ (for deployment scripts)

### For AWS Access
- AWS account with access to us-east-2 and us-east-1 regions
- IAM permissions for: EC2, VPC, Lambda, DynamoDB, API Gateway, Cognito, S3, CloudWatch

## Setup & Deployment

### 1. Flutter Application Setup

```bash
# Install dependencies
flutter pub get

# Generate code (if using build_runner)
flutter pub run build_runner build

# Run on specific platform
flutter run -d chrome           # Web
flutter run -d macos            # macOS
flutter run -d your-device      # Physical device
```

### 2. Infrastructure Deployment (Terraform)

#### Primary Region (us-east-2)

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

#### Secondary Region (us-east-1)

```bash
cd infrastructure/terraform-us-east-1

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

### 3. Deploy Lambda Functions

```bash
# Use deployment script (PowerShell)
.\scripts\deploy_lambda.ps1

# Or manual deployment:
cd infrastructure/lambda
# Deploy each function following Lambda deployment guide in docs/
```

### 4. Configure Cognito & Amplify

```bash
# Setup Cognito
.\scripts\setup_amplify_cognito.ps1

# Setup Storage
.\scripts\setup_amplify_storage.ps1
```

## Configuration

### Environment Variables

Create `.env` file in project root:

```env
# AWS Configuration
AWS_REGION=us-east-2
AWS_SECONDARY_REGION=us-east-1

# Cognito
COGNITO_USER_POOL_ID=<your-user-pool-id>
COGNITO_CLIENT_ID=<your-client-id>
COGNITO_DOMAIN=<your-cognito-domain>

# API Gateway
API_ENDPOINT=<your-api-endpoint>
WEBSOCKET_ENDPOINT=<your-websocket-endpoint>

# DynamoDB
DYNAMODB_TABLE_PREFIX=foretale

# S3
S3_BUCKET_NAME=foretale-storage
```

### Terraform Variables

Configure region-specific variables in:
- `infrastructure/terraform/terraform.tfvars` (us-east-2)
- `infrastructure/terraform-us-east-1/terraform.tfvars` (us-east-1)

Key variables:
- `region` - AWS region
- `environment` - Environment name (dev/staging/prod)
- `app_name` - Application name
- `instance_type` - EC2 instance type
- `asg_desired_capacity` - Desired ASG size (default: 1)
- `asg_min_size` - Minimum ASG size
- `asg_max_size` - Maximum ASG size

## Deployment Status

### us-east-2 (Primary)
- ✅ VPC & Networking
- ✅ Auto Scaling Group (1 instance: t4g.medium ARM64)
- ✅ Application Load Balancer (Internal)
- ✅ Security Groups (Restrictive rules)
- ✅ Cognito User Pool
- ✅ DynamoDB Tables
- ✅ Lambda Functions & Layers
- ✅ API Gateway
- ✅ S3 Buckets

### us-east-1 (Secondary)
- ✅ VPC & Networking
- ✅ Auto Scaling Group (1 instance: t4g.medium ARM64)
- ✅ Application Load Balancer (Internal)
- ✅ Security Groups (Restrictive rules)
- ✅ Cognito User Pool (Synchronized)
- ✅ DynamoDB Tables (Synchronized)
- ✅ Lambda Functions & Layers
- ✅ API Gateway
- ✅ S3 Buckets

## Security

### Network Security
- **Private Subnets Only**: All EC2, RDS, Lambda in private subnets
- **No Public IPs**: Only ALB has network interface (internal only)
- **Security Groups**: Restrictive inbound rules
  - ALB: 443 from allowed CIDR blocks
  - EC2: 443, 8002 from ALB security group only
  - RDS: 5432 from EC2 security group only

### Data Security
- **Encryption at Rest**: EBS volumes encrypted with KMS
- **Encryption in Transit**: TLS 1.2+ for all communications
- **Database**: Encrypted DynamoDB with point-in-time recovery
- **Secrets**: AWS Secrets Manager for sensitive values

### Access Control
- **Cognito**: User authentication and authorization
- **IAM Roles**: Least privilege principle applied to all roles
- **Multi-Region**: Synchronized security policies across regions

## Documentation

Comprehensive documentation available in `docs/`:
- [Deployment Status](docs/DEPLOYMENT_STATUS.md) - Current infrastructure state
- [Terraform Configs](docs/terraform/) - Infrastructure documentation
- [API Testing Guide](docs/API_TESTING_GUIDE.md) - API endpoints and testing
- [Amplify Integration](docs/AMPLIFY_INTEGRATION_STATUS.md) - Amplify setup status
- [Lambda Documentation](docs/LAMBDA_ROLE_COMPARISON.md) - Lambda function details
- [Reports](docs/reports/) - Analysis and implementation reports

## Troubleshooting

### Terraform Issues

**State Lock**
```bash
terraform force-unlock <LOCK_ID>
```

**Replan/Reapply**
```bash
terraform refresh
terraform plan -out=tfplan
terraform apply tfplan
```

### Infrastructure Issues

Check CloudWatch logs:
```bash
# View EC2 system logs
aws ec2 describe-console-output --instance-id <instance-id> --region us-east-2

# View ASG activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name foretale-asg --region us-east-2
```

### Flutter Issues

- **Build errors**: Delete .dart_tool/ and pubspec.lock, then `flutter pub get`
- **Platform-specific issues**: Check native code in `native/` directories
- **State management**: Review core/ subdirectory for state management setup

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit pull request

### Code Standards
- Flutter: Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Terraform: Use `terraform fmt` for formatting
- Scripts: Use consistent PowerShell/Bash conventions

## Deployment Pipeline

```
Local Development
    ↓
Feature Branch Testing
    ↓
PR Review & Merge to main
    ↓
Terraform Validation (terraform plan)
    ↓
Automated Testing
    ↓
Terraform Apply (both regions)
    ↓
Lambda Deployment
    ↓
Smoke Testing
    ↓
Production Ready
```

## Monitoring & Maintenance

### CloudWatch Monitoring
- EC2 CPU usage, Memory, Network
- ECS Task performance
- Lambda execution metrics
- API Gateway requests/errors
- DynamoDB read/write capacity

### Scheduled Tasks
- Daily database backups (DynamoDB PITR enabled)
- Weekly security group audits
- Monthly infrastructure cost review
- Quarterly disaster recovery drills

## Support

For issues or questions:
1. Check existing documentation in `docs/`
2. Review deployment reports in `docs/reports/`
3. Check CloudWatch logs for errors
4. Contact infrastructure team

## License

Confidential - ForeTale Application

## Version History

- **2026-02-13**: Multi-region deployment completed (us-east-2 primary, us-east-1 secondary)
- **2026-02-10**: ASG optimization (reduced to 1 instance, scales to 10)
- **2026-02-08**: Security hardening (ports restricted, VPC-only)
- **2026-02-01**: Initial infrastructure deployment

---

**Last Updated**: February 13, 2026  
**Infrastructure Status**: ✅ Deployed (Both Regions)  
**Application Status**: Ready for GitHub Push
# Foretale-AI
