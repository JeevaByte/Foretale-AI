# KAN-9: Auto Scaling & Load Balancer Deployment - Final Reference

## Executive Summary

**Project**: ForeTale AWS Infrastructure Deployment - Phase 3 (KAN-9)  
**Objective**: Deploy Auto Scaling and Load Balancer infrastructure  
**Status**: Configuration complete, ready for infrastructure creation  
**Estimated Completion Time**: 15-20 minutes (Terraform apply)

---

## Phase 3 - KAN-9 Deployment Scope

### Components Ready for Deployment

#### 1. Application Load Balancer (ALB)
- **Status**: ✅ Already created in AWS
- **Name**: `foretale-dev-alb`
- **DNS**: `foretale-dev-alb-1306722095.us-east-2.elb.amazonaws.com`
- **ARN**: `arn:aws:elasticloadbalancing:us-east-2:442426872653:loadbalancer/app/foretale-dev-alb/96eba076c4b2bd62`

**Target Groups**:
- EKS Workloads: `foretale-dev-eks-tg` (ip-based routing)
- Lambda APIs: `foretale-dev-lambda-tg` (lambda-based routing)

**Routing Rules** (Ready for creation):
- `/api/*` → Lambda target group
- `/health/*` → EKS target group
- Default → EKS target group

#### 2. Lambda Functions (6 total)
Ready for creation with the following configuration:

| Function | Memory | Timeout | Purpose |
|----------|--------|---------|---------|
| insert_record | 512 MB | 60s | Insert records to RDS |
| update_record | 512 MB | 60s | Update records in RDS |
| delete_record | 512 MB | 60s | Delete records from RDS |
| read_record | 512 MB | 60s | Read records from RDS |
| read_json_record | 512 MB | 60s | Read and return JSON from RDS |
| ecs_invoker | 256 MB | 60s | Invoke ECS tasks |

**Configuration**:
- Runtime: Python 3.12
- VPC: foretale-dev VPC
- Security Groups: Lambda-specific security group
- Subnets: Private subnets (3 AZs)
- IAM Role: `foretale-dev-lambda-execution-role`
- Environment Variables: RDS endpoint, Secrets Manager credentials, AWS region

#### 3. Auto Scaling Group (ASG)
Ready for creation with the following configuration:

**ASG Name**: `foretale-dev-ai-servers-asg`

**Capacity**:
- Minimum: 1 instance
- Desired: 2 instances
- Maximum: 10 instances

**Instance Configuration**:
- Instance Type: `t3.medium`
- AMI: Amazon Linux 2 (Latest)
- Root Volume: 30 GB gp3 (encrypted)
- IOPS: 3000
- Throughput: 125 MB/s
- IAM Instance Profile: `foretale-dev-ai-server-profile`

**Health Checks**:
- Type: ELB
- Grace Period: 300 seconds
- Unhealthy Action: Terminate and replace

**Placement**:
- VPC: foretale-dev
- Subnets: Private subnets (3 AZs)
- Target Groups: EKS workloads

**Termination Policies**:
- Default + Oldest Instance
- Detach Load Balancer behavior

#### 4. Scaling Policies
Ready for creation with the following configuration:

**CPU-Based Scaling**:
- Type: Target Tracking
- Target Metric: Average CPU Utilization
- Target Value: 70%
- Scale-up Cooldown: 300 seconds
- Scale-down Cooldown: 300 seconds

**ALB Request Count Scaling**:
- Type: Target Tracking
- Target Metric: ALB Request Count Per Target
- Target Value: 1000 requests/target
- Scale-up Cooldown: 60 seconds
- Scale-down Cooldown: 300 seconds

**Simple Scaling Policies**:
- Scale-up: Increase by 1 instance (cooldown: 300s)
- Scale-down: Decrease by 1 instance (cooldown: 300s)

#### 5. CloudWatch Monitoring
Ready for creation with the following alarms:

**ALB Monitoring**:
- High HTTP 5XX Errors: >= 10 errors (threshold)
- Response Time Alert: >= 1 second (threshold)
- Unhealthy Host Count: >= 1 (threshold)

**ASG Monitoring**:
- High CPU Alert: >= 80% CPU (threshold)
- Low CPU Alert: <= 20% CPU (threshold)
- Scale-up triggered at 70% CPU (auto-scaling)
- Scale-down triggered at < 30% CPU (auto-scaling)

---

## Terraform Configuration Files

### Main Configuration Files

1. **modules/alb/main.tf**
   - Defines: ALB, target groups, HTTP listener, listener rules
   - Status: ✅ Configured and validated
   - Changes: Lambda target group fixed (removed port/protocol attributes)

2. **modules/alb/variables.tf**
   - Defines: Input variables for ALB module
   - Status: ✅ Complete

3. **modules/autoscaling/main.tf**
   - Defines: Launch template, ASG, scaling policies, CloudWatch alarms
   - Status: ✅ Configured and validated
   - Size: Comprehensive with all monitoring and scaling rules

4. **modules/lambda/main.tf**
   - Defines: 6 Lambda functions with IAM, VPC, environment configuration
   - Status: ✅ Configured, uses placeholder ZIP file
   - Note: Uses `lambda_placeholder.zip` (279 bytes) for initialization

5. **modules/lambda/variables.tf**
   - Defines: Input variables for Lambda module
   - Status: ✅ Complete

6. **main.tf**
   - Root module configuration calling all sub-modules
   - Status: ✅ Complete

7. **variables.tf**
   - Global variables and locals
   - Status: ✅ Complete

8. **terraform.tfvars**
   - Environment-specific values
   - Status: ✅ Complete

### Plan Files

- **tfplan3** (Current): 58 to add, 3 to change, 0 to destroy (LATEST - READY)
- **phase3_kan9.tfplan**: Previous plan version
- **phase3_final.tfplan**: Phase 3 final plan

---

## Terraform State Management

### Current State File
- **Location**: `terraform/terraform.tfstate`
- **Backup**: `terraform/terraform.tfstate.backup`
- **Resources**: 100+ resources already managed
- **Recent Changes**:
  - Imported: `/aws/eks/foretale-dev-eks-cluster/cluster` (CloudWatch log group)
  - Untainted: `module.alb.aws_lb.main` (ALB resource)

### Resources Already in State
- VPC and Subnets (9 total)
- RDS PostgreSQL database
- EKS Cluster and Node Groups
- DynamoDB Tables (5)
- S3 Buckets (4)
- Cognito User Pool
- IAM Roles and Policies
- Security Groups (5+)
- CloudWatch Log Groups

### Resources Ready to Create (58+)
See "Components Ready for Deployment" section above.

---

## Deployment Instructions

### Prerequisites
1. ✅ AWS credentials configured
2. ✅ Terraform installed and in PATH
3. ✅ Working directory: `terraform/`
4. ✅ All Terraform configurations validated
5. ✅ Plan file ready: `tfplan3`

### Step-by-Step Deployment

```bash
# Navigate to terraform directory
cd terraform

# Option 1: Using existing plan file
terraform apply tfplan3

# Option 2: Fresh plan then apply
terraform plan -out=tfplan_new
terraform apply tfplan_new

# Option 3: Direct apply with auto-approve (use with caution)
terraform apply -auto-approve
```

### Monitoring Deployment Progress

```bash
# Watch resource creation
terraform show -json | jq '.values.root_module.resources[] | {type: .type, name: .name, mode: .mode}'

# Count resources in state
terraform state list | wc -l

# Check specific resources
terraform state list | grep -E "lambda|autoscaling|alb"

# View all outputs
terraform output
```

### Verification Checklist

After `terraform apply` completes:

- [ ] **Lambda Functions**: 6 functions exist in AWS Console
  - Verify via: AWS Console → Lambda → Functions
  - Check environment variables are set correctly
  - Verify IAM role has RDS and ECS permissions

- [ ] **Auto Scaling Group**: Active and launching instances
  - Verify via: AWS Console → EC2 → Auto Scaling Groups
  - Check desired capacity = 2, current = 2
  - Verify launch template version is correct
  - Check instances are in healthy state

- [ ] **Launch Template**: Created with correct specifications
  - Verify via: AWS Console → EC2 → Launch Templates
  - Check instance type = t3.medium
  - Verify IAM instance profile is attached
  - Check security groups are correct

- [ ] **ALB Listener**: HTTP listener on port 80
  - Verify via: AWS Console → EC2 → Load Balancers
  - Check default target group (EKS)
  - Verify listener rules for `/api/*` and `/health/*`

- [ ] **Health Checks**: Targets are healthy
  - Verify via: ALB → Target Groups → Targets
  - All instances showing "healthy"
  - Response code 200 from `/health` endpoint

- [ ] **CloudWatch Alarms**: All alarms created and active
  - Verify via: AWS Console → CloudWatch → Alarms
  - Check High CPU alarm status
  - Verify Low CPU alarm exists
  - Check ALB error rate alarms

---

## Troubleshooting Guide

### Issue: Terraform Plan Shows Too Many Changes

**Symptom**: Plan shows 100+ changes instead of 58

**Solution**:
```bash
# Refresh state to sync with AWS
terraform refresh

# Then plan again
terraform plan -out=tfplan_new
```

### Issue: AWS Credentials Error

**Symptom**: `Error: error configuring AWS provider`

**Solution**:
```bash
# Check credentials
aws sts get-caller-identity

# If error, configure AWS CLI
aws configure set aws_access_key_id YOUR_KEY
aws configure set aws_secret_access_key YOUR_SECRET
aws configure set region us-east-2
```

### Issue: Lambda Functions Fail to Create

**Symptom**: `Error: error creating Lambda Function`

**Causes & Solutions**:
1. IAM role missing → Verify `foretale-dev-lambda-execution-role` exists
2. ZIP file missing → Check `modules/lambda/lambda_placeholder.zip` exists
3. VPC subnets invalid → Verify private subnets exist in foretale-dev VPC
4. Security group invalid → Verify security group exists and has outbound rules

### Issue: ASG Fails to Launch Instances

**Symptom**: `Error: Auto Scaling Group creation failed` or instances not launching

**Causes & Solutions**:
1. Launch template invalid → Check instance type availability in us-east-2
2. IAM instance profile missing → Verify `foretale-dev-ai-server-profile` exists
3. Subnets have no available IPs → Check subnet CIDR blocks
4. Security groups blocking traffic → Verify ALB can reach instances on health check port

### Issue: CloudWatch Alarms Not Created

**Symptom**: `Error: creating CloudWatch Metric Alarm`

**Solution**:
1. Verify IAM permissions for CloudWatch
2. Check alarm names don't exceed 256 characters
3. Verify metric dimensions are correct

### Issue: Health Checks Failing

**Symptom**: Instances marked as unhealthy in target group

**Solution**:
1. SSH into instance and check if application is running
2. Verify security group rules allow inbound from ALB security group on port (health check port)
3. Check CloudWatch logs from instance for errors
4. Verify health check path exists on application

---

## Post-Deployment Steps

### Immediate (Next 1 hour)

1. **Verify Infrastructure**
   - Check ALB receives traffic
   - Verify EC2 instances are healthy
   - Test API endpoints through ALB

2. **Monitor Scaling**
   - Watch auto-scaling group for 15 minutes
   - Verify CloudWatch metrics are recording
   - Check for any alarm triggers

3. **Deploy Application Code**
   - Replace `lambda_placeholder.zip` with actual Lambda code
   - Deploy application to EC2 instances
   - Configure Docker containers

### Short-term (Next 24 hours)

1. **Load Testing**
   - Test auto-scaling by generating load
   - Verify scale-up triggers at 70% CPU
   - Verify scale-down triggers below 30% CPU

2. **Monitoring Setup**
   - Configure CloudWatch Dashboard
   - Set up SNS notifications for alarms
   - Configure log aggregation

3. **Security Hardening**
   - Review and restrict security group rules
   - Enable VPC Flow Logs
   - Configure WAF rules on ALB (optional)

### Medium-term (Next 1 week)

1. **Phase 4 Deployment**
   - Deploy AI/ML services (SageMaker, Bedrock)
   - Configure model inference endpoints
   - Set up inference request routing

2. **Performance Optimization**
   - Analyze CloudWatch metrics
   - Optimize Lambda function execution
   - Fine-tune auto-scaling policies

3. **Cost Optimization**
   - Review AWS billing
   - Optimize instance types and counts
   - Consider reserved capacity for baseline load

---

## Resource Costs Estimate

### Monthly Cost Estimate (us-east-2)

| Service | Usage | Cost/Month |
|---------|-------|-----------|
| ALB | 24/7 operation | $18-25 |
| EC2 (t3.medium) | 2-10 instances avg | $30-150 |
| Lambda | 1M invocations/month | $2-5 |
| RDS PostgreSQL | Single AZ, 100GB | $50-100 |
| DynamoDB | On-demand | $10-20 |
| EKS | Cluster fee | $73 |
| Data Transfer | Estimated 100GB | $10-20 |
| CloudWatch | Logs + alarms | $5-10 |
| **TOTAL** | | **$200-400/month** |

---

## Key AWS Metrics to Monitor

### ALB Metrics
- Request Count
- Target Response Time
- HTTP 4xx Errors
- HTTP 5xx Errors
- Active Connection Count
- New Connection Count
- Processed Bytes

### EC2/ASG Metrics
- CPU Utilization
- Network In/Out
- Disk Read/Write
- Instance Health
- Group Desired Capacity
- Group In Service
- Group Pending
- Group Terminating

### Lambda Metrics
- Invocation Count
- Duration
- Error Count
- Concurrent Executions
- Throttles

### RDS Metrics
- Database Connections
- CPU Utilization
- Disk Space Used
- Network Receive Throughput
- Network Transmit Throughput
- Read Latency
- Write Latency

---

## Important Notes

1. **Lambda Placeholder Code**: Currently using a 279-byte placeholder ZIP file. Replace with actual application code before production use.

2. **EC2 Key Pair**: Ensure an EC2 key pair is configured for SSH access to auto-scaled instances.

3. **Security Groups**: Verify all security group rules allow necessary traffic:
   - ALB → EC2: Allow on application port
   - EC2 → RDS: Allow on port 5432
   - ALB → Lambda: Direct integration (no SG needed)

4. **IAM Permissions**: Verify Lambda execution role has:
   - RDS read/write permissions
   - Secrets Manager read permissions
   - ECS invoke permissions
   - CloudWatch logs write permissions
   - VPC elastic network interface permissions

5. **Network Configuration**: Ensure:
   - Private subnets have NAT Gateway for outbound internet access
   - VPC endpoints configured for AWS services
   - Route tables properly configured

6. **Cost Control**:
   - Set up CloudWatch alarms for cost anomalies
   - Configure Auto Scaling Group max size appropriately
   - Monitor data transfer costs

---

## Quick Reference Commands

```bash
# Apply infrastructure
cd terraform && terraform apply tfplan3

# Show plan details
terraform show tfplan3

# List all resources
terraform state list

# List specific resource type
terraform state list | grep lambda
terraform state list | grep autoscaling

# Check resource details
terraform state show module.autoscaling.aws_autoscaling_group.ai_servers

# Destroy infrastructure (use with caution)
terraform destroy -auto-approve

# Validate configuration
terraform validate

# Format configuration
terraform fmt -recursive

# Lock/Unlock state
terraform force-unlock LOCK_ID

# Refresh state
terraform refresh
```

---

## Support & Escalation

For issues during deployment:

1. **Check Terraform Logs**: Review terraform output carefully
2. **Check AWS Console**: Verify resources are created as expected
3. **Check CloudWatch Logs**: Look for application errors
4. **Check Security Groups**: Ensure traffic can flow correctly
5. **Contact AWS Support**: For AWS-specific issues (if needed)

---

**Document Version**: 1.0  
**Last Updated**: Current session  
**Status**: Ready for Deployment  
**Next Step**: Execute `terraform apply tfplan3`
