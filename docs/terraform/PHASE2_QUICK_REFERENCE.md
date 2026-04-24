# Phase 2 Quick Reference

## Database Connection Details

**Host:** foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com  
**Port:** 5432  
**Database:** foretaledb  
**Username:** foretaleadmin  
**Password:** *Stored in AWS Secrets Manager (foretale-dev-db-credentials)*

## Get Database Password

```bash
# View full secret
aws secretsmanager get-secret-value \
  --secret-id foretale-dev-db-credentials \
  --region us-east-2 \
  --output text

# Extract password only
aws secretsmanager get-secret-value \
  --secret-id foretale-dev-db-credentials \
  --region us-east-2 \
  --query "SecretString | fromjson | .password" \
  --output text
```

## PostgreSQL Connection Examples

### psql CLI
```bash
psql -h foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com \
     -U foretaleadmin \
     -d foretaledb \
     -p 5432
```

### Connection String
```
postgresql://foretaleadmin@foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com:5432/foretaledb
```

### DBeaver/Other Tools
```
Host: foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com
Port: 5432
Database: foretaledb
User: foretaleadmin
Password: [From Secrets Manager]
```

## S3 Backup Storage Lifecycle

| Days | Storage Class | Purpose |
|------|---------------|---------|
| 0-30 | STANDARD | Active backups |
| 30-90 | STANDARD_IA | Infrequent access backups |
| 90-180 | GLACIER_IR | Archive with instant retrieval |
| 180-730 | DEEP_ARCHIVE | Cold storage archive |
| 730+ | Deleted | Automatic expiration |

## Terraform Commands

```bash
cd terraform/

# View all outputs
terraform output

# View specific outputs
terraform output rds_endpoint
terraform output phase2_summary

# View state
terraform state list | grep -E "rds|s3_bucket_lifecycle"

# Refresh state from AWS
terraform refresh
```

## AWS CLI Commands

### Check RDS Status
```bash
aws rds describe-db-instances \
  --db-instance-identifier foretale-dev-postgres \
  --region us-east-2 \
  --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus,AvailabilityZone,Engine,EngineVersion]' \
  --output table
```

### Check S3 Lifecycle Configuration
```bash
aws s3api get-bucket-lifecycle-configuration \
  --bucket foretale-dev-backups \
  --region us-east-2 \
  --output json
```

### Check Database Credentials in Secrets Manager
```bash
aws secretsmanager get-secret-value \
  --secret-id foretale-dev-db-credentials \
  --region us-east-2 \
  --output json
```

### Monitor RDS Performance
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=foretale-dev-postgres \
  --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region us-east-2
```

## RDS Database Features

✅ **Engine:** PostgreSQL 15  
✅ **Instance Class:** db.t3.micro (burstable, cost-effective)  
✅ **Storage:** 20 GB (can scale up)  
✅ **Backups:** 7-day retention  
✅ **Monitoring:** 60-second intervals  
✅ **Performance Insights:** Enabled  
✅ **Query Monitoring:** pg_stat_statements enabled  

## Common Tasks

### Create a Database Backup Snapshot
```bash
aws rds create-db-snapshot \
  --db-instance-identifier foretale-dev-postgres \
  --db-snapshot-identifier foretale-backup-$(date +%Y%m%d-%H%M%S) \
  --region us-east-2
```

### List Recent Backups
```bash
aws rds describe-db-snapshots \
  --db-instance-identifier foretale-dev-postgres \
  --region us-east-2 \
  --query 'DBSnapshots[0:5].[DBSnapshotIdentifier,SnapshotCreateTime,Status]' \
  --output table
```

### Check Query Performance (pg_stat_statements)
```bash
psql -h foretale-dev-postgres.cny6oww6atkz.us-east-2.rds.amazonaws.com \
     -U foretaleadmin \
     -d foretaledb \
     -c "SELECT query, calls, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

## Related Phase 1 Resources

- **VPC:** vpc-0bb9267ea1818564c
- **Security Group (RDS):** sg-098c14021205301 3a
- **Subnets:** 3x database subnets (subnet-047..., subnet-060..., subnet-0b8...)
- **DynamoDB Tables:** 5x tables (sessions, cache, ai-state, audit-logs, websocket-connections)
- **S3 Buckets:** 4x buckets (backups, user-uploads, app-storage, analytics)

## Troubleshooting

### Can't Connect to RDS
1. Check security group allows inbound on port 5432
2. Verify RDS instance status: `aws rds describe-db-instances --db-instance-identifier foretale-dev-postgres --region us-east-2`
3. Check credentials in Secrets Manager
4. Verify VPC/subnet routing

### S3 Lifecycle Not Working
1. Verify lifecycle configuration: `aws s3api get-bucket-lifecycle-configuration --bucket foretale-dev-backups --region us-east-2`
2. Ensure objects meet minimum size (128KB)
3. Check bucket versioning status
4. Verify IAM permissions for bucket lifecycle

### High RDS Costs
1. Review S3 lifecycle transitions - ensure backups are moving to GLACIER_IR/DEEP_ARCHIVE
2. Check CloudWatch metrics for CPU/storage growth
3. Consider snapshot retention policies
4. Monitor DynamoDB usage (on-demand billing)

## Document References

- **Full Deployment Summary:** `PHASE2_DEPLOYMENT_SUMMARY.md`
- **Terraform Configuration:** `terraform/modules/rds/main.tf`, `terraform/modules/s3/main.tf`
- **Variables:** `terraform/terraform.tfvars`, `terraform/variables.tf`
- **Architecture Diagram:** `terraform/ARCHITECTURE_DIAGRAM.md`

