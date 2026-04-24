# Quick Reference - ForeTale Networking Resources
**Updated:** February 3, 2026

---

## 🎯 ACTIVE INFRASTRUCTURE (foretale-app-vpc)

### VPC Details
| Property | Value |
|----------|-------|
| VPC ID | vpc-0bb9267ea1818564c |
| VPC Name | foretale-app-vpc |
| CIDR Block | 10.0.0.0/16 |
| Region | us-east-2 |
| Availability Zones | us-east-2a, us-east-2b, us-east-2c |
| Status | ✅ Active |

---

## 📊 SUBNET MAPPING

### Public Subnets (NAT/IGW Access)
```
foretale-app-public-subnet-us-east-2a (subnet-0f546c8342e908ba4) | 10.0.1.0/24
foretale-app-public-subnet-us-east-2b (subnet-0c76e28ef555b9159) | 10.0.2.0/24
foretale-app-public-subnet-us-east-2c (subnet-00ab6ebd3305afd8a) | 10.0.3.0/24
```

### Private Subnets (NAT Only Access)
```
foretale-app-private-subnet-us-east-2a (subnet-0eb005ebf922d4da1) | 10.0.11.0/24
foretale-app-private-subnet-us-east-2b (subnet-0d2a35802b544fcb3) | 10.0.12.0/24
foretale-app-private-subnet-us-east-2c (subnet-099c4a4b51deaf9e2) | 10.0.13.0/24
```

### Database Subnets (Internal Only)
```
foretale-app-database-subnet-us-east-2a (subnet-0474663ac69b7f53f) | 10.0.21.0/24
foretale-app-database-subnet-us-east-2b (subnet-06005d32dc838779b) | 10.0.22.0/24
foretale-app-database-subnet-us-east-2c (subnet-0b817d17b0d6ca506) | 10.0.23.0/24
```

---

## 🔗 NETWORK GATEWAYS

| Type | Name | ID | Status |
|------|------|--|----|
| Internet Gateway | foretale-app-igw | igw-0c75c5a6c54c48ff1 | ✅ Active |
| NAT Gateway | foretale-app-nat-us-east-2a | nat-0ff858c1ca9880179 | ✅ Active |
| Elastic IP | foretale-app-nat-eip-1 | eipalloc-09e3aa02df2bb53f0 | 18.190.69.252 |

---

## 🛣️ ROUTE TABLES

| Name | ID | Type | Status |
|------|-----|------|--------|
| foretale-app-main-rt | rtb-09c400d3f13270378 | Main | ✅ Active |
| foretale-app-public-rt | rtb-0fd8971cdbddeaef5 | Public | ✅ Active |
| foretale-app-private-rt | rtb-02075b5df500a6100 | Private | ✅ Active |
| foretale-app-database-rt | rtb-0532dfd78d2deabe1 | Database | ✅ Active |

### Route Rules
- **Public RT:** 0.0.0.0/0 → IGW (foretale-app-igw)
- **Private RT:** 0.0.0.0/0 → NAT (foretale-app-nat-us-east-2a)
- **Database RT:** Local routes only (VPC internal)

---

## 🔒 SECURITY GROUPS

### Application Layer
| Name | ID | Purpose |
|------|-------|---------|
| foretale-app-ecs-tasks-sg | sg-0ad8dfac3083b58a4 | ECS Task Container Access |
| foretale-app-alb-sg | sg-0e96af64d75de7a0b | Application Load Balancer |

### Service Integration
| Name | ID | Purpose |
|------|-------|---------|
| foretale-app-ai-server-sg | sg-0a674638dfa739028 | AI/ML Server Access |
| foretale-app-lambda-sg | sg-0b0f1552f2ce495d5 | Lambda Function Access |
| foretale-app-vpc-endpoints-sg | sg-0063315a3ab679758 | VPC Endpoint Access |

### Data Layer
| Name | ID | Purpose |
|------|-------|---------|
| foretale-app-rds-sg | sg-098c140212053013a | RDS Database Access |

### Kubernetes/Container Orchestration
| Name | ID | Purpose |
|------|-------|---------|
| foretale-app-eks-20260124131634574200000003 | sg-0001a80293d2ee38f | EKS Control Plane |
| foretale-app-eks-nodes-20260124131634579600000004 | sg-0c7900dd26b3b6c07 | EKS Worker Nodes |

### System
| Name | ID | Purpose |
|------|-------|---------|
| default | sg-0658790f3859bb1ac | AWS System Group |
| foretale-rds-sg | sg-02212827192fdba24 | Shared RDS Group |

---

## 🔌 VPC ENDPOINTS

| Service | Name | ID | Type | Status |
|---------|------|-----|------|--------|
| S3 | foretale-app-s3-endpoint | vpce-04bf4ba07330c8a7e | Gateway | ✅ Active |
| DynamoDB | foretale-app-dynamodb-endpoint | vpce-0dd10c2c36cdaea13 | Gateway | ✅ Active |
| Execute API | foretale-app-execute-api-endpoint | vpce-0181499bc4e02a982 | Interface | ✅ Active |

---

## 🌐 NETWORK INTERFACES

**Active ENIs in foretale-app-vpc: 7**

| ENI ID | Status | Location | Purpose |
|--------|--------|----------|---------|
| eni-08fe085cc09a07a72 | in-use | foretale-app-public-subnet-us-east-2a | NAT Gateway |
| eni-0750dd0a20ff1e87b | in-use | foretale-app-public-subnet-us-east-2b | ALB/Load Balancer |
| eni-078ba9a379d5950d6 | in-use | foretale-app-database-subnet-us-east-2a | RDS Database |
| eni-06c72811f729841d7 | in-use | foretale-app-private-subnet-us-east-2b | ECS Workload |
| eni-0909695e91063e59a | in-use | foretale-app-private-subnet-us-east-2a | ECS Workload |
| eni-0f47df6894f6012ba | in-use | foretale-app-private-subnet-us-east-2c | ECS Workload |
| eni-01ca674c0e0adb978 | available | foretale-app-public-subnet-us-east-2b | Unattached |

---

## 📈 NETWORK ARCHITECTURE

```
Internet
    │
    ↓
[Internet Gateway: foretale-app-igw]
    │
    ├─→ Public Subnets (foretale-app-public-subnet-*)
    │   └─→ NAT Gateway (foretale-app-nat-us-east-2a)
    │       └─→ Elastic IP: 18.190.69.252
    │
    ├─→ Private Subnets (foretale-app-private-subnet-*)
    │   ├─→ ECS Tasks
    │   ├─→ Lambda Functions
    │   └─→ AI/ML Servers
    │
    └─→ Database Subnets (foretale-app-database-subnet-*)
        └─→ RDS Databases

VPC Endpoints:
    ├─→ S3 Gateway (foretale-app-s3-endpoint)
    ├─→ DynamoDB Gateway (foretale-app-dynamodb-endpoint)
    └─→ Execute API Interface (foretale-app-execute-api-endpoint)
```

---

## 🔍 COMMON AWS CLI COMMANDS

### List All Subnets
```bash
aws ec2 describe-subnets --region us-east-2 \
  --filters "Name=vpc-id,Values=vpc-0bb9267ea1818564c" \
  --query 'Subnets[].[SubnetId,Tags[?Key==`Name`]|[0].Value,CidrBlock]' \
  --output table
```

### List All Security Groups
```bash
aws ec2 describe-security-groups --region us-east-2 \
  --filters "Name=vpc-id,Values=vpc-0bb9267ea1818564c" \
  --query 'SecurityGroups[].[GroupId,GroupName]' \
  --output table
```

### Check VPC Details
```bash
aws ec2 describe-vpcs --region us-east-2 \
  --vpc-ids vpc-0bb9267ea1818564c \
  --query 'Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`]|[0].Value]' \
  --output table
```

### List All Route Tables
```bash
aws ec2 describe-route-tables --region us-east-2 \
  --filters "Name=vpc-id,Values=vpc-0bb9267ea1818564c" \
  --query 'RouteTables[].[RouteTableId,Tags[?Key==`Name`]|[0].Value]' \
  --output table
```

### List VPC Endpoints
```bash
aws ec2 describe-vpc-endpoints --region us-east-2 \
  --filters "Name=vpc-id,Values=vpc-0bb9267ea1818564c" \
  --query 'VpcEndpoints[].[VpcEndpointId,ServiceName,State]' \
  --output table
```

---

## 🔄 INFRASTRUCTURE UPDATES

**Last Audit:** February 3, 2026  
**Last Naming Update:** February 3, 2026  
**Compliance Status:** ✅ 100% Compliant  
**Production Status:** ✅ Ready  

---

## 📝 RELATED DOCUMENTATION

- [NETWORKING_AUDIT_FEB3_2026.md](NETWORKING_AUDIT_FEB3_2026.md) - Full audit details
- [NAMING_CORRECTIONS_COMPLETE.md](NAMING_CORRECTIONS_COMPLETE.md) - Naming corrections report
- [ARCHITECTURE.md](ARCHITECTURE.md) - Overall architecture
- [VPC_CONSOLIDATION_SUMMARY.md](VPC_CONSOLIDATION_SUMMARY.md) - Consolidation details

---

**Quick Access:** Keep this file handy for rapid resource lookups during operational tasks.
