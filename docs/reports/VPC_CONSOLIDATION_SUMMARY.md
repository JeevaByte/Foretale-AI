# VPC Consolidation and Naming Migration - Summary

## Status: PARTIALLY COMPLETE

### Completed Tasks ✓

#### 1. **Dev VPC Resource Naming Migration** ✓
All development VPC resources have been successfully renamed from `foretale-dev-*` pattern to `foretale-app-*` pattern:

**VPC & Networking:**
- VPC: `foretale-dev-vpc` → `foretale-app-vpc` (vpc-0bb9267ea1818564c)
- Internet Gateway: `foretale-dev-igw` → `foretale-app-igw` (igw-0c75c5a6c54c48ff1)
- NAT Gateway: `foretale-dev-nat-*` → `foretale-app-nat-us-east-2a` (nat-0ff858c1ca9880179)

**Subnets (9 total):**
- Public: `foretale-app-public-subnet-us-east-2a` (subnet-0f546c8342e908ba4)
- Public: `foretale-app-public-subnet-us-east-2b` (subnet-0c76e28ef555b9159)
- Public: `foretale-app-public-subnet-us-east-2c` (subnet-00ab6ebd3305afd8a)
- Private: `foretale-app-private-subnet-us-east-2a` (subnet-0eb005ebf922d4da1)
- Private: `foretale-app-private-subnet-us-east-2b` (subnet-0d2a35802b544fcb3)
- Private: `foretale-app-private-subnet-us-east-2c` (subnet-099c4a4b51deaf9e2)
- Database: `foretale-app-database-subnet-us-east-2a` (subnet-0474663ac69b7f53f)
- Database: `foretale-app-database-subnet-us-east-2b` (subnet-06005d32dc838779b)
- Database: `foretale-app-database-subnet-us-east-2c` (subnet-0b817d17b0d6ca506)

**Route Tables (4 total):**
- Main: `foretale-app-main-rt` (rtb-09c400d3f13270378)
- Public: `foretale-app-public-rt` (rtb-0fd8971cdbddeaef5)
- Private: `foretale-app-private-rt` (rtb-02075b5df500a6100)
- Database: `foretale-app-database-rt` (rtb-0532dfd78d2deabe1)

**Security Groups (8 renamed):**
- `foretale-app-ecs-tasks-sg` (sg-0ad8dfac3083b58a4)
- `foretale-app-ai-server-sg` (sg-0a674638dfa739028)
- `foretale-app-eks-*` (sg-0001a80293d2ee38f, sg-0c7900dd26b3b6c07)
- `foretale-app-rds-sg` (sg-098c140212053013a)
- `foretale-app-lambda-sg` (sg-0b0f1552f2ce495d5)
- `foretale-app-vpc-endpoints-sg` (sg-0063315a3ab679758)
- `foretale-app-alb-sg` (sg-0e96af64d75de7a0b)
- Note: `foretale-rds-sg` (sg-02212827192fdba24) kept as-is (shared resource, not dev-specific)

**VPC Endpoints (3 renamed):**
- S3: `foretale-app-s3-endpoint` (vpce-04bf4ba07330c8a7e)
- DynamoDB: `foretale-app-dynamodb-endpoint` (vpce-0dd10c2c36cdaea13)
- Execute API: `foretale-app-execute-api-endpoint` (vpce-0181499bc4e02a982)

#### 2. **Infrastructure Cleanup** ✓
- Deleted duplicate prod VPC (vpc-0299d0b6f638f6619)
- Deleted prod VPC ALB (foretale-app-alb)
- Deleted prod VPC security groups (sg-04de4fb1b8c722ef6, sg-0752b506987d0f4bd)
- Deleted prod VPC IGW (igw-07e947f9b05a9e69b)
- Terminated prod VPC EC2 instances (i-01d10023ca03096ba, i-0b8355e329e6a455d)
- Updated all us-east-2 Lambda timeouts to 900 seconds (15 minutes)
- Synced Secrets Manager across regions (us-east-1, us-east-2, ap-south-1)

### Blocking Issue: Prod VPC Deletion ❌

**Problem:**
Two network interfaces (ENIs) remain orphaned in the prod VPC after instance termination:
- `eni-08cb7652b82476658` (Attachment: eni-attach-09b00a7cdcefe5293)
- `eni-0cb72828cd2cbacac` (Attachment: eni-attach-0a371e82618f1eabf)

**Status:** Both ENIs report as `in-use` despite being created by now-terminated instances.

**Root Cause:**
These are primary network interfaces (device index 0) that:
1. Cannot be detached (AWS blocks primary interface detachment)
2. Are marked `DeleteOnTermination: true` but did not auto-delete after instance termination
3. Block subnet deletion, which blocks VPC deletion

**Remaining Prod VPC Resources (Cannot Delete Yet):**
- VPC: `vpc-0aef39d92ca9cb3f9` (foretale-prod-vpc)
- Subnets: `subnet-09a654b71ee959728`, `subnet-0bede8b3d10d98d84`
- Route Tables: `rtb-0277bcd2f9cbc47c3`, `rtb-0ffcac40e22454674`
- Network ACL: `acl-0075778ee9e1ba9c0`

### Resolution Options

**Option 1: AWS Service Eventual Consistency (Recommended - Wait)**
- AWS ENI cleanup can take 24-48 hours after instance termination
- Retry VPC deletion after 24 hours
- No manual intervention required

**Option 2: AWS Support Request**
- Open AWS Support case requesting orphaned ENI cleanup
- Provide ENI IDs and instance termination timestamp
- AWS may manually release the ENIs

**Option 3: Terraform State Cleanup (Advanced)**
- Remove network interface resources from `terraform.tfstate`
- Use `terraform state rm` to unmanage orphaned resources
- Attempt `terraform destroy` with modified state
- Risk: Requires state file manipulation

### Next Steps

1. **Immediate (24+ hours):**
   - Wait for AWS ENI eventual consistency
   - Retry: `aws ec2 delete-vpc --region us-east-2 --vpc-id vpc-0aef39d92ca9cb3f9`

2. **If Still Blocked After 24 Hours:**
   - Contact AWS Support with orphaned ENI ticket
   - Reference ENI IDs and instance termination time

3. **Terraform Updates (Can proceed now):**
   - Update `terraform/main.tf` to use single VPC (foretale-app)
   - Update variable defaults to reflect new naming scheme
   - Remove prod VPC module references
   - Update `terraform/terraform.tfvars` to reference only dev VPC

4. **Documentation:**
   - Update architecture docs with single-VPC design
   - Update naming conventions documentation
   - Document the orphaned ENI incident for future reference

## Infrastructure State

### Active VPC (Development/Application)
- **VPC ID:** vpc-0bb9267ea1818564c
- **Name:** foretale-app-vpc
- **CIDR:** 10.0.0.0/16
- **AZs:** us-east-2a, us-east-2b, us-east-2c
- **Subnets:** 3 Public + 3 Private + 3 Database = 9 Total
- **Resources:** ALBs, ECS, EKS, RDS, Lambda, API Gateway

### Orphaned VPC (To Be Deleted)
- **VPC ID:** vpc-0aef39d92ca9cb3f9
- **Name:** foretale-prod-vpc
- **Status:** Empty except for orphaned ENIs
- **Blocking:** Cannot delete due to ENI dependencies

## Command Reference

### Check ENI Status
```bash
aws ec2 describe-network-interfaces --region us-east-2 --vpc-id vpc-0aef39d92ca9cb3f9
```

### Retry VPC Deletion
```bash
aws ec2 delete-vpc --region us-east-2 --vpc-id vpc-0aef39d92ca9cb3f9
```

### Force Delete Individual Subnets (After ENIs Released)
```bash
aws ec2 delete-subnet --region us-east-2 --subnet-id subnet-09a654b71ee959728
aws ec2 delete-subnet --region us-east-2 --subnet-id subnet-0bede8b3d10d98d84
```

---

**Last Updated:** 2026-02-02
**Status:** Development VPC naming complete, Prod VPC deletion blocked by orphaned ENIs
