# ✅ ForeTale Infrastructure Deployment Checklist

## Phase 1: Core Infrastructure and Networking

### Pre-Deployment Checklist

- [ ] **AWS Account Ready**
  - [ ] AWS account created
  - [ ] IAM user created with appropriate permissions
  - [ ] Access Key ID and Secret Access Key generated

- [ ] **Tools Installed**
  - [ ] Terraform (>= 1.0) installed
  - [ ] AWS CLI installed
  - [ ] Git installed (optional)

- [ ] **AWS CLI Configured**
  ```bash
  aws configure
  # Enter Access Key ID
  # Enter Secret Access Key
  # Region: us-east-1
  # Output: json
  ```
  - [ ] Verify: `aws sts get-caller-identity`

- [ ] **Review Configuration**
  - [ ] Review `terraform.tfvars`
  - [ ] Confirm region: us-east-1
  - [ ] Confirm environment: dev
  - [ ] Confirm VPC CIDR: 10.0.0.0/16

### Deployment Steps

- [ ] **Navigate to terraform directory**
  ```bash
  cd terraform
  ```

- [ ] **Initialize Terraform**
  ```bash
  terraform init
  ```

- [ ] **Validate Configuration**
  ```bash
  terraform validate
  ```

- [ ] **Review Plan**
  ```bash
  terraform plan
  ```
  - [ ] Verify: Creating VPC
  - [ ] Verify: Creating 9 subnets
  - [ ] Verify: Creating Internet Gateway
  - [ ] Verify: Creating NAT Gateway
  - [ ] Verify: Creating 6 Security Groups
  - [ ] Verify: Creating 7 IAM Roles

- [ ] **Apply Configuration**
  ```bash
  terraform apply
  ```
  - [ ] Review changes
  - [ ] Type `yes` to confirm
  - [ ] Wait for completion (5-10 minutes)

### Post-Deployment Verification

- [ ] **Check Terraform Outputs**
  ```bash
  terraform output
  ```
  - [ ] vpc_id present
  - [ ] subnet IDs present
  - [ ] security group IDs present
  - [ ] IAM role ARNs present

- [ ] **Verify in AWS Console**
  - [ ] VPC created (VPC Dashboard)
  - [ ] 9 Subnets created (3 public, 3 private, 3 database)
  - [ ] Internet Gateway attached
  - [ ] NAT Gateway(s) running
  - [ ] Route tables configured
  - [ ] 6 Security Groups created
  - [ ] 7 IAM Roles created

- [ ] **Run Validation Commands**
  ```bash
  # Check VPC
  aws ec2 describe-vpcs --filters "Name=tag:Project,Values=foretale"
  
  # Check subnets
  aws ec2 describe-subnets --filters "Name=tag:Project,Values=foretale" --query 'Subnets[*].[Tags[?Key==`Name`].Value|[0]]' --output table
  
  # Check security groups
  aws ec2 describe-security-groups --filters "Name=tag:Project,Values=foretale" --query 'SecurityGroups[*].GroupName'
  
  # Check IAM roles
  aws iam list-roles --query 'Roles[?contains(RoleName, `foretale`)].RoleName'
  ```

- [ ] **Save Outputs**
  ```bash
  terraform output -json > outputs.json
  ```

### Cost Monitoring

- [ ] **Review Cost Estimate**
  - Expected: ~$32/month (dev with single NAT Gateway)
  - [ ] Set up AWS Budget alert
  - [ ] Enable Cost Explorer

- [ ] **Monitor Initial Costs**
  ```bash
  aws ce get-cost-and-usage \
    --time-period Start=2026-01-20,End=2026-01-21 \
    --granularity DAILY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE
  ```

### Security Verification

- [ ] **Verify IAM Roles**
  - [ ] All roles follow naming: `foretale-dev-<service>-role`
  - [ ] No overly permissive policies
  - [ ] Trust relationships correct

- [ ] **Verify Security Groups**
  - [ ] Only necessary ports open
  - [ ] Source restrictions in place
  - [ ] No 0.0.0.0/0 for sensitive ports (except ALB 80/443)

- [ ] **Enable CloudTrail** (Recommended)
  - [ ] Enable CloudTrail for API logging
  - [ ] Review trail configuration

### Documentation

- [ ] **Document Infrastructure**
  - [ ] Update ARCHITECTURE.md if needed
  - [ ] Note VPC ID and subnet IDs
  - [ ] Note security group IDs
  - [ ] Note IAM role ARNs

- [ ] **Version Control**
  - [ ] Commit Terraform code to Git
  - [ ] DO NOT commit terraform.tfvars (contains sensitive data)
  - [ ] DO NOT commit terraform.tfstate (contains sensitive data)

### Prepare for Phase 2

- [ ] **Review Phase 2 Requirements**
  - [ ] RDS PostgreSQL cluster
  - [ ] S3 buckets
  - [ ] ECR repositories
  - [ ] Secrets Manager

- [ ] **Note Required Information for Phase 2**
  - VPC ID: ________________
  - Private Subnet IDs: ________________
  - Database Subnet IDs: ________________
  - RDS Security Group ID: ________________
  - ECS Security Group ID: ________________
  - Lambda Security Group ID: ________________

## Troubleshooting Checklist

### If Deployment Fails

- [ ] Check AWS credentials
  ```bash
  aws sts get-caller-identity
  ```

- [ ] Check Terraform version
  ```bash
  terraform --version
  ```

- [ ] Review error messages in terminal

- [ ] Check AWS service quotas
  - [ ] VPC limit
  - [ ] Elastic IP limit
  - [ ] NAT Gateway limit

- [ ] Verify region configuration
  ```bash
  aws configure get region
  ```

- [ ] Clean up and retry
  ```bash
  terraform destroy
  terraform apply
  ```

## Rollback Plan

### If Need to Rollback

- [ ] **Destroy Infrastructure**
  ```bash
  terraform destroy
  ```

- [ ] **Verify Deletion**
  ```bash
  aws ec2 describe-vpcs --filters "Name=tag:Project,Values=foretale"
  ```

- [ ] **Clean Up State**
  ```bash
  rm -rf .terraform
  rm terraform.tfstate*
  ```

## Success Criteria

### Phase 1 Complete When ALL Are True:

✅ VPC created with CIDR 10.0.0.0/16  
✅ 3 Public subnets created  
✅ 3 Private subnets created  
✅ 3 Database subnets created  
✅ Internet Gateway attached  
✅ NAT Gateway(s) operational  
✅ Route tables configured correctly  
✅ 6 Security groups created  
✅ 7 IAM roles created  
✅ All terraform outputs available  
✅ No errors in deployment  
✅ Cost monitoring set up  
✅ Documentation updated  

## Next Steps After Phase 1

1. ✅ Complete this checklist
2. ⏭️ Review Phase 2 requirements
3. ⏭️ Gather database requirements (instance size, storage, etc.)
4. ⏭️ Plan S3 bucket structure
5. ⏭️ Prepare container images for ECR
6. ⏭️ Schedule Phase 2 deployment

---

**Deployment Date**: _______________  
**Deployed By**: _______________  
**Environment**: dev  
**Region**: us-east-1  
**Phase**: 1 of 6  
**Status**: [ ] Not Started [ ] In Progress [ ] Complete  

**Notes**:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
