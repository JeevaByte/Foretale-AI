# ForeTale Infrastructure - Quick Start Guide

## 🚀 Deploy Phase 1 in 5 Minutes

### Step 1: Navigate to Terraform Directory
```bash
cd terraform
```

### Step 2: Configure AWS Credentials (if not already done)
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter region: us-east-1
# Enter output format: json
```

### Step 3: Create Your Variables File
```bash
# Windows
copy terraform.tfvars.example terraform.tfvars

# Linux/Mac
cp terraform.tfvars.example terraform.tfvars
```

### Step 4: Deploy Using Script

**Windows:**
```bash
deploy.bat
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**OR Manual Deployment:**
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

### Step 5: Verify Deployment
```bash
# View outputs
terraform output

# Check AWS resources
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=foretale"
```

## 📊 What Gets Created

### Networking
- ✅ 1 VPC (10.0.0.0/16)
- ✅ 9 Subnets (3 public, 3 private, 3 database)
- ✅ 1 Internet Gateway
- ✅ 1 NAT Gateway (dev) or 3 NAT Gateways (prod)
- ✅ Route Tables

### Security
- ✅ 6 Security Groups (ALB, ECS, RDS, Lambda, AI Server, VPC Endpoints)
- ✅ 7 IAM Roles (ECS, Lambda, API Gateway, Amplify, AI Server, RDS Monitoring)

### Cost
- **Development**: ~$32/month (single NAT Gateway)
- **Production**: ~$106/month (3 NAT Gateways)

## 🔧 Common Commands

```bash
# View all outputs
terraform output

# View specific output
terraform output vpc_id

# Destroy everything
terraform destroy

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show
```

## 🎯 Next Phase

After Phase 1 completes, you'll deploy:
- Phase 2: RDS, S3, ECR
- Phase 3: ECS Clusters
- Phase 4: API Gateway, Lambda
- Phase 5: Load Balancers
- Phase 6: Cognito, Amplify, AI Server

## ⚠️ Important Notes

1. **First Time Setup**: Review `terraform.tfvars` before deploying
2. **State File**: Keep `terraform.tfstate` secure (contains sensitive data)
3. **Costs**: NAT Gateway runs 24/7 (~$32/month)
4. **Cleanup**: Run `terraform destroy` to delete all resources

## 🆘 Troubleshooting

### Error: "No valid credential sources"
```bash
aws configure
```

### Error: "Insufficient permissions"
- Ensure your AWS user has AdministratorAccess or appropriate IAM permissions

### Error: "Region not set"
```bash
export AWS_DEFAULT_REGION=us-east-1
```

### Check AWS Resources
```bash
# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table

# List Subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# List Security Groups
aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `foretale`)].[GroupId,GroupName]' --output table

# List IAM Roles
aws iam list-roles --query 'Roles[?contains(RoleName, `foretale`)].[RoleName,Arn]' --output table
```

## 📞 Support

- Check [README.md](README.md) for detailed documentation
- Review AWS Console for resource verification
- Check Terraform logs for error details
