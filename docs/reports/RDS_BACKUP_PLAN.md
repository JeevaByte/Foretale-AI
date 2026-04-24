# RDS Backup Plan - ForeTale Application

## Executive Summary
Backup strategy for PostgreSQL RDS database with 3-day backup frequency and 7-day retention period.

## Current State
- **Database:** foretale-app-rds-main (PostgreSQL 15)
- **Region:** us-east-2 (Ohio)
- **Instance Type:** db.t3.xlarge
- **Storage:** 100GB (gp3)

## Proposed Backup Plan

### Backup Configuration
```
Backup Retention Period:    7 days
Backup Frequency:           Every 3 days (AWS RDS limitation)
Backup Window:              03:00-04:00 UTC (off-peak)
Multi-AZ Deployment:        Enabled (automatic failover + backup redundancy)
```

### Understanding of Requirements

**1. Backup Frequency (Every 3 Days)**
- AWS RDS does NOT support custom backup intervals
- RDS automatically creates **daily backups** by default
- With 7-day retention, you get UP TO 7 daily backup snapshots
- **Alternative Interpretation:** 
  - If you want backups ONLY every 3 days, we can use AWS Backup service with scheduled snapshots
  - Manual snapshot policy: Take snapshots every 3 days

**2. Retention Period (7 Days)**
- Automated backups are kept for exactly 7 days
- After 7 days, old backups are automatically deleted
- Maximum 35 daily automated backups can be retained

### Proposed Solution Options

#### Option 1: Enhanced Automated Backups (Recommended)
```
✓ Daily automated backups (RDS native)
✓ 7-day retention period
✓ Point-in-time recovery (PITR) enabled
✓ Backup Window: 03:00-04:00 UTC
✓ Multi-AZ enabled for redundancy
```

#### Option 2: Custom 3-Day Backup Schedule (Using AWS Backup)
```
✓ AWS Backup service for scheduled snapshots
✓ Create snapshots every 3 days
✓ Retain snapshots for 7 days
✓ Automated backup lifecycle management
```

#### Option 3: Hybrid Approach
```
✓ AWS RDS daily automated backups (7-day retention)
✓ AWS Backup service for every 3 days snapshot (7-day retention)
✓ Provides both continuous recovery capability + scheduled snapshots
```

## Recommendation

**I recommend Option 1 (Enhanced Automated Backups)** because:
1. ✓ Simpler management (native RDS feature)
2. ✓ Lower cost (no extra AWS Backup service charges)
3. ✓ Better RTO/RPO (daily backups vs. 3-day gaps)
4. ✓ Point-in-time recovery available
5. ✓ Automatic backup to S3 with multi-AZ

## Key Considerations

### Recovery Objectives
- **RTO (Recovery Time Objective):** ~5-10 minutes (restore from snapshot)
- **RPO (Recovery Point Objective):** 24 hours (daily backups) or 3 hours (continuous logs)

### Cost Impact
- **Daily Backups:** Minimal cost (included in RDS)
- **AWS Backup Service:** ~$0.023 per snapshot (if using Option 2)
- **Storage:** Snapshots stored in S3 at ~$0.023 per GB per month

### Compliance & Security
- ✓ Encryption at rest (KMS)
- ✓ Encryption in transit (SSL/TLS)
- ✓ Multi-AZ automatic failover
- ✓ Automated backup copy to S3
- ✓ IAM access control

## Implementation Plan

### Phase 1: Current Configuration (No Change Needed)
- Retention Period: Keep at 7 days ✓
- Backup Window: Keep at 03:00-04:00 UTC ✓
- Multi-AZ: Already enabled ✓

### Phase 2: Add AWS Backup (Optional - if 3-day snapshots required)
- Create AWS Backup vault
- Define backup plan with 3-day schedule
- Set 7-day retention lifecycle rule
- Tag resources for automation

## Questions for Clarification

Before implementing, please confirm:

1. **Backup Frequency:** Do you need:
   - Daily automated backups (recommended) OR
   - Snapshots taken ONLY every 3 days?

2. **Recovery Type:** Do you need:
   - Point-in-time recovery (PITR) capability OR
   - Just periodic snapshots?

3. **Budget:** Are you:
   - Okay with standard RDS backup costs? OR
   - Need to minimize backup storage costs?

4. **Compliance:** Are there requirements for:
   - Cross-region backup replication?
   - Specific retention or deletion policies?

---

**Status:** Ready for implementation upon confirmation

**Last Updated:** 2026-02-05
