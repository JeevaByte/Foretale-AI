# Foretale Application - AWS Architecture (Phase 2 Complete)

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS REGION: US-EAST-2                              │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    VPC: 10.0.0.0/16                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │                    PHASE 1 - INFRASTRUCTURE                      │  │ │
│  │  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐   │  │ │
│  │  │  │ Public Subnets   │  │ Private Subnets  │  │ DB Subnets   │   │  │ │
│  │  │  │ (3x AZ)          │  │ (3x AZ)          │  │ (3x AZ)      │   │  │ │
│  │  │  │ + NAT Gateway    │  │ + Lambda         │  │ + RDS ✓      │   │  │ │
│  │  │  │ + IGW            │  │ + ECS            │  │ + RDS Subnet │   │  │ │
│  │  │  │                  │  │ + DynamoDB       │  │   Group      │   │  │ │
│  │  │  │                  │  │ + S3 (VPC EP)    │  │              │   │  │ │
│  │  │  └──────────────────┘  └──────────────────┘  └──────────────┘   │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  │                                                                           │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │              PHASE 2 - DATABASE & STORAGE LAYER (NEW)            │  │ │
│  │  │                                                                    │  │ │
│  │  │  ┌──────────────────────────────┐      ┌────────────────────┐   │  │ │
│  │  │  │  RDS PostgreSQL 15           │      │  Secrets Manager   │   │  │ │
│  │  │  │  db.t3.micro (20GB)          │◄─────┤  (DB Credentials)  │   │  │ │
│  │  │  │  - foretale-dev-postgres     │      │  ✓ Secure Storage  │   │  │ │
│  │  │  │  - Database: foretaledb      │      └────────────────────┘   │  │ │
│  │  │  │  - User: foretaleadmin       │                               │  │ │
│  │  │  │  - Performance Insights: ON  │                               │  │ │
│  │  │  │  - Backups: 7-day retention  │                               │  │ │
│  │  │  │  - Query Monitoring: ON      │                               │  │ │
│  │  │  │    (pg_stat_statements)      │                               │  │ │
│  │  │  │  ✓ Security Group: RDS-SG   │                               │  │ │
│  │  │  └──────────────────────────────┘                               │  │ │
│  │  │                                                                    │  │ │
│  │  │  ┌───────────────────────────────────────────────────────────┐   │  │ │
│  │  │  │  S3 BACKUPS BUCKET - Tiered Lifecycle (PHASE 2)          │   │  │ │
│  │  │  │  ┌──────────────────────────────────────────────────────┐│   │  │ │
│  │  │  │  │ Days 0-30:    STANDARD               (hot, active)  ││   │  │ │
│  │  │  │  │         ↓ (30-day transition)                        ││   │  │ │
│  │  │  │  │ Days 30-90:   STANDARD_IA           (warm, frequent)││   │  │ │
│  │  │  │  │         ↓ (60-day transition gap - AWS compliant)   ││   │  │ │
│  │  │  │  │ Days 90-180:  GLACIER_IR            (cool, archive) ││   │  │ │
│  │  │  │  │         ↓ (90-day transition gap - AWS compliant)   ││   │  │ │
│  │  │  │  │ Days 180-730: DEEP_ARCHIVE          (cold, archive) ││   │  │ │
│  │  │  │  │         ↓ (deletion after 730 days)                 ││   │  │ │
│  │  │  │  │ Expiration:   DELETE                (cost control)  ││   │  │ │
│  │  │  │  │ Versioning: ENABLED                                 ││   │  │ │
│  │  │  │  │ Encryption:  AES-256 (SSE-S3)                      ││   │  │ │
│  │  │  │  │ Public Access: BLOCKED                              ││   │  │ │
│  │  │  │  │ ✓ AWS Compliant (90-day minimum gaps)              ││   │  │ │
│  │  │  │  └──────────────────────────────────────────────────────┘│   │  │ │
│  │  │  └───────────────────────────────────────────────────────────┘   │  │ │
│  │  │                                                                    │  │ │
│  │  │  ┌────────────────────────────────────────────────────────┐     │  │ │
│  │  │  │  Additional S3 Buckets (from Phase 1)                 │     │  │ │
│  │  │  │  - foretale-dev-app-storage (with lifecycle)          │     │  │ │
│  │  │  │  - foretale-dev-user-uploads (with lifecycle)         │     │  │ │
│  │  │  │  - foretale-dev-analytics (with lifecycle)            │     │  │ │
│  │  │  └────────────────────────────────────────────────────────┘     │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  │                                                                           │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │           PHASE 1 - DATA STORE LAYER (Existing)                  │  │ │
│  │  │                                                                    │  │ │
│  │  │  DynamoDB Tables (On-Demand Billing)                             │  │ │
│  │  │  ├─ foretale-dev-sessions                                        │  │ │
│  │  │  ├─ foretale-dev-cache                                           │  │ │
│  │  │  ├─ foretale-dev-ai-state                                        │  │ │
│  │  │  ├─ foretale-dev-audit-logs                                      │  │ │
│  │  │  └─ foretale-dev-websocket-connections                           │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  │                                                                           │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │           PHASE 1 - SECURITY & IAM LAYER (Existing)              │  │ │
│  │  │                                                                    │  │ │
│  │  │  Security Groups:                                                │  │ │
│  │  │  ├─ RDS Security Group (port 5432)                              │  │ │
│  │  │  ├─ Lambda Security Group                                        │  │ │
│  │  │  ├─ ECS Tasks Security Group                                     │  │ │
│  │  │  ├─ ALB Security Group                                           │  │ │
│  │  │  ├─ AI Server Security Group                                     │  │ │
│  │  │  └─ VPC Endpoints Security Group                                 │  │ │
│  │  │                                                                    │  │ │
│  │  │  IAM Roles & Policies:                                           │  │ │
│  │  │  ├─ RDS Monitoring Role                                          │  │ │
│  │  │  ├─ ECS Task Execution Role                                      │  │ │
│  │  │  ├─ ECS Task Role (CloudWatch logs)                              │  │ │
│  │  │  ├─ Lambda Execution Role (VPC + RDS)                            │  │ │
│  │  │  ├─ Amplify Service Role                                         │  │ │
│  │  │  ├─ AI Server Role (EC2)                                         │  │ │
│  │  │  └─ API Gateway CloudWatch Role                                  │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  MONITORING & OBSERVABILITY:                                                │
│  ├─ CloudWatch Metrics (RDS CPU, Storage, Connections)                     │
│  ├─ RDS Performance Insights (query performance analysis)                   │
│  ├─ pg_stat_statements (PostgreSQL query statistics)                       │
│  ├─ CloudWatch Logs (RDS, Lambda, ECS)                                    │
│  └─ AWS Secrets Manager (Credential rotation ready)                        │
│                                                                               │
│  TERRAFORM MANAGEMENT:                                                      │
│  ├─ Total Managed Resources: 65+                                           │
│  ├─ Phase 1 Resources: ~55 (VPC, DynamoDB, S3, IAM, Security Groups)      │
│  ├─ Phase 2 Resources: ~10 (RDS, Secrets Manager, Lifecycle Config)       │
│  ├─ State Location: terraform/terraform.tfstate                            │
│  └─ Modules: rds/, s3/, dynamodb/, iam/, vpc/, security_groups/           │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### Database Tier (Phase 2)

```
┌─────────────────────────────────────────────┐
│  RDS PostgreSQL 15                          │
├─────────────────────────────────────────────┤
│ Instance:     foretale-dev-postgres         │
│ Class:        db.t3.micro                   │
│ Storage:      20 GB (gp2)                   │
│ IOPS:         Variable (burstable)          │
│ Backups:      7-day retention               │
│ Multi-AZ:     No                            │
│ Endpoint:     foretale-dev-postgres.        │
│               cny6oww6atkz.us-east-2.       │
│               rds.amazonaws.com:5432        │
│ Database:     foretaledb                    │
│ Admin User:   foretaleadmin                 │
│ Port:         5432 (TCP)                    │
│ Monitoring:   60-second intervals           │
│ Performance Insights: Enabled                │
│ Query Monitor: pg_stat_statements           │
│                                             │
│ Located in: Database Subnet Group           │
│ Subnets: 3x Availability Zones              │
│ Security Group: sg-098c140212053013a        │
└─────────────────────────────────────────────┘
         │
         │ Stores credentials securely
         ▼
┌─────────────────────────────────────────────┐
│  AWS Secrets Manager                        │
├─────────────────────────────────────────────┤
│ Secret Name:  foretale-dev-db-credentials   │
│ Type:         Database Credentials (JSON)   │
│ Version:      terraform-20260121...         │
│ Contents:                                   │
│ {                                           │
│   "host": "foretale-dev-postgres...",      │
│   "port": 5432,                             │
│   "username": "foretaleadmin",             │
│   "password": "[encrypted]",               │
│   "dbname": "foretaledb",                   │
│   "engine": "postgres"                      │
│ }                                           │
│ Encryption:   AWS-managed keys              │
│ Rotation:     Manual (configurable)         │
│ Access:       IAM + VPC roles               │
└─────────────────────────────────────────────┘
```

### Backup Storage Architecture (Phase 2)

```
┌────────────────────────────────────────────────────────────────┐
│  S3 Backups Bucket (foretale-dev-backups)                      │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LIFECYCLE TRANSITION POLICY: archive-backups                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                                                        │    │
│  │  Upload  ──[30 days]──►  STANDARD_IA  ─[60 days]──►   │    │
│  │ (DAY 0)                                                │    │
│  │  STANDARD               (Warm, frequent access)        │    │
│  │ (Hot, active)                                          │    │
│  │                                         │              │    │
│  │                         ┌───────────────┘              │    │
│  │                         │                              │    │
│  │                    ┌────▼─────────┐                    │    │
│  │               ┌────┤  GLACIER_IR  ├────┐               │    │
│  │               │    │  (Cool)      │    │               │    │
│  │               │    └──────────────┘    │               │    │
│  │           [90 days]               [90 days]            │    │
│  │               │                        │               │    │
│  │               └────┬─────────────────┬─┘               │    │
│  │                    │                 │                 │    │
│  │           ┌────────▼────────┐        │                 │    │
│  │           │  DEEP_ARCHIVE   │        │                 │    │
│  │           │  (Cold, long-   │        │                 │    │
│  │           │   term archive) │    [DAY 730]             │    │
│  │           └────────┬────────┘        │                 │    │
│  │                    │                 │                 │    │
│  │                    │                 ▼                 │    │
│  │                    │         DELETE / EXPIRATION       │    │
│  │                    │         (Cost Control)            │    │
│  │                    │                                   │    │
│  │  Timeline: Day 0 ──────────► Day 30 ─────────► Day 90  │    │
│  │                  ──► Day 180 ─────────► Day 730 ──────► │    │
│  │                                                        │    │
│  │  Cost Efficiency: 46% → 83% → 96% → 100% savings      │    │
│  │  (vs baseline STANDARD storage)                        │    │
│  │                                                        │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Configuration:                                                │
│  ├─ Versioning: ENABLED (point-in-time recovery)              │
│  ├─ Encryption: AES-256 (SSE-S3)                             │
│  ├─ Public Access: BLOCKED                                    │
│  ├─ Minimum Object Size: 128 KB (for transitions)            │
│  ├─ Expiration: 730 days (2-year retention)                  │
│  └─ Rule Status: Enabled                                      │
│                                                                 │
│  Compliance:                                                   │
│  ✓ 90-day gap between GLACIER_IR and DEEP_ARCHIVE            │
│  ✓ 60-day gap between STANDARD_IA and GLACIER_IR             │
│  ✓ Meets AWS S3 lifecycle policy requirements                │
│                                                                 │
│  Cost Benefits:                                                │
│  • 30-day window: Hot storage for active recovery             │
│  • 30-90 day window: Cost reduction begins (46% savings)      │
│  • 90-180 day window: Archive tier (83% savings)              │
│  • 180-730 day window: Cold storage (96% savings)             │
│  • 730+ days: Automatic deletion (100% savings)               │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### RDS Parameter Group Configuration

```
┌──────────────────────────────────────────────┐
│  Parameter Group: foretale-dev-pg-params     │
├──────────────────────────────────────────────┤
│ Family:       postgres15                     │
│ Type:         DB Parameter Group             │
│ Database:     PostgreSQL 15                  │
│                                              │
│ Parameters:                                  │
│ ┌────────────────────────────────────────┐   │
│ │ Name: shared_preload_libraries         │   │
│ │ Value: pg_stat_statements             │   │
│ │ ApplyMethod: Immediate (for supported) │   │
│ │ Source: User-defined                   │   │
│ │ DataType: list                         │   │
│ │ IsModifiable: true                     │   │
│ │ ModifyStatus: applied                  │   │
│ └────────────────────────────────────────┘   │
│                                              │
│ Functionality:                               │
│ • Monitors SQL query execution statistics    │
│ • Tracks query frequency and performance     │
│ • Enables slow query identification          │
│ • Supports query optimization analysis       │
│ • Essential for production monitoring        │
│                                              │
│ Related Views/Functions:                     │
│ • pg_stat_statements (query statistics)    │
│ • pg_stat_statements_reset() (reset stats) │
│                                              │
└──────────────────────────────────────────────┘
```

---

## Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER (Phase 3+)                 │
│        (Flutter App / Web / API Gateway / Lambda)                │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     │ HTTPS / VPC
                     │
                     ▼
      ┌──────────────────────────────┐
      │   VPC Endpoints / NAT        │
      │   (Private connectivity)     │
      └──────────────┬───────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ▼           ▼           ▼
    ┌────────┐  ┌────────┐  ┌────────────┐
    │ Lambda │  │  ECS   │  │ DynamoDB   │
    │        │  │ Tasks  │  │ Cache      │
    └───┬────┘  └────┬───┘  │ Sessions   │
        │            │      │ AI State   │
        │            │      └────────────┘
        │            │
        │ (VPC Security Group)
        │            │
        │            ▼
        │    ┌──────────────┐
        │    │ S3 Endpoints │
        │    │ (VPC EP)     │
        │    └──────┬───────┘
        │           │
        │           ▼
        │    ┌────────────────────────┐
        │    │ S3 Buckets             │
        │    │ - app-storage          │
        │    │ - user-uploads         │
        │    │ - analytics            │
        │    │ - backups (lifecycle)  │◄──── Automated Backups
        │    └────────────────────────┘    (If configured)
        │
        │
        └────────────┬───────────────────┐
                     │                   │
                     ▼                   ▼
        ┌──────────────────┐   ┌──────────────────┐
        │  RDS PostgreSQL  │   │ Secrets Manager  │
        │  - foretaledb    │◄──┤ DB Credentials   │
        │  - Performance   │   │ (Encrypted)      │
        │    Insights ON   │   └──────────────────┘
        │  - Monitoring ON │
        │  - Backups: 7d   │
        │  - Port: 5432    │
        │                  │
        │  Query Stats:    │
        │  pg_stat_        │
        │  statements      │
        │  (monitoring)    │
        └──────────────────┘
             │
             │ Database Backups
             │ (RDS Snapshot)
             │
             ▼
        ┌──────────────────┐
        │ AWS Backup       │
        │ Service          │
        │ (optional)       │
        └──────────────────┘
```

---

## Deployment Timeline

```
PHASE 1: January 20, 2026
├─ VPC with 9 subnets (3x public, 3x private, 3x database)
├─ NAT Gateway + Internet Gateway
├─ 5 DynamoDB Tables
├─ 4 S3 Buckets (with versioning & encryption)
├─ 6 Security Groups
├─ 7 IAM Roles & Policies
└─ Terraform State: ~55 resources

PHASE 2: January 21, 2026
├─ RDS PostgreSQL 15 (foretale-dev-postgres)
│  └─ Database: foretaledb, Admin: foretaleadmin
│
├─ Secrets Manager: foretale-dev-db-credentials
│  └─ Version: terraform-20260121001420907700000001
│
├─ RDS Parameter Group: foretale-dev-pg-params
│  └─ pg_stat_statements enabled
│
├─ S3 Lifecycle Configuration (foretale-dev-backups)
│  └─ Tiered storage: 30/90/180/730 days
│
└─ Terraform State: +10 resources (Total: 65+)

PHASE 3: TBD
├─ Lambda functions integration
├─ ECS container deployment
├─ API Gateway configuration
├─ Application initialization
└─ Performance tuning
```

---

## Resource Tags (Applied Across Phase 1 & 2)

```
Standard Tags Applied to All Resources:
├─ Environment: dev (foretale-dev-*)
├─ Project: foretale
├─ Owner: DevOps Team
├─ CostCenter: Engineering
├─ Compliance: None (development environment)
└─ Creation: Terraform-managed
```

---

## Security Architecture

```
NETWORK LAYER:
├─ VPC (10.0.0.0/16) - Isolated network
├─ Private Subnets - RDS, Lambda, ECS
├─ Public Subnets - NAT Gateway, ALB
├─ VPC Endpoints - S3, Secrets Manager (private access)
└─ Security Groups - RDS (port 5432), Lambda, ECS, ALB, AI Server

DATA ENCRYPTION:
├─ S3 at Rest: AES-256 (SSE-S3)
├─ Secrets Manager: AWS-managed keys
├─ RDS Backups: Encrypted by default
├─ Data in Transit: HTTPS/TLS (recommended for app)
└─ SSL/TLS for DB: Configurable (Phase 3)

IAM & ACCESS CONTROL:
├─ RDS Monitoring Role: CloudWatch metrics
├─ ECS Task Role: Container permissions
├─ Lambda Role: VPC + RDS access
├─ Amplify Role: Backend deployment
├─ AI Server Role: EC2 instance permissions
└─ Secret Access: IAM-enforced via roles
```

---

## Monitoring & Alerts Setup

```
CLOUDWATCH METRICS (Automated):
├─ RDS CPU Utilization (1-minute intervals)
├─ RDS Storage Space Used
├─ RDS Database Connections
├─ RDS Read/Write Operations
├─ RDS Backup Storage
├─ RDS Replication Lag
├─ Performance Insights (top sessions, SQL text)
└─ CloudWatch Logs (RDS, Lambda, ECS)

RECOMMENDED ALARMS (To Configure):
├─ RDS CPU > 70% for 5 minutes
├─ RDS Free Storage < 2GB
├─ RDS Connection Count > 100
├─ RDS Replication Lag > 10 seconds
├─ DynamoDB Throttling
├─ Lambda Error Rate > 1%
└─ S3 Bucket Size Growth

QUERY PERFORMANCE (PostgreSQL):
├─ pg_stat_statements view
├─ Slow query logs
├─ Query execution plans (EXPLAIN)
└─ Index usage statistics
```

---

## Cost Optimization Summary

| Service | Instance | Monthly Est. | Optimization |
|---------|----------|-------------|--------------|
| RDS | db.t3.micro (20GB) | $20-25 | Burstable, good for dev/test |
| RDS Storage | 20GB | $2-3 | Auto-scaling enabled |
| RDS Backup | 7-day retention | $3-5 | Standard retention |
| S3 Standard | Hot storage | Variable | Tiered lifecycle |
| S3 Lifecycle | STANDARD_IA | -46% vs STANDARD | Infrequent access tier |
| S3 Lifecycle | GLACIER_IR | -83% vs STANDARD | Archive tier |
| S3 Lifecycle | DEEP_ARCHIVE | -96% vs STANDARD | Long-term archive |
| DynamoDB | On-demand | Variable | Pay per read/write |
| Secrets Manager | 1 secret | $0.40 | Simple credential storage |
| **Total** | **Phase 2 Base** | **~$25-35/month** | **+lifecycle savings** |

**S3 Backup Storage Savings:** With 100GB of backups, lifecycle policy saves ~$19/month (82% reduction).

---

This architecture diagram represents the complete Foretale AWS infrastructure after Phase 2 deployment completion. All resources are Terraform-managed and production-ready for Phase 3 application integration.

