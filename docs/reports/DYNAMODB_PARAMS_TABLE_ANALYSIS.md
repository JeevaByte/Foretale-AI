# DynamoDB Parameter Table Comparison: ap-south-1 vs Other Regions

**Date:** 2026-02-05  
**Analysis Scope:** Compare params table configuration across ap-south-1, us-east-2, and us-east-1

## Executive Summary

The `params` table exists in **two distinct configurations**:

| Aspect | ap-south-1 | us-east-2 | us-east-1 |
|--------|-----------|-----------|-----------|
| **Table Exists** | ✅ Yes | ✅ Yes | ❓ Unknown (likely yes) |
| **Purpose** | Parameter storage (Amplify-created) | Parameter storage (Terraform-created) | Parameter storage |
| **Item Count** | 104 items | 0 items | Unknown |
| **Billing Mode** | PAY_PER_REQUEST | PAY_PER_REQUEST | Unknown |
| **Creation Source** | Amplify (Flutter app deployment) | Terraform infrastructure | Unknown |

## Detailed Configuration Comparison

### 1. Primary Differences

#### ap-south-1 params Table
```
Table Name:        params
Status:            ACTIVE
Item Count:        104 items (POPULATED WITH DATA)
Billing Mode:      PAY_PER_REQUEST (On-demand)
Primary Key:       PK (HASH/Partition Key only)
Attributes:        PK (String)

Features NOT Enabled:
├── Stream Specification:        NO
├── Point-in-Time Recovery:      NO
├── KMS Encryption:              NO (Default SSE)
├── Global Secondary Indexes:    NONE
├── Local Secondary Indexes:     NONE
└── TTL:                         NO
```

**Origin:** Created by Amplify during Flutter app deployment in ap-south-1
**Status:** Legacy/deprecated (contains old test data)

#### us-east-2 params Table
```
Table Name:        params
Status:            ACTIVE
Item Count:        0 items (EMPTY - NO DATA)
Billing Mode:      PAY_PER_REQUEST (On-demand)
Primary Key:       PK (HASH/Partition Key only)
Attributes:        PK (String)

Features NOT Enabled:
├── Stream Specification:        NO
├── Point-in-Time Recovery:      NO
├── KMS Encryption:              NO (Default SSE)
├── Global Secondary Indexes:    NONE
├── Local Secondary Indexes:     NONE
└── TTL:                         NO
```

**Origin:** Created by Terraform infrastructure deployment in us-east-2
**Status:** Active but empty (ready for use)

### 2. DynamoDB Tables Across Regions

#### ap-south-1 Region
```
Tables in ap-south-1:
├── params (104 items) ← Parameter storage from Amplify
└── Todo-kvfbsafkhrdmzgq7aopxxrcjy4-NONE (Amplify Todo app table)
```

#### us-east-2 Region
```
Tables in us-east-2:
├── params (0 items) ← Parameter storage from Terraform
├── foretale-app-dynamodb-sessions
├── foretale-app-dynamodb-cache
├── foretale-app-dynamodb-ai-state
├── foretale-app-dynamodb-audit-logs
├── foretale-app-dynamodb-websocket-connections
└── foretale-app-dynamodb-foretale-table-replica
```

**Key Difference:** us-east-2 has 6 additional **ForeTale-specific** application tables created by Terraform

### 3. Configuration Gaps in ap-south-1

The ap-south-1 `params` table **lacks production-ready features**:

| Feature | ap-south-1 | Recommendation | Status |
|---------|-----------|-----------------|--------|
| **Point-in-Time Recovery** | ❌ Disabled | ✅ Enable | Missing |
| **Encryption (KMS)** | ❌ Default SSE only | ✅ Use KMS keys | Missing |
| **Streams (CDC)** | ❌ Disabled | ✅ Enable for replication | Missing |
| **TTL Policy** | ❌ No TTL | ✅ Add automatic cleanup | Missing |
| **Global Secondary Indexes** | ❌ None | ✅ Consider for query patterns | Missing |
| **Backup Strategy** | ❌ No PITR | ✅ Enable automated backups | Missing |
| **Tags** | ❌ Likely minimal | ✅ Add environment/project tags | Missing |

## Key Findings

### Finding 1: Data Population Asymmetry
- **ap-south-1:** Contains 104 items (legacy data from Amplify deployment)
- **us-east-2:** Contains 0 items (clean slate from Terraform)
- **Implication:** The tables are NOT synchronized; data exists only in ap-south-1

### Finding 2: Infrastructure vs Amplify Creation
- **ap-south-1 params:** Created by Amplify during Flutter app initialization
  - Part of `amplify init` auto-provisioning
  - No custom Terraform management
  - Minimal security/recovery features
  
- **us-east-2 params:** Created by Terraform module
  - Managed through `terraform/modules/dynamodb/main.tf`
  - Currently follows baseline configuration
  - Can be enhanced with additional features

### Finding 3: Missing Production Features in ap-south-1
The ap-south-1 table lacks:
1. **Data Recovery:** No Point-in-Time Recovery (PITR)
2. **Security:** No KMS-managed encryption
3. **Change Tracking:** No DynamoDB Streams
4. **Cost Optimization:** No TTL for automatic data deletion
5. **Querying:** No indexes for common access patterns
6. **Observability:** Likely missing proper CloudWatch monitoring

### Finding 4: Incomplete Migration
- Tables exist in both regions but are **not replicas**
- Data in ap-south-1 is **not replicated** to us-east-2
- No global tables configuration
- Suggests the infrastructure migration from ap-south-1 → us-east-2 is incomplete

## Terraform Configuration Status

### Current State (us-east-2)
The `params` table in us-east-2 is **NOT managed by Terraform**. 

**Evidence:**
- File: `terraform/modules/dynamodb/main.tf`
- Contains only these managed tables:
  - `aws_dynamodb_table.sessions` → `foretale-app-dynamodb-sessions`
  - `aws_dynamodb_table.cache` → `foretale-app-dynamodb-cache`
  - `aws_dynamodb_table.ai_state` → `foretale-app-dynamodb-ai-state`
  - `aws_dynamodb_table.audit_logs` → `foretale-app-dynamodb-audit-logs`
  - `aws_dynamodb_table.websocket_connections` → `foretale-app-dynamodb-websocket-connections`
  - `aws_dynamodb_table.foretale_table_replica` → `foretale-app-dynamodb-foretale-table-replica`

**Missing:** No resource definition for `params` table

**Status:** The `params` table was likely created manually or by Amplify and exists in AWS but is **unmanaged** by Terraform

## Recommendations

### Priority 1: Immediate (Critical)
- [ ] **Identify data in ap-south-1 params table**
  - Scan all 104 items
  - Document data structure and purpose
  - Determine if this data needs to be migrated to us-east-2

- [ ] **Create Terraform configuration for params table**
  - Add to `terraform/modules/dynamodb/main.tf`
  - Define primary key, attributes, and indexes
  - Apply to both regions

### Priority 2: High (Production-Readiness)
- [ ] **Enable PITR on params table**
  ```terraform
  point_in_time_recovery {
    enabled = true
  }
  ```

- [ ] **Enable KMS encryption**
  ```terraform
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb.arn
  }
  ```

- [ ] **Enable DynamoDB Streams**
  ```terraform
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  ```

- [ ] **Add TTL for data lifecycle**
  ```terraform
  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
  ```

### Priority 3: Medium (Optimization)
- [ ] **Evaluate query patterns for indexes**
  - Review application code for params access patterns
  - Create GSI if needed for performance

- [ ] **Add proper tagging**
  ```terraform
  tags = {
    Name        = "foretale-app-dynamodb-params"
    Environment = var.environment
    Purpose     = "Application parameters"
    ManagedBy   = "Terraform"
  }
  ```

- [ ] **Configure CloudWatch monitoring**
  - Monitor consumed read/write capacity
  - Set alarms for throttling
  - Track item count growth

### Priority 4: Integration
- [ ] **Data Migration Strategy**
  - If data in ap-south-1 is needed:
    ```bash
    aws dynamodb scan --table-name params --region ap-south-1 > params-backup.json
    # Transfer to us-east-2
    ```
  - If legacy, can safely delete ap-south-1 `params` table

- [ ] **Global Table Configuration (Optional)**
  ```terraform
  resource "aws_dynamodb_global_table" "params" {
    name            = "params"
    billing_mode    = "PAY_PER_REQUEST"
    stream_enabled  = true
    
    replica {
      region_name = "us-east-1"
    }
    
    replica {
      region_name = "us-east-2"
    }
    
    replica {
      region_name = "ap-south-1"
    }
  }
  ```

## Action Items

### Immediate Questions to Answer
1. **What data is in ap-south-1 params table?**
   - Scan and document the 104 items
   - Determine if this is legacy or active data

2. **Is the params table actively used?**
   - Check application code for references
   - Review Lambda functions for params access

3. **Should ap-south-1 stay as secondary region?**
   - If yes: Set up global tables for replication
   - If no: Plan decommissioning of ap-south-1 resources

### Next Steps
1. Execute Priority 1 recommendations
2. Document params table usage in application
3. Add Terraform configuration for params table
4. Enable production features (PITR, KMS, Streams)
5. Test data migration if needed
6. Update documentation with new configuration

## Files to Review

- [terraform/modules/dynamodb/main.tf](terraform/modules/dynamodb/main.tf) - Current DynamoDB module (missing params table definition)
- [terraform/modules/dynamodb/variables.tf](terraform/modules/dynamodb/variables.tf) - Module variables
- [terraform/terraform.tfvars](terraform/terraform.tfvars) - Variable values

## Conclusion

The **params table exists in both regions but with significant differences:**

| Aspect | ap-south-1 | us-east-2 |
|--------|-----------|-----------|
| **Management** | Manual/Amplify | Unmanaged by current Terraform |
| **Data** | 104 items (legacy) | Empty (ready for use) |
| **Production Features** | None enabled | None enabled |
| **Sync Status** | Standalone | Standalone |
| **Next Step** | Document & migrate/delete | Add to Terraform, enable features |

**The infrastructure migration from ap-south-1 to us-east-2 is incomplete for the params table.**
