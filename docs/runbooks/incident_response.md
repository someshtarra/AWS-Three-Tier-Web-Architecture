# 🚨 Incident Response & Troubleshooting Runbook
## Enterprise Banking Platform on AWS

### 🔴 Severity 1: Application Unavailable (HTTP 502 / 503)

#### Step 1: ALB Target Group Verification
```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET_GROUP_ARN> \
  --output table
```
If targets report `Unhealthy`:
1. Check Nginx / App service status on EC2 nodes via AWS SSM Session Manager.
2. Verify local health check endpoint: `curl -Iv http://localhost:8080/health`.

#### Step 2: Auto Scaling Fleet Inspection
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names banking-web-asg
```
Verify desired capacity vs actual running instances. If instances are continuously terminating, inspect EC2 console system event logs.

#### Step 3: CloudWatch Log Group Review
```bash
aws logs filter-log-events \
  --log-group-name /aws/ec2/banking-platform/web/nginx-error \
  --start-time $(date -d "15 mins ago" +%s000)
```
Look for upstream timeouts, memory exceptions, or connection failures to database endpoints.
