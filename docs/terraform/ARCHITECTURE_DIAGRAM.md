# ForeTale Infrastructure - Phase 1 Architecture

## Network Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  AWS Region: us-east-1                                                      │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │ VPC: foretale-dev-vpc (10.0.0.0/16)                                   │ │
│  │                                                                         │ │
│  │  ┌────────────────────┐   ┌────────────────────┐   ┌────────────────┐ │ │
│  │  │  AZ: us-east-1a    │   │  AZ: us-east-1b    │   │  AZ: us-east-1c│ │ │
│  │  │                    │   │                    │   │                │ │ │
│  │  │ ┌────────────────┐ │   │ ┌────────────────┐ │   │ ┌──────────────┐│ │
│  │  │ │ Public Subnet  │ │   │ │ Public Subnet  │ │   │ │Public Subnet││ │
│  │  │ │ 10.0.1.0/24    │ │   │ │ 10.0.2.0/24    │ │   │ │10.0.3.0/24  ││ │
│  │  │ │                │ │   │ │                │ │   │ │             ││ │
│  │  │ │ ┌────────────┐ │ │   │ │                │ │   │ │             ││ │
│  │  │ │ │NAT Gateway │ │ │   │ │                │ │   │ │             ││ │
│  │  │ │ │(dev only)  │ │ │   │ │                │ │   │ │             ││ │
│  │  │ │ └────────────┘ │ │   │ │                │ │   │ │             ││ │
│  │  │ └────────────────┘ │   │ └────────────────┘ │   │ └──────────────┘│ │
│  │  │        ↑           │   │                    │   │                │ │
│  │  │        │           │   │                    │   │                │ │
│  │  │ ┌────────────────┐ │   │ ┌────────────────┐ │   │ ┌──────────────┐│ │
│  │  │ │Private Subnet  │ │   │ │Private Subnet  │ │   │ │Private Subnet││ │
│  │  │ │ 10.0.11.0/24   │ │   │ │ 10.0.12.0/24   │ │   │ │10.0.13.0/24 ││ │
│  │  │ │                │ │   │ │                │ │   │ │             ││ │
│  │  │ │ ECS Tasks      │ │   │ │ ECS Tasks      │ │   │ │ ECS Tasks   ││ │
│  │  │ │ Lambda         │ │   │ │ Lambda         │ │   │ │ Lambda      ││ │
│  │  │ └────────────────┘ │   │ └────────────────┘ │   │ └──────────────┘│ │
│  │  │                    │   │                    │   │                │ │
│  │  │ ┌────────────────┐ │   │ ┌────────────────┐ │   │ ┌──────────────┐│ │
│  │  │ │Database Subnet │ │   │ │Database Subnet │ │   │ │Database      ││ │
│  │  │ │ 10.0.21.0/24   │ │   │ │ 10.0.22.0/24   │ │   │ │Subnet        ││ │
│  │  │ │                │ │   │ │                │ │   │ │10.0.23.0/24 ││ │
│  │  │ │ RDS (Phase 2)  │ │   │ │ RDS (Phase 2)  │ │   │ │ RDS         ││ │
│  │  │ └────────────────┘ │   │ └────────────────┘ │   │ └──────────────┘│ │
│  │  └────────────────────┘   └────────────────────┘   └────────────────┘ │
│  │                                                                         │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  │ Internet Gateway                                                  │  │
│  │  └──────────────────────────────────────────────────────────────────┘  │
│  │                                   ↕                                     │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                     ↕                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ↕
                                 Internet
```

## Security Groups Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│ Security Group Layer                                             │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ALB Security Group (foretale-dev-alb-sg)                │    │
│  │ Ingress: 0.0.0.0/0:80, 0.0.0.0/0:443                    │    │
│  │ Egress: All                                             │    │
│  └─────────────────────┬───────────────────────────────────┘    │
│                        │                                         │
│                        ↓                                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ ECS Tasks Security Group (foretale-dev-ecs-tasks-sg)    │    │
│  │ Ingress: ALB SG, VPC CIDR                               │    │
│  │ Egress: All                                             │    │
│  └─────────┬──────────────────────────────────────────┬────┘    │
│            │                                          │          │
│            ↓                                          ↓          │
│  ┌─────────────────────┐                  ┌──────────────────┐  │
│  │ Lambda SG           │                  │ RDS SG           │  │
│  │ (foretale-dev-      │                  │ (foretale-dev-   │  │
│  │  lambda-sg)         │                  │  rds-sg)         │  │
│  │ Ingress: VPC CIDR   │                  │ Ingress: ECS SG, │  │
│  │ Egress: All         │                  │  Lambda SG:5432  │  │
│  └─────────────────────┘                  │ Egress: All      │  │
│                                           └──────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ AI Server SG (foretale-dev-ai-server-sg)                 │   │
│  │ Ingress: 0.0.0.0/0:8002 (WebSocket), SSH:22             │   │
│  │ Egress: All                                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ VPC Endpoints SG (foretale-dev-vpc-endpoints-sg)         │   │
│  │ Ingress: VPC CIDR:443                                    │   │
│  │ Egress: All                                              │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## IAM Roles and Permissions

```
┌─────────────────────────────────────────────────────────────────┐
│ IAM Roles (Least Privilege)                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ECS Task Execution Role                                        │
│  ├─ Name: foretale-dev-ecs-task-execution-role                 │
│  ├─ Trust: ecs-tasks.amazonaws.com                             │
│  └─ Permissions:                                                │
│     ├─ ECR: Pull images                                        │
│     ├─ CloudWatch Logs: Create/Write logs                      │
│     └─ Secrets Manager: Get secrets                            │
│                                                                 │
│  ECS Task Role                                                  │
│  ├─ Name: foretale-dev-ecs-task-role                           │
│  ├─ Trust: ecs-tasks.amazonaws.com                             │
│  └─ Permissions:                                                │
│     ├─ S3: GetObject, PutObject, DeleteObject                  │
│     └─ CloudWatch Logs: Write logs                             │
│                                                                 │
│  Lambda Execution Role                                          │
│  ├─ Name: foretale-dev-lambda-execution-role                   │
│  ├─ Trust: lambda.amazonaws.com                                │
│  └─ Permissions:                                                │
│     ├─ VPC: Create/Manage ENIs                                 │
│     ├─ RDS Data API: Execute statements                        │
│     ├─ S3: GetObject, PutObject                                │
│     ├─ ECS: RunTask, DescribeTasks, StopTask                   │
│     ├─ Secrets Manager: Get secrets                            │
│     └─ IAM: PassRole (to ECS)                                  │
│                                                                 │
│  API Gateway CloudWatch Role                                    │
│  ├─ Name: foretale-dev-api-gateway-cloudwatch-role             │
│  ├─ Trust: apigateway.amazonaws.com                            │
│  └─ Permissions:                                                │
│     └─ CloudWatch Logs: Push API logs                          │
│                                                                 │
│  Amplify Service Role                                           │
│  ├─ Name: foretale-dev-amplify-service-role                    │
│  ├─ Trust: amplify.amazonaws.com                               │
│  └─ Permissions:                                                │
│     └─ Amplify: Backend deployment                             │
│                                                                 │
│  AI Server EC2 Role                                             │
│  ├─ Name: foretale-dev-ai-server-role                          │
│  ├─ Instance Profile: foretale-dev-ai-server-profile           │
│  ├─ Trust: ec2.amazonaws.com                                   │
│  └─ Permissions:                                                │
│     ├─ Bedrock: InvokeModel, InvokeModelWithResponseStream     │
│     ├─ S3: GetObject, PutObject                                │
│     └─ CloudWatch Logs: Write logs                             │
│                                                                 │
│  RDS Monitoring Role                                            │
│  ├─ Name: foretale-dev-rds-monitoring-role                     │
│  ├─ Trust: monitoring.rds.amazonaws.com                        │
│  └─ Permissions:                                                │
│     └─ CloudWatch: Enhanced monitoring                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Traffic Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  User (Internet)                                                │
│       │                                                         │
│       │ HTTPS                                                   │
│       ↓                                                         │
│  ┌──────────────────────┐                                       │
│  │ Internet Gateway     │                                       │
│  └──────────┬───────────┘                                       │
│             │                                                   │
│             │                                                   │
│             ↓                                                   │
│  ┌──────────────────────┐     ┌──────────────────────┐        │
│  │ Public Subnets       │────→│ NAT Gateway          │        │
│  │ - ALB (Phase 5)      │     │ (Internet for        │        │
│  │ - AI Server (Phase 6)│     │  private resources)  │        │
│  └──────────┬───────────┘     └──────────────────────┘        │
│             │                                                   │
│             │                                                   │
│             ↓                                                   │
│  ┌──────────────────────┐                                       │
│  │ Private Subnets      │                                       │
│  │ - ECS Tasks          │                                       │
│  │ - Lambda Functions   │                                       │
│  └──────────┬───────────┘                                       │
│             │                                                   │
│             │ PostgreSQL:5432                                   │
│             ↓                                                   │
│  ┌──────────────────────┐                                       │
│  │ Database Subnets     │                                       │
│  │ - RDS PostgreSQL     │                                       │
│  │   (Phase 2)          │                                       │
│  └──────────────────────┘                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Route Tables

```
┌─────────────────────────────────────────────────────────────────┐
│ Public Route Table (foretale-dev-public-rt)                     │
├─────────────────────────────────────────────────────────────────┤
│ Destination         │ Target                                    │
├─────────────────────┼──────────────────────────────────────────┤
│ 10.0.0.0/16         │ local                                     │
│ 0.0.0.0/0           │ Internet Gateway                          │
└─────────────────────┴──────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ Private Route Table (foretale-dev-private-rt)                   │
├─────────────────────────────────────────────────────────────────┤
│ Destination         │ Target                                    │
├─────────────────────┼──────────────────────────────────────────┤
│ 10.0.0.0/16         │ local                                     │
│ 0.0.0.0/0           │ NAT Gateway                               │
└─────────────────────┴──────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ Database Route Table (foretale-dev-database-rt)                 │
├─────────────────────────────────────────────────────────────────┤
│ Destination         │ Target                                    │
├─────────────────────┼──────────────────────────────────────────┤
│ 10.0.0.0/16         │ local                                     │
│                     │ (No internet access)                      │
└─────────────────────┴──────────────────────────────────────────┘
```

## Resource Naming Convention

```
Format: {project}-{environment}-{resource}-{descriptor}

Examples:
- foretale-dev-vpc
- foretale-dev-public-subnet-us-east-1a
- foretale-dev-private-subnet-us-east-1a
- foretale-dev-database-subnet-us-east-1a
- foretale-dev-alb-sg
- foretale-dev-ecs-tasks-sg
- foretale-dev-rds-sg
- foretale-dev-lambda-sg
- foretale-dev-ecs-task-execution-role
- foretale-dev-lambda-execution-role
- foretale-dev-api-gateway-cloudwatch-role

Production would be:
- foretale-prod-vpc
- foretale-prod-ecs-task-execution-role
- etc.
```

## High Availability Design

```
┌──────────────────────────────────────────────────────────────┐
│ Multi-AZ Deployment (3 Availability Zones)                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  us-east-1a        us-east-1b        us-east-1c             │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐          │
│  │ Public   │      │ Public   │      │ Public   │          │
│  │ Private  │      │ Private  │      │ Private  │          │
│  │ Database │      │ Database │      │ Database │          │
│  └──────────┘      └──────────┘      └──────────┘          │
│                                                              │
│  Benefits:                                                   │
│  ✓ Fault tolerance                                          │
│  ✓ High availability                                        │
│  ✓ Load distribution                                        │
│  ✓ Zero downtime deployments                                │
│                                                              │
│  Future Phases:                                              │
│  - RDS Multi-AZ (automatic failover)                        │
│  - ECS tasks across multiple AZs                            │
│  - ALB distributes across all AZs                           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Scalability & Cost Optimization

```
Development Environment (Current):
┌─────────────────────────────────────┐
│ Single NAT Gateway                  │
│ - Cost: ~$32/month                  │
│ - Located in us-east-1a             │
│ - All private subnets route here    │
└─────────────────────────────────────┘

Production Environment (Recommended):
┌─────────────────────────────────────┐
│ NAT Gateway per AZ                  │
│ - Cost: ~$96/month                  │
│ - High availability                 │
│ - Better performance                │
│ - No single point of failure        │
└─────────────────────────────────────┘

To Switch:
In terraform.tfvars, set:
single_nat_gateway = false
```

---

**Legend:**
- `→` : Traffic flow
- `↓` : Routing
- `├─` : Component/Permission
- `└─` : Last item in list

**Phase**: 1 of 6  
**Status**: Infrastructure Ready for Phase 2  
**Next**: Deploy RDS, S3, ECR
