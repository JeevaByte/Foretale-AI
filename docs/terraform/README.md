# ForeTale Application - Terraform Infrastructure

This repository contains Terraform configurations for deploying the ForeTale application infrastructure on AWS.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Infrastructure Components](#infrastructure-components)
- [Getting Started](#getting-started)
- [Deployment Phases](#deployment-phases)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Cost Optimization](#cost-optimization)
- [Security Best Practices](#security-best-practices)

## 🏗️ Architecture Overview

The infrastructure is deployed in phases:

### Phase 1: Core Infrastructure and Networking (Current)
- VPC with public, private, and database subnets across 3 Availability Zones
- Internet Gateway and NAT Gateway
- Route tables for public and private subnets
- Security Groups for all services
- IAM roles and policies with least privilege access

### Future Phases
- **Phase 2**: RDS PostgreSQL, S3 buckets, ECR repositories
- **Phase 3**: ECS Fargate clusters and task definitions
- **Phase 4**: API Gateway, Lambda functions
- **Phase 5**: Application Load Balancer, CloudFront
- **Phase 6**: Cognito, Amplify Hosting, AI/WebSocket server

## 📦 Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```
3. **Terraform** installed (>= 1.0)
   ```bash
   terraform --version
   ```
4. **Git** for version control

## 🔧 Infrastructure Components

### Networking (Phase 1)
- **VPC**: `10.0.0.0/16`
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
- **Private Subnets**: `10.0.11.0/24`, `10.0.12.0/24`, `10.0.13.0/24`
- **Database Subnets**: `10.0.21.0/24`, `10.0.22.0/24`, `10.0.23.0/24`
- **NAT Gateway**: Single NAT Gateway (dev) or per-AZ (prod)

### Security Groups (Phase 1)
- **ALB Security Group**: Allows HTTP/HTTPS from Internet
- **ECS Security Group**: Allows traffic from ALB and within VPC
- **RDS Security Group**: Allows PostgreSQL (5432) from ECS and Lambda
- **Lambda Security Group**: Allows traffic within VPC
- **AI Server Security Group**: Allows WebSocket (8002) and SSH
- **VPC Endpoints Security Group**: Allows HTTPS from VPC

### IAM Roles (Phase 1)
All roles follow the naming convention: `foretale-<environment>-<service>-role`

- **ECS Task Execution Role**: Pull images, write logs
- **ECS Task Role**: Application-level permissions (S3, CloudWatch)
- **Lambda Execution Role**: Execute functions, access RDS, S3, invoke ECS
- **API Gateway CloudWatch Role**: Write API logs
- **Amplify Service Role**: Deploy and manage Amplify apps
- **AI Server Role**: Access Bedrock, S3, CloudWatch
- **RDS Monitoring Role**: Enhanced monitoring

## 🚀 Getting Started

### 1. Clone the Repository

```bash
cd foretale_application-main
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
aws_region   = "us-east-1"
project_name = "foretale"
environment  = "dev"

# Customize if needed
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# For production, set single_nat_gateway = false
single_nat_gateway = true
```

## 📝 Configuration

### Directory Structure

```
terraform/
├── main.tf                    # Root configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables
├── terraform.tfvars          # Your actual variables (gitignored)
└── modules/
    ├── vpc/                   # VPC and networking resources
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-groups/       # Security group definitions
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── iam/                   # IAM roles and policies
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Project name prefix | `foretale` |
| `environment` | Environment name | `dev` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `enable_nat_gateway` | Enable NAT Gateway | `true` |
| `single_nat_gateway` | Use single NAT (cost optimization) | `true` |

## 🚢 Deployment

### Phase 1: Deploy Core Infrastructure

1. **Review the plan**:
   ```bash
   terraform plan
   ```

2. **Apply the configuration**:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

3. **View outputs**:
   ```bash
   terraform output
   ```

### Verify Deployment

```bash
# List VPCs
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=foretale"

# List subnets
aws ec2 describe-subnets --filters "Name=tag:Project,Values=foretale"

# List security groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=foretale"

# List IAM roles
aws iam list-roles | grep foretale
```

## 📤 Outputs

After deployment, the following outputs are available:

### Network Outputs
- `vpc_id` - VPC ID
- `public_subnet_ids` - Public subnet IDs
- `private_subnet_ids` - Private subnet IDs
- `database_subnet_ids` - Database subnet IDs
- `nat_gateway_ids` - NAT Gateway IDs

### Security Group Outputs
- `alb_security_group_id`
- `ecs_security_group_id`
- `rds_security_group_id`
- `lambda_security_group_id`
- `ai_server_security_group_id`

### IAM Outputs
- `ecs_task_execution_role_arn`
- `ecs_task_role_arn`
- `lambda_execution_role_arn`
- `api_gateway_cloudwatch_role_arn`
- `amplify_service_role_arn`
- `ai_server_role_arn`

## 💰 Cost Optimization

### Development Environment
- Single NAT Gateway: ~$32/month
- VPC: Free
- Security Groups: Free
- IAM: Free

**Estimated Monthly Cost**: ~$32

### Production Environment
- NAT Gateway (3 AZs): ~$96/month
- VPC Flow Logs: ~$10/month (optional)

**Estimated Monthly Cost**: ~$106

### Cost Reduction Tips
1. Use single NAT Gateway for dev/test
2. Disable VPC Flow Logs if not needed
3. Delete unused Elastic IPs
4. Use VPC Endpoints to reduce NAT Gateway data transfer

## 🔐 Security Best Practices

### Implemented in Phase 1

1. **Network Segmentation**
   - Separate subnets for public, private, and database tiers
   - Database subnets have no Internet access

2. **Least Privilege IAM**
   - Specific permissions for each service
   - No wildcard (*) resources where possible
   - Conditional policies for ECS task execution

3. **Security Groups**
   - Principle of least privilege
   - Only required ports are open
   - Source-based restrictions

4. **Encryption**
   - VPC traffic is encrypted by default (AWS)
   - Prepare for encryption at rest (Phase 2)

### Additional Recommendations

1. **Enable VPC Flow Logs** (optional, costs extra)
   ```hcl
   enable_flow_logs = true
   ```

2. **Restrict SSH Access**
   Update `allowed_ssh_cidr_blocks` in variables to your IP:
   ```hcl
   allowed_ssh_cidr_blocks = ["YOUR_IP/32"]
   ```

3. **Enable MFA for AWS Account**

4. **Use AWS Systems Manager Session Manager** instead of SSH

5. **Regular Security Audits**
   ```bash
   aws iam get-credential-report
   ```

## 🔄 State Management

### Remote State (Recommended for Teams)

Uncomment the backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "foretale-terraform-state"
  key            = "infrastructure/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "foretale-terraform-locks"
}
```

Create the backend resources:

```bash
# Create S3 bucket
aws s3 mb s3://foretale-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket foretale-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name foretale-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Then initialize:

```bash
terraform init -migrate-state
```

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all infrastructure. Make sure you have backups!

## 📚 Next Steps

After Phase 1 is deployed:

1. **Phase 2**: Deploy RDS, S3, ECR
   - RDS PostgreSQL cluster
   - S3 buckets for application data
   - ECR repositories for container images

2. **Phase 3**: Deploy ECS clusters
   - cluster-uploads for CSV processing
   - cluster-execute for test execution

3. **Phase 4**: Deploy APIs and Lambda
   - API Gateway endpoints
   - Lambda functions for database operations
   - ECS task invocation functions

4. **Phase 5**: Deploy Load Balancing
   - Application Load Balancer
   - Target groups
   - CloudFront distribution

5. **Phase 6**: Deploy Application Services
   - Cognito User Pool
   - Amplify Hosting
   - AI/WebSocket server on EC2

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test with `terraform plan`
4. Submit pull request

## 📞 Support

For issues or questions:
- Review AWS documentation
- Check Terraform registry for module documentation
- Contact DevOps team

## 📄 License

Internal use only - ForeTale Application

---

**Version**: Phase 1  
**Last Updated**: January 2026  
**Maintained By**: DevOps Team
