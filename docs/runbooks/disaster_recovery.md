# 🚑 Disaster Recovery & Failover Runbook
## Amazon RDS & Multi-AZ Infrastructure Failover

### 1. Initiating Manual RDS Multi-AZ Failover
In the event of database degradation in the primary Availability Zone:

```bash
aws rds reboot-db-instance \
  --db-instance-identifier banking-prod-db \
  --force-failover
```

#### Verification Steps:
1. Monitor DNS resolution shift: `dig +short db.internal.banking.com`.
2. Ensure connection string dynamically re-establishes socket connection within 60 seconds.
3. Confirm standby instance status in secondary AZ using:
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier banking-prod-db \
     --query "DBInstance.[DBInstanceStatus,AvailabilityZone,SecondaryAvailabilityZone]"
   ```

### 2. Point-in-Time Restoration (PITR)
To restore database state prior to a corrupt transaction:

```bash
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier banking-prod-db \
  --target-db-instance-identifier banking-prod-db-restored \
  --restore-time 2026-07-25T14:30:00.000Z \
  --db-subnet-group-name banking-db-subnet-group
```
