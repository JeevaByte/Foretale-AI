# Networking and Load Balancer Status Report
**Region:** us-east-2  
**Date:** February 16, 2026  
**Environment:** Development

## Executive Summary

**Overall Status:** ✅ Networking layer configured correctly, ⚠️ Load balancer partially functional

### Key Findings
- VPC and subnet architecture properly deployed across 3 availability zones
- Internet Gateway and NAT Gateway operational
- Security groups configured with appropriate rules
- ALB active but returning 503 (no healthy targets)
- Target group instances not receiving traffic (Target.NotInUse)
- Auto Scaling Group healthy but not attached to target group

---

## 1. VPC Configuration

### VPC Details
| VPC ID | CIDR Block | Name | State |
|--------|------------|------|-------|
| vpc-0bb9267ea1818564c | 10.0.0.0/16 | foretale-dev-vpc | available |

**Status:** ✅ Active and properly configured

---

## 2. Subnet Architecture

### Subnet Distribution (9 subnets across 3 AZs)

#### Public Subnets (Internet-facing)
| Subnet ID | CIDR | AZ | Name |
|-----------|------|-----|------|
| subnet-0f546c8342e908ba4 | 10.0.1.0/24 | us-east-2a | foretale-dev-public-subnet-us-east-2a |
| subnet-0c76e28ef555b9159 | 10.0.2.0/24 | us-east-2b | foretale-dev-public-subnet-us-east-2b |
| subnet-00ab6ebd3305afd8a | 10.0.3.0/24 | us-east-2c | foretale-dev-public-subnet-us-east-2c |

#### Private Subnets (Application tier)
| Subnet ID | CIDR | AZ | Name |
|-----------|------|-----|------|
| subnet-0eb005ebf922d4da1 | 10.0.11.0/24 | us-east-2a | foretale-dev-private-subnet-us-east-2a |
| subnet-0d2a35802b544fcb3 | 10.0.12.0/24 | us-east-2b | foretale-dev-private-subnet-us-east-2b |
| subnet-099c4a4b51deaf9e2 | 10.0.13.0/24 | us-east-2c | foretale-dev-private-subnet-us-east-2c |

#### Database Subnets (Data tier)
| Subnet ID | CIDR | AZ | Name |
|-----------|------|-----|------|
| subnet-0474663ac69b7f53f | 10.0.21.0/24 | us-east-2a | foretale-dev-database-subnet-us-east-2a |
| subnet-06005d32dc838779b | 10.0.22.0/24 | us-east-2b | foretale-dev-database-subnet-us-east-2b |
| subnet-0b817d17b0d6ca506 | 10.0.23.0/24 | us-east-2c | foretale-dev-database-subnet-us-east-2c |

**Status:** ✅ Multi-AZ architecture properly implemented

---

## 3. Internet Connectivity

### Internet Gateway
| IGW ID | Attached VPC | State | Name |
|--------|--------------|-------|------|
| igw-0c75c5a6c54c48ff1 | vpc-0bb9267ea1818564c | available | foretale-dev-igw |

**Status:** ✅ Attached and operational

### NAT Gateway
| NAT Gateway ID | State | Subnet | Public IP | Name |
|----------------|-------|--------|-----------|------|
| nat-0ff858c1ca9880179 | available | subnet-0f546c8342e908ba4 (us-east-2a) | 18.190.69.252 | foretale-dev-nat-us-east-2a |

**Status:** ✅ Active in single AZ (cost optimization)
**Note:** Only 1 NAT Gateway deployed (single AZ) - consider adding NAT Gateways in us-east-2b and us-east-2c for high availability

---

## 4. Route Tables

| Route Table ID | Name | Type | Associated Subnets | Routes |
|----------------|------|------|-------------------|--------|
| rtb-0fd8971cdbddeaef5 | foretale-dev-public-rt | Public | 3 | 4 |
| rtb-02075b5df500a6100 | foretale-dev-private-rt | Private | 3 | 4 |
| rtb-0532dfd78d2deabe1 | foretale-dev-database-rt | Private | 3 | 3 |

**Status:** ✅ All subnets properly associated with route tables

### Expected Routes:
- **Public RT:** Local VPC + Internet Gateway (0.0.0.0/0 → igw)
- **Private RT:** Local VPC + NAT Gateway (0.0.0.0/0 → nat-gw)
- **Database RT:** Local VPC + VPC Endpoints (restricted internet access)

---

## 5. Security Groups

| Group ID | Name | Inbound Rules | Outbound Rules | Purpose |
|----------|------|---------------|----------------|---------|
| sg-0e96af64d75de7a0b | foretale-dev-alb-sg | 2 | 1 | Application Load Balancer |
| sg-0a674638dfa739028 | foretale-dev-ai-server-sg | 3 | 1 | AI Server instances |
| sg-0ad8dfac3083b58a4 | foretale-dev-ecs-tasks-sg | 1 | 1 | ECS Fargate tasks |
| sg-0b0f1552f2ce495d5 | foretale-dev-lambda-sg | 1 | 1 | Lambda functions |
| sg-098c140212053013a | foretale-dev-rds-sg | 1 | 1 | RDS databases |
| sg-0063315a3ab679758 | foretale-dev-vpc-endpoints-sg | 1 | 1 | VPC Endpoints |

**Status:** ✅ All security groups configured

### ALB Security Group Details (foretale-dev-alb-sg)

**Inbound Rules:**
- TCP Port 80 from 0.0.0.0/0 (HTTP traffic from internet)
- TCP Port 443 from 0.0.0.0/0 (HTTPS traffic from internet)

**Outbound Rules:**
- All traffic to 0.0.0.0/0 (unrestricted outbound)

**Status:** ✅ Properly configured for internet-facing load balancer

---

## 6. Application Load Balancer (ALB)

### ALB Configuration
| Property | Value |
|----------|-------|
| **Name** | foretale-app-alb-main |
| **DNS Name** | foretale-app-alb-main-454419653.us-east-2.elb.amazonaws.com |
| **State** | active |
| **Type** | application |
| **Scheme** | internet-facing |
| **Availability Zones** | 3 (us-east-2a, us-east-2b, us-east-2c) |

**Status:** ✅ ALB is active and deployed across all 3 AZs

### Listeners
| Protocol | Port | Default Action | Target Group |
|----------|------|----------------|--------------|
| HTTP | 80 | forward | foretale-app-tg (default) |

**Status:** ✅ HTTP listener configured

### Listener Rules
| Priority | Conditions | Action | Target Group ID | Default |
|----------|------------|--------|-----------------|---------|
| 50 | 1 | forward | 1fdda9398515e3ef | No |
| 100 | 1 | forward | 66966418e0f36a50 | No |
| default | 0 | forward | 1fdda9398515e3ef | Yes |

**Status:** ✅ Routing rules configured

### ALB Health Check
**Test Result:**
```
URL: http://foretale-app-alb-main-454419653.us-east-2.elb.amazonaws.com
Status: 503 Server Unavailable
```

**Status:** ❌ ALB returning 503 (no healthy backend targets)

---

## 7. Target Groups

### Target Group: foretale-app-tg
| Property | Value |
|----------|-------|
| **Protocol** | HTTP |
| **Port** | 80 |
| **Health Check Path** | / |
| **Health Check Protocol** | HTTP |
| **Registered Targets** | 2 |
| **Healthy Targets** | 0 |

**Targets:**
| Instance ID | Port | State | Reason | Description |
|-------------|------|-------|--------|-------------|
| i-01d10023ca03096ba | 80 | unused | Target.NotInUse | Target group is not configured to receive traffic from the load balancer |
| i-0b8355e329e6a455d | 80 | unused | Target.NotInUse | Target group is not configured to receive traffic from the load balancer |

**Status:** ❌ Targets marked as "unused" - listener routing issue

### Target Group: foretale-dev-eks-tg
| Protocol | Port | Health Check | Registered | Healthy |
|----------|------|--------------|-----------|---------|
| HTTP | 80 | / | 0 | N/A |

**Status:** ⚠️ No targets registered (EKS not deployed)

### Target Group: foretale-dev-lambda-tg
| Protocol | Port | Health Check | Registered | Healthy |
|----------|------|--------------|-----------|---------|
| N/A (Lambda) | N/A | / | 0 | N/A |

**Status:** ⚠️ No Lambda targets registered

---

## 8. Auto Scaling Group

### ASG Configuration
| Property | Value |
|----------|-------|
| **Name** | foretale-dev-ai-servers-asg |
| **Desired Capacity** | 1 |
| **Min Size** | 1 |
| **Max Size** | 10 |
| **Current Instances** | 1 |
| **Healthy Instances** | 1 |
| **Target Groups Attached** | 0 |

**Status:** ⚠️ ASG healthy but NOT attached to any target group

### ASG Instance Details
| Instance ID | Lifecycle State | Health Status | Availability Zone |
|-------------|----------------|---------------|-------------------|
| i-09643fe0df48ba40f | InService | Healthy | us-east-2a |

**Status:** ✅ Instance healthy in ASG

---

## 9. Running EC2 Instances

| Instance ID | Type | Name | Private IP | Subnet | State |
|-------------|------|------|------------|--------|-------|
| i-09643fe0df48ba40f | t3.medium | foretale-dev-ai-server | 10.0.11.107 | foretale-dev-private-subnet-us-east-2a | running |

**Status:** ✅ 1 instance running in private subnet

---

## Issues Identified

### Critical Issues

#### 1. ALB Returns 503 - No Healthy Targets
**Symptom:** Load balancer returning "503 Server Unavailable"
**Root Cause:** Target group has 2 registered instances but both marked as "Target.NotInUse"
**Impact:** Applications cannot be accessed through load balancer
**Resolution Required:**
- Verify listener rules route traffic to correct target group
- Check if target group is attached to listener
- Confirm target group ARN matches listener configuration

#### 2. Auto Scaling Group Not Attached to Target Group
**Symptom:** ASG shows `TargetGroups: 0`
**Root Cause:** ASG definition missing `target_group_arns` parameter
**Impact:** New instances launched by ASG won't automatically register with ALB
**Resolution Required:**
```bash
aws autoscaling attach-load-balancer-target-groups \
  --auto-scaling-group-name foretale-dev-ai-servers-asg \
  --target-group-arns arn:aws:elasticloadbalancing:us-east-2:442426872653:targetgroup/foretale-app-tg/<tg-id> \
  --region us-east-2
```

#### 3. Target Instances Marked as "Unused"
**Symptom:** Both instances in target group show state "unused" with reason "Target.NotInUse"
**Root Cause:** Listener not forwarding traffic to this target group OR wrong target group attached
**Impact:** Even healthy instances won't receive traffic
**Resolution Required:**
- Verify listener default action points to foretale-app-tg
- Check listener rule conditions match expected traffic patterns
- Confirm target group ARN in listener matches foretale-app-tg ARN

### Warnings

#### 4. Single NAT Gateway (Single Point of Failure)
**Current:** 1 NAT Gateway in us-east-2a
**Risk:** If us-east-2a fails, private subnets in us-east-2b and us-east-2c lose internet access
**Recommendation:** Deploy NAT Gateways in us-east-2b and us-east-2c for high availability
**Cost Impact:** ~$97/month additional ($32.40/month per NAT Gateway × 2)

#### 5. No HTTPS Listener Configured
**Current:** Only HTTP (port 80) listener active
**Risk:** Traffic not encrypted, vulnerable to eavesdropping
**Recommendation:** 
- Add ACM certificate
- Create HTTPS listener on port 443
- Redirect HTTP to HTTPS

#### 6. EKS and Lambda Target Groups Empty
**Current:** foretale-dev-eks-tg and foretale-dev-lambda-tg have no registered targets
**Status:** Expected if EKS cluster and Lambda integrations not yet deployed
**Action:** Monitor when these services are deployed

---

## Recommended Actions

### Immediate Actions (Critical)

1. **Fix ALB Target Group Association**
   ```bash
   # Get target group ARN
   aws elbv2 describe-target-groups --names foretale-app-tg --region us-east-2
   
   # Attach ASG to target group
   aws autoscaling attach-load-balancer-target-groups \
     --auto-scaling-group-name foretale-dev-ai-servers-asg \
     --target-group-arns <FULL_TARGET_GROUP_ARN> \
     --region us-east-2
   ```

2. **Verify Listener Default Action**
   ```bash
   # Check current listener configuration
   aws elbv2 describe-listeners \
     --load-balancer-arn <ALB_ARN> \
     --region us-east-2
   
   # Verify default action target group matches foretale-app-tg
   ```

3. **Check Target Health After Fix**
   ```bash
   # Wait 1-2 minutes for health checks
   aws elbv2 describe-target-health \
     --target-group-arn <TG_ARN> \
     --region us-east-2
   
   # Should show: State: "healthy" instead of "unused"
   ```

### Short-term Actions (Within 1 week)

4. **Add HTTPS Support**
   - Request ACM certificate for domain
   - Add HTTPS listener (port 443)
   - Configure HTTP → HTTPS redirect

5. **Review Security Group Rules**
   - Ensure ALB security group allows traffic to backend instances
   - Verify backend instance security groups allow traffic from ALB

6. **Enable Access Logs**
   ```bash
   aws elbv2 modify-load-balancer-attributes \
     --load-balancer-arn <ALB_ARN> \
     --attributes Key=access_logs.s3.enabled,Value=true \
              Key=access_logs.s3.bucket,Value=<S3_BUCKET_NAME> \
     --region us-east-2
   ```

### Long-term Actions (Within 1 month)

7. **Deploy Additional NAT Gateways**
   - Create NAT Gateway in us-east-2b
   - Create NAT Gateway in us-east-2c
   - Update private route tables for multi-AZ failover

8. **Implement Web Application Firewall (WAF)**
   - Attach AWS WAF to ALB
   - Configure common attack protection rules
   - Set up rate limiting

9. **Set Up CloudWatch Alarms**
   - ALB TargetResponseTime > 2s
   - ALB UnHealthyHostCount > 0
   - ALB HTTPCode_Target_5XX_Count > 10
   - ALB RequestCount (traffic monitoring)

---

## Testing Checklist

After fixes are applied, verify:

- [ ] ALB responds with HTTP 200 (not 503)
  ```bash
  curl -I http://foretale-app-alb-main-454419653.us-east-2.elb.amazonaws.com
  ```

- [ ] Target group shows healthy targets:
  ```bash
  aws elbv2 describe-target-health --target-group-arn <ARN> --region us-east-2
  # Expected: State = "healthy"
  ```

- [ ] ASG attached to target group:
  ```bash
  aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names foretale-dev-ai-servers-asg \
    --region us-east-2 | grep TargetGroupARNs
  # Should show target group ARN
  ```

- [ ] New instances auto-register:
  ```bash
  # Scale up ASG
  aws autoscaling set-desired-capacity \
    --auto-scaling-group-name foretale-dev-ai-servers-asg \
    --desired-capacity 2 --region us-east-2
  
  # Wait 2-3 minutes, check target group has 2 healthy targets
  ```

- [ ] Internet connectivity from private subnet:
  ```bash
  # SSH to instance via Session Manager
  aws ssm start-session --target i-09643fe0df48ba40f --region us-east-2
  
  # Test outbound connectivity
  curl -I https://www.google.com
  # Should succeed via NAT Gateway
  ```

---

## Architecture Diagram

```
Internet
   ↓
Internet Gateway (igw-0c75c5a6c54c48ff1)
   ↓
┌─────────────────────────────────────────────────────────┐
│              VPC: 10.0.0.0/16                           │
│                                                          │
│  Public Subnets (10.0.1-3.0/24)                        │
│  ├─ us-east-2a: ALB (active)                           │
│  ├─ us-east-2b: ALB (active)                           │
│  └─ us-east-2c: ALB (active)                           │
│       │                                                  │
│       ↓                                                  │
│  Application Load Balancer                              │
│  DNS: foretale-app-alb-main-454419653...                │
│  Status: Active, returning 503 ❌                       │
│       │                                                  │
│       ↓                                                  │
│  Target Group: foretale-app-tg                          │
│  Targets: 2 instances (unused) ❌                       │
│       │                                                  │
│       ↓                                                  │
│  Private Subnets (10.0.11-13.0/24)                     │
│  ├─ us-east-2a: AI Server (i-09643fe...) ✅            │
│  ├─ us-east-2b: (available)                            │
│  └─ us-east-2c: (available)                            │
│       │                                                  │
│       ↓ (via NAT Gateway)                               │
│  Database Subnets (10.0.21-23.0/24)                    │
│  ├─ us-east-2a: RDS instances                          │
│  ├─ us-east-2b: RDS instances                          │
│  └─ us-east-2c: RDS instances                          │
└─────────────────────────────────────────────────────────┘
   ↓ (Outbound from private)
NAT Gateway (nat-0ff858c1ca9880179)
   ↓
Internet
```

---

## Summary

### What's Working ✅
- VPC and subnet architecture properly deployed
- Multi-AZ distribution (3 availability zones)
- Internet Gateway and NAT Gateway operational
- Security groups configured correctly
- ALB deployed and active across 3 AZs
- Auto Scaling Group with 1 healthy instance
- EC2 instance running in private subnet

### What Needs Attention ❌
- ALB returning 503 (no traffic flow to backends)
- Target instances marked as "unused" 
- ASG not attached to target group
- No HTTPS/SSL configured
- Single NAT Gateway (availability risk)

### Next Steps
1. Attach ASG to ALB target group
2. Verify listener routes to correct target group
3. Test ALB endpoint returns 200 OK
4. Add HTTPS listener with SSL certificate
5. Consider deploying NAT Gateways in remaining AZs

---

**Report Generated:** February 16, 2026  
**Generated By:** Infrastructure Audit Script  
**Region:** us-east-2 (Ohio)
