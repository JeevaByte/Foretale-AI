# ForeTale Application - Cloud Architecture Documentation

## 🏗️ Application Component Analysis

### Overview
ForeTale is a comprehensive Flutter-based web application designed for project management, testing, AI-assisted analysis, and reporting. This document outlines all components for cloud deployment architecture design.

---

## 1. FRONTEND LAYER

### Flutter Web Application
- **Framework**: Flutter (Dart SDK >=3.4.4)
- **Deployment Target**: AWS Amplify Hosting
- **Build Output**: Web (build/web/)

#### Key Features
- Multi-screen application architecture
- Responsive UI with Syncfusion components (DataGrid, Charts)
- PDF/Excel generation & export capabilities
- Real-time WebSocket communication
- File upload/download management
- Code editor with syntax highlighting

#### Main Screens
```
├── Landing & Splash
├── Project Management (Selection, Creation, Settings)
├── Test Management (Creation, Execution, Results)
├── Data Upload & Processing
├── Inquiry Management
├── AI Assistant (Agentic AI)
├── Analysis & Reports
├── Storyboard
└── Help & Resources
```

---

## 2. AUTHENTICATION & AUTHORIZATION

### AWS Cognito User Pool
- **Pool Name**: `foretaleapplicationef550e90`
- **Authentication Method**: Email-based
- **Service**: AWS Cognito via Amplify

#### Configuration
```json
{
  "mfaConfiguration": "OFF",
  "mfaTypes": ["SMS"],
  "passwordProtectionSettings": {
    "passwordPolicyMinLength": 8
  },
  "signupAttributes": ["EMAIL"],
  "verificationMechanisms": ["EMAIL"]
}
```

#### User Attributes
- Email (required)
- Name (custom attribute)
- Password (min 8 characters)

---

## 3. BACKEND SERVICES

### A. API Layer (AWS API Gateway)

#### 1. Database API
**Endpoint**: `https://uq56kj6m5f.execute-api.us-east-1.amazonaws.com/dev`

**Operations**:
- `POST /insert_record` - Create records
- `PUT /update_record` - Update records
- `DELETE /delete_record` - Delete records
- `GET /read_record` - Read records
- `GET /read_json_record` - Read JSON-formatted records

**Architecture**: API Gateway → Lambda → RDS (stored procedures)

#### 2. ECS Invoker API
**Endpoint**: `https://itpkscu97c.execute-api.us-east-1.amazonaws.com/dev/ecs_invoker_resource`

**Purpose**: Trigger long-running ECS tasks dynamically
- CSV data processing
- Test execution workflows
- Background job orchestration

---

### B. Compute Services (AWS ECS Fargate)

#### 1. CSV Upload Processing Cluster
```
Cluster Name: cluster-uploads
Task Definition: td-csv-upload
Container: con-csv-upload
Runtime: Python 3.12
Application: /opt/python/initiate-data-upload-process/app.py
```

**Purpose**: Process uploaded CSV files, validate data, and import to database

#### 2. Test Execution Cluster
```
Cluster Name: cluster-execute
Task Definition: td-db-process
Container: con-db-process
Runtime: Python 3.12
Application: /opt/python/invoke-db-process/app.py
```

**Purpose**: Execute automated tests and database processing tasks

---

### C. AI/ML Services

#### AI Assistant (WebSocket-based)
**Endpoint**: `ws://54.209.170.16:8002/ws`

**Configuration**:
```dart
Host: 54.209.170.16:8002
Protocol: WebSocket
Path: /ws
Session-based: Yes (session_id parameter)
```

**Features**:
- Real-time streaming conversations
- Session persistence
- Agentic AI capabilities
- Message event streaming

**Possible Implementation**:
- AWS Bedrock (Claude/Titan models)
- Self-hosted AI model on EC2
- Lambda with streaming response

---

## 4. STORAGE LAYER

### A. Object Storage (AWS S3)

#### S3 Bucket Configuration
**Bucket Name**: `foretaleresources` (managed by Amplify)

**Directory Structure**:
```
public/
├── inquiry/          # Question and inquiry attachments
├── test/             # Test-related files and attachments
└── feedback/         # User feedback attachments
```

**Operations**:
- Upload files (images, PDFs, CSV, Excel)
- Download/retrieve files
- List bucket contents
- Delete files

**Access**: Via Amplify Storage S3 plugin with Cognito credentials

---

### B. Relational Database (AWS RDS)

**Access Pattern**: API Gateway → Lambda → RDS
**Interface**: Stored procedures for all CRUD operations

#### Data Models (25+ Entities)

**Core Business Entities**:
- `project_details` - Project information
- `project_settings` - Project configurations
- `project_type_list` - Project categorization
- `tests_model` - Test definitions
- `create_test_model` - Test creation metadata
- `inquiry_question_model` - Inquiry questions
- `inquiry_response_model` - Inquiry responses
- `inquiry_attachment_model` - Inquiry file attachments
- `report_model` - Report definitions
- `result_model` - Test/analysis results
- `data_assessment_model` - Data quality assessments

**User & Organization**:
- `user_details_model` - User profiles
- `client_contacts_model` - Client information
- `team_contacts_model` - Team member details
- `organization_list_model` - Organization registry

**AI & Analysis**:
- `ai_assistant_model` - AI assistant configurations
- `ai_session_model` - AI conversation sessions
- `question_model` - Question bank
- `chart_metadata_model` - Chart configurations

**Reference Data**:
- `category_list_model` - Category taxonomy
- `industry_list_model` - Industry classifications
- `topic_list_model` - Topic management
- `modules_list_model` - Module definitions
- `columns_model` - Dynamic column configurations
- `file_upload_summary_model` - Upload tracking

---

## 5. KEY DEPENDENCIES & INTEGRATIONS

### AWS Services
```yaml
amplify_flutter: ^2.6.0
amplify_authenticator: ^2.3.2
amplify_auth_cognito: ^2.6.0
amplify_storage_s3: ^2.6.0
```

### State Management
```yaml
provider: ^6.0.1
shared_preferences: ^2.3.3
```

### HTTP & Real-time Communication
```yaml
http: ^1.2.2
web_socket_channel: ^3.0.0
```

### UI Components
```yaml
syncfusion_flutter_core: ^30.2.7
syncfusion_flutter_datagrid: ^30.2.7
syncfusion_flutter_charts: ^30.2.7
google_fonts: ^6.2.1
fl_chart: ^0.68.0
```

### File Handling
```yaml
file_picker: ^10.3.0
image_picker: ^1.1.2
path_provider: ^2.1.1
```

### Data Processing & Export
```yaml
csv: ^6.0.0
excel: ^4.0.6
pdf: ^3.11.1
printing: ^5.13.3
flutter_html_to_pdf: ^0.7.0
```

### Code Display & Editing
```yaml
flutter_code_editor: ^0.3.0
code_text_field: ^1.1.0
flutter_highlight: ^0.7.0
highlight: ^0.7.0
```

### Utilities
```yaml
uuid: ^4.3.3
intl: ^0.20.2
markdown: ^7.0.0
html_unescape: ^2.0.0
dropdown_search: ^5.0.0
```

### External Resources
- **Documentation**: `https://foretale-revolutionizing-x5v0nb0.gamma.site/`

---

## 6. CLOUD ARCHITECTURE DESIGN

### Recommended AWS Architecture (us-east-2 Deployment)

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER LAYER                                  │
│  Web Browsers (Desktop, Mobile, Tablet)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  TIER 1: CDN & HOSTING                          │
│  ┌──────────────────┐         ┌──────────────────┐            │
│  │  CloudFront CDN  │────────▶│ Amplify Hosting  │            │
│  │  (Global Edge)   │         │ (Flutter Web)    │            │
│  └──────────────────┘         └──────────────────┘            │
│           │                            │                        │
│           │                            ▼                        │
│           │                   ┌──────────────────┐            │
│           └──────────────────▶│  S3 Static Web   │            │
│                               │  (build/web/)    │            │
│                               └──────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              TIER 2: SECURITY & IDENTITY                        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │  AWS WAF     │    │ AWS Cognito  │    │ AWS Shield   │    │
│  │  (Firewall)  │    │  User Pool   │    │   (DDoS)     │    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│           TIER 3: API GATEWAY & LOAD BALANCING                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │             AWS API Gateway (REST + WebSocket)           │  │
│  ├─────────────────────┬────────────────────────────────────┤  │
│  │   Database API      │  ECS Invoker API  │  WebSocket API│  │
│  │   (CRUD Operations) │  (Task Trigger)   │  (AI Chat)    │  │
│  └─────────────────────┴────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                │                       │                │
                ▼                       ▼                ▼
┌───────────────────────┐  ┌──────────────────┐  ┌─────────────────┐
│   TIER 4: COMPUTE     │  │  TIER 4: COMPUTE │  │ TIER 4: AI/ML   │
│  ┌─────────────────┐  │  │ ┌──────────────┐ │  │ ┌─────────────┐ │
│  │ Lambda Functions│  │  │ │ ECS Fargate  │ │  │ │AWS Bedrock  │ │
│  │ ─ DB Proxy      │  │  │ │ Clusters:    │ │  │ │   OR        │ │
│  │ ─ Auth Handler  │  │  │ │ ─ CSV Upload │ │  │ │EC2 Instance │ │
│  │ ─ File Processor│  │  │ │ ─ Test Exec  │ │  │ │(WebSocket)  │ │
│  └─────────────────┘  │  │ └──────────────┘ │  │ └─────────────┘ │
└───────────────────────┘  └──────────────────┘  └─────────────────┘
                │                       │                │
                └───────────┬───────────┴────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                  TIER 5: DATA LAYER                             │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │   Amazon RDS     │    │   Amazon S3      │                  │
│  │   ─ PostgreSQL   │    │   ─ foretale     │                  │
│  │      OR MySQL    │    │     resources    │                  │
│  │   ─ Multi-AZ     │    │   ─ Versioning   │                  │
│  │   ─ Encrypted    │    │   ─ Lifecycle    │                  │
│  └──────────────────┘    └──────────────────┘                  │
│           │                        │                             │
│           ▼                        ▼                             │
│  ┌──────────────────┐    ┌──────────────────┐                  │
│  │  RDS Read Replica│    │   S3 Glacier     │                  │
│  │  (Scaling)       │    │   (Archive)      │                  │
│  └──────────────────┘    └──────────────────┘                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              TIER 6: SUPPORTING SERVICES                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │
│  │ CloudWatch │  │  Secrets   │  │  AWS KMS   │  │   VPC    │ │
│  │  Logging   │  │  Manager   │  │ Encryption │  │ Subnets  │ │
│  │  Metrics   │  │  (Creds)   │  │            │  │ Security │ │
│  │  Alarms    │  │            │  │            │  │  Groups  │ │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │
│  │ CloudTrail │  │  IAM Roles │  │  SNS/SES   │  │Backup DR │ │
│  │  (Audit)   │  │  Policies  │  │(Notif/Mail)│  │          │ │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. DATA FLOW PATTERNS

### 1. User Authentication Flow
```
User → CloudFront → Amplify App → AWS Cognito
  ↓
JWT Token Generated
  ↓
Stored in Client (SharedPreferences)
  ↓
Used for all API calls (Authorization header)
```

### 2. CRUD Operations Flow
```
Flutter App → API Gateway (REST)
  ↓
Lambda Function (DB Proxy)
  ↓
RDS Database (Stored Procedures)
  ↓
Response → Lambda → API Gateway → App
```

### 3. File Upload Flow
```
User selects file (File Picker)
  ↓
Flutter App → Amplify Storage S3
  ↓
Direct upload to S3 bucket
  ↓
S3 Event (optional) → Lambda → Update DB
  ↓
Success response to App
```

### 4. CSV Processing Flow
```
User uploads CSV → S3
  ↓
App → API Gateway → ECS Invoker
  ↓
ECS Fargate Task (cluster-uploads)
  ↓
Python app processes CSV
  ↓
Validates & imports to RDS
  ↓
Updates file_upload_summary
  ↓
Response to App
```

### 5. Test Execution Flow
```
User initiates test → App → API Gateway
  ↓
ECS Invoker API triggers task
  ↓
ECS Fargate (cluster-execute)
  ↓
Python app runs test logic
  ↓
Stores results in RDS
  ↓
App polls for status/results
```

### 6. AI Chat Flow (WebSocket)
```
User message → WebSocket connection
  ↓
ws://54.209.170.16:8002/ws?session_id=xxx
  ↓
AI Server (Bedrock/EC2)
  ↓
Streaming response chunks
  ↓
Real-time display in App
```

### 7. Report Generation Flow
```
User requests report → App → API Gateway
  ↓
Lambda fetches data from RDS
  ↓
Generates PDF/Excel (in-app or Lambda)
  ↓
Returns binary data or S3 link
  ↓
User downloads report
```

---

## 8. DEPLOYMENT STRATEGY

### Current Configuration
- **Region**: us-east-1 (primary APIs, databases)
- **WebSocket**: EC2 at 54.209.170.16
- **Hosting**: Amplify (auto-deployed from Git)

### Recommended Migration to us-east-2

#### Phase 1: Infrastructure Setup
1. Create VPC with public/private subnets
2. Set up RDS instance (Multi-AZ)
3. Create S3 bucket with versioning
4. Configure Cognito User Pool
5. Set up KMS keys for encryption

#### Phase 2: Application Services
1. Deploy Lambda functions
2. Create ECS clusters and task definitions
3. Configure API Gateway endpoints
4. Set up CloudFront distribution
5. Configure Amplify hosting

#### Phase 3: Migration
1. Database migration (snapshot → restore)
2. S3 data replication
3. Update application configuration files
4. DNS/endpoint updates
5. Testing and validation

#### Phase 4: Optimization
1. Enable CloudWatch monitoring
2. Configure auto-scaling policies
3. Set up backup and DR
4. Implement cost optimization
5. Security hardening

---

## 9. CONFIGURATION FILES TO UPDATE FOR DEPLOYMENT

### For us-east-2 Deployment, update:

#### 1. lib/config/config_db_api.dart
```dart
class DatabaseApiConfig {
  static String baseApIUrl = "https://<NEW_API_ID>.execute-api.us-east-2.amazonaws.com/prod";
}
```

#### 2. lib/config/config_ecs.dart
```dart
class CsvUploadECS {
  static const String url = 'https://<NEW_API_ID>.execute-api.us-east-2.amazonaws.com/prod/ecs_invoker_resource';
  static const String clusterName = 'cluster-uploads-prod';
  static const String taskDefinition = 'td-csv-upload-prod';
  // ... other configs
}
```

#### 3. lib/ui/widgets/ai_box/config/config.dart
```dart
class AgenticAIConfig {
  static const String defaultHost = '<NEW_LOAD_BALANCER_DNS>:8002';
  // OR
  // static const String defaultHost = '<API_GATEWAY_WEBSOCKET_URL>';
}
```

#### 4. amplify/backend/backend-config.json
- Update Cognito pool region
- Update S3 bucket region
- Update all resource ARNs

---

## 10. SECURITY CONSIDERATIONS

### Authentication & Authorization
- ✅ AWS Cognito for user management
- ✅ JWT tokens for API authentication
- ✅ MFA support available
- ⚠️ Implement fine-grained IAM policies

### Data Protection
- ✅ S3 bucket encryption
- ✅ RDS encryption at rest (via KMS)
- ⚠️ Enable SSL/TLS for all API calls
- ⚠️ Implement data classification

### Network Security
- ⚠️ Deploy RDS in private subnets
- ⚠️ Configure Security Groups restrictively
- ⚠️ Implement WAF rules for API Gateway
- ⚠️ Enable VPC Flow Logs

### Application Security
- ⚠️ Validate all user inputs
- ⚠️ Implement rate limiting
- ⚠️ Regular security scanning
- ⚠️ Secrets management via AWS Secrets Manager

---

## 11. COST OPTIMIZATION RECOMMENDATIONS

### Compute
- Use Lambda for sporadic workloads
- ECS Fargate Spot for batch processing
- Right-size ECS tasks based on metrics

### Storage
- S3 Intelligent-Tiering for older files
- RDS instance right-sizing
- Enable S3 lifecycle policies

### Network
- CloudFront caching for static assets
- VPC endpoints for AWS service access
- Consolidate regions to reduce data transfer

### Monitoring
- CloudWatch Logs retention policies
- Use CloudWatch Insights for querying
- Set up budget alerts

---

## 12. HIGH AVAILABILITY & DISASTER RECOVERY

### High Availability
- Multi-AZ RDS deployment
- ECS tasks across multiple AZs
- S3 cross-region replication (optional)
- CloudFront global distribution

### Disaster Recovery
- RDS automated backups (7-35 days)
- S3 versioning enabled
- Regular infrastructure snapshots
- Documented recovery procedures

### Backup Strategy
- **RTO Target**: < 4 hours
- **RPO Target**: < 1 hour
- **Backup Frequency**: Daily automated
- **Backup Retention**: 30 days minimum

---

## 13. MONITORING & OBSERVABILITY

### Key Metrics to Monitor
```
Application Layer:
├── API Gateway: Request count, latency, errors
├── Lambda: Invocations, duration, errors, throttles
├── ECS: CPU, memory, task count
└── Amplify: Build success rate, deployment time

Data Layer:
├── RDS: Connections, CPU, storage, IOPS
├── S3: Requests, data transfer, storage
└── ElastiCache (if used): Hit rate, evictions

Infrastructure:
├── CloudWatch: Log volume, alarm states
├── CloudTrail: API activity, security events
└── Cost Explorer: Daily/monthly spend
```

### Alerting Strategy
- Critical: Database unavailability, API errors > 5%
- Warning: High CPU/memory, increased latency
- Info: Deployment completion, backup success

---

## 14. CI/CD PIPELINE RECOMMENDATIONS

### Using AWS Amplify (Current)
```yaml
# amplify.yml already configured
version: 1
backend:
  phases:
    build:
      commands:
        - amplifyPush --simple
frontend:
  phases:
    preBuild:
      commands:
        - flutter pub get
    build:
      commands:
        - flutter build web --release
```

### Alternative: GitHub Actions + Terraform
```
GitHub Push → Actions Workflow
  ↓
1. Run tests (flutter test)
2. Build app (flutter build web)
3. Terraform plan (infrastructure)
4. Manual approval (optional)
5. Terraform apply
6. Deploy to S3
7. Invalidate CloudFront cache
8. Run smoke tests
9. Notify team
```

---

## 15. NEXT STEPS FOR DEPLOYMENT

### Immediate Actions
1. ✅ Review and validate architecture diagram
2. 🔲 Create Terraform modules for us-east-2
3. 🔲 Set up CI/CD pipeline
4. 🔲 Create environment-specific configuration files
5. 🔲 Document secrets and credentials

### Short-term (1-2 weeks)
1. Deploy infrastructure to us-east-2
2. Migrate database schema and data
3. Update application configuration
4. Deploy application to Amplify
5. Comprehensive testing

### Medium-term (1 month)
1. Enable monitoring and alerting
2. Implement backup and DR procedures
3. Security hardening and compliance
4. Performance optimization
5. Documentation updates

### Long-term (2-3 months)
1. Multi-region deployment (if needed)
2. Advanced features (caching, CDN optimization)
3. Cost optimization review
4. Capacity planning
5. Continuous improvement

---

## 16. CONTACT & SUPPORT

### Documentation Resources
- **AWS Amplify**: https://docs.amplify.aws/
- **Flutter**: https://flutter.dev/docs
- **Terraform AWS**: https://registry.terraform.io/providers/hashicorp/aws/

### Project-Specific
- **ForeTale Resources**: https://foretale-revolutionizing-x5v0nb0.gamma.site/

---

## Appendix A: Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter Web | UI/UX, cross-platform |
| **Hosting** | AWS Amplify | Static web hosting, CI/CD |
| **CDN** | CloudFront | Content delivery |
| **Auth** | AWS Cognito | User authentication |
| **API** | API Gateway | RESTful APIs, WebSocket |
| **Compute** | Lambda + ECS | Serverless + containers |
| **AI/ML** | Bedrock/EC2 | AI assistant, ML models |
| **Database** | RDS | Relational data storage |
| **Storage** | S3 | Object/file storage |
| **Security** | KMS, WAF, Shield | Encryption, firewall, DDoS |
| **Monitoring** | CloudWatch | Logs, metrics, alarms |
| **IaC** | Terraform | Infrastructure as code |

---

## 16. PHASE 3: APPLICATION LAYER DEPLOYMENT

### Phase 3 Overview
Phase 3 implements the complete **Application Layer** connecting the Flutter frontend to Phase 2 infrastructure (RDS, S3, DynamoDB) using API Gateway, Lambda, and EKS.

### Phase 3 Components

#### A. API Gateway (REST API)
- **Deployment**: `module.api_gateway` in `terraform/modules/api-gateway/`
- **Authorization**: Cognito User Pool authorizer
- **Endpoints** (6 total):
  - `POST /insert_record` - Insert records (Lambda proxy)
  - `PUT /update_record` - Update records (Lambda proxy)
  - `DELETE /delete_record` - Delete records (Lambda proxy)
  - `GET /read_record` - Read record (Lambda proxy)
  - `GET /read_json_record` - Read JSON (Lambda proxy)
  - `POST /ecs_invoker_resource` - Trigger ECS tasks (Lambda proxy)
- **Features**: CloudWatch logging, request validation, CORS
- **Output**: API invoke URL, endpoint URLs for integration

#### B. Lambda Functions (6 Serverless Compute Functions)
- **Deployment**: `module.lambda` in `terraform/modules/lambda/`
- **Functions**:
  1. `foretale-dev-insert-record` - Database INSERT proxy (512 MB, 60s)
  2. `foretale-dev-update-record` - Database UPDATE proxy (512 MB, 60s)
  3. `foretale-dev-delete-record` - Database DELETE proxy (512 MB, 60s)
  4. `foretale-dev-read-record` - Database SELECT proxy (512 MB, 60s)
  5. `foretale-dev-read-json-record` - JSON response proxy (512 MB, 60s)
  6. `foretale-dev-ecs-invoker` - ECS task trigger (256 MB, 60s)
- **Runtime**: Python 3.12
- **VPC**: Private subnets with Lambda security group for RDS access
- **Environment**: RDS endpoint, port, database, credentials, ECS clusters
- **Logging**: CloudWatch Log Group `/aws/lambda/foretale-dev`

#### C. EKS Cluster (Kubernetes Container Orchestration)
- **Deployment**: `module.eks` in `terraform/modules/eks/`
- **Cluster**: `foretale-dev-eks-cluster` v1.29
- **Region**: us-east-2
- **Node Group**: `foretale-dev-node-group`
  - Instance Type: t3.medium (configurable)
  - Replicas: 2 desired, 1-4 autoscaling
  - Auto-scaling enabled with CloudWatch metrics
- **Features**:
  - OIDC provider for IAM Roles for Service Accounts (IRSA)
  - Pod execution IAM role with RDS/Secrets Manager access
  - CloudWatch Container Insights logging
  - Security groups for cluster control plane and worker nodes
  - RDS security group ingress from pod SG on port 5432
- **Networking**: Private subnets with NAT Gateway for external access

#### D. Kubernetes Manifests & Workloads
- **Location**: `kubernetes/` directory with 5 manifest files
- **ConfigMap** (`01-configmap.yaml`):
  - RDS endpoint, port, database, username
  - AWS region and environment
  - S3 bucket names (4 buckets)
  - DynamoDB table names (5 tables)
  - Application configuration
- **Secrets & ServiceAccount** (`02-secret-and-serviceaccount.yaml`):
  - Database credentials (from Secrets Manager)
  - IRSA ServiceAccount for pod IAM access
  - Annotation: `role-arn: arn:aws:iam::ACCOUNT_ID:role/foretale-dev-eks-pod-execution-role`
- **CSV Processor Deployment** (`03-csv-processor-deployment.yaml`):
  - 2 replicas, rolling update strategy
  - Container image: `ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/foretale-csv-processor:latest`
  - Port: 8000
  - Resources: 256 Mi memory, 250m CPU (requests), 512 Mi, 500m (limits)
  - Health probes: Liveness (30s), Readiness (10s)
  - Pod anti-affinity for high availability
  - Service: ClusterIP on port 8000
- **Test Executor Deployment** (`04-test-executor-deployment.yaml`):
  - 2 replicas, rolling update strategy
  - Container image: `ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/foretale-test-executor:latest`
  - Port: 8001
  - Resources: 512 Mi memory, 500m CPU (requests), 1 Gi, 1000m (limits)
  - Health probes: Liveness (30s), Readiness (10s)
  - Pod anti-affinity for high availability
  - Service: ClusterIP on port 8001
- **Ingress & Network Policy** (`05-ingress-and-network-policy.yaml`):
  - Ingress: `foretale-api-ingress` with TLS termination
  - Routes:
    - `/csv-processor` → `csv-processor-svc:8000`
    - `/test-executor` → `test-executor-svc:8001`
  - NetworkPolicy: Deny by default, allow:
    - DNS (port 53/UDP)
    - RDS (port 5432/TCP)
    - HTTPS (port 443/TCP)
    - Inter-pod (ports 8000-8001/TCP)

### Phase 3 Infrastructure as Code Summary

**Terraform Plan**: 44 resources to add, 1 to change
- Lambda: 7 resources (6 functions + log group)
- API Gateway: 20 resources (REST API, methods, integrations, permissions, etc.)
- EKS: 12 resources (cluster, node group, IAM roles, security groups, OIDC, logs)
- RDS Modification: 1 (security group ingress from EKS nodes)

**Total Phase 3**: 45 resources (new + modified)

### Phase 3 Deployment Architecture

```
┌───────────────────────────────────────────────────────────────────┐
│                        PHASE 3 ARCHITECTURE                       │
│                                                                   │
│  Flutter Web App (Amplify Hosting)                               │
│         │                                                         │
│         ▼                                                         │
│  ┌─────────────────────────────────────────┐                    │
│  │  AWS API Gateway (REST + Cognito Auth)  │                    │
│  │  Invoke URL: https://<api>.execute...   │                    │
│  └──────┬────────────────────────┬─────────┘                    │
│         │                        │                               │
│    ┌────▼────┐            ┌──────▼──────┐                       │
│    │ Lambda  │            │ Lambda      │                       │
│    │ (CRUD)  │            │ (ECS Invoke)│                       │
│    │ 5 Funcs │            │ 1 Func      │                       │
│    └────┬────┘            └──────┬──────┘                       │
│         │                        │                               │
│         │                        ▼                               │
│         │                 ┌────────────────┐                    │
│         │                 │ ECS Clusters   │                    │
│         │                 │ (Phase 2)      │                    │
│         │                 └────────────────┘                    │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────┐                   │
│  │    EKS Cluster (foretale-dev-eks)       │                   │
│  │    │                                     │                   │
│  │    ├─ CSV Processor (Deployment, 2x)     │                   │
│  │    │  Port 8000 → csv-processor-svc     │                   │
│  │    │  Memory: 256-512 Mi                 │                   │
│  │    │                                     │                   │
│  │    ├─ Test Executor (Deployment, 2x)     │                   │
│  │    │  Port 8001 → test-executor-svc     │                   │
│  │    │  Memory: 512-1024 Mi                │                   │
│  │    │                                     │                   │
│  │    └─ Ingress + Network Policy           │                   │
│  │       Routes: /csv-processor, /test-... │                   │
│  │                                          │                   │
│  │    Node Group: t3.medium (2-4 nodes)    │                   │
│  │    OIDC: Pod IAM role for RDS access    │                   │
│  └──────┬────────────────────────────────────┘                  │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────┐                   │
│  │    Phase 2: RDS + S3 + DynamoDB         │                   │
│  │    (Database, Storage, Cache)           │                   │
│  └─────────────────────────────────────────┘                   │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

### Phase 3 Deployment Instructions

See detailed deployment guide: `terraform/PHASE3_DEPLOYMENT_SUMMARY.md`

**Quick Deploy**:
```bash
cd terraform/

# Update Cognito pool ARN
vim terraform.tfvars

# Validate and plan
terraform init
terraform validate
terraform plan -out=phase3.tfplan

# Apply Phase 3
terraform apply phase3.tfplan

# Retrieve outputs
terraform output -json > phase3-outputs.json

# Configure kubectl
aws eks update-kubeconfig --name foretale-dev-eks-cluster --region us-east-2

# Apply Kubernetes manifests
kubectl apply -f ../kubernetes/
```

### Phase 3 Cost Estimation

**Monthly Costs (us-east-2, development)**:
- API Gateway: $3.50
- Lambda (6 functions): $15.00
- EKS Control Plane: $73.00
- EC2 (t3.medium × 2): $35.00
- CloudWatch Logs: $5.00
- NAT Gateway: $32.00
- **Subtotal Phase 3**: ~$165/month
- Phase 1-2 (RDS, S3, DynamoDB): ~$50/month
- **Total**: ~$215/month

### Phase 3 Post-Deployment Checklist

- [ ] Terraform plan shows 44 resources to add
- [ ] terraform validate returns "Success!"
- [ ] terraform apply completes without errors
- [ ] EKS cluster accessible via `kubectl get nodes`
- [ ] Kubernetes pods running: `kubectl get pods -A`
- [ ] Lambda functions invocable via console
- [ ] API Gateway endpoints responding
- [ ] CloudWatch logs ingesting data
- [ ] RDS receives connections from pods
- [ ] SecurityGroups allow pod-to-RDS traffic

### Phase 3 Documentation

- **Deployment Summary**: `terraform/PHASE3_DEPLOYMENT_SUMMARY.md`
- **Quick Reference**: `terraform/PHASE3_QUICK_REFERENCE.md`
- **Architecture Diagram**: This file (section 16)
- **Kubernetes Guide**: `kubernetes/README.md`

---

**Document Version**: 3.0 (Phase 3 Added)  
**Last Updated**: January 20, 2026  
**Target Region**: us-east-2 (Ohio)  
**Environment**: Production-ready architecture with Phase 3 Application Layer

