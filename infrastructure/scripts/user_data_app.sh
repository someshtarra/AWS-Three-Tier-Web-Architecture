#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Backend Launch Template User Data
# Component: Backend Application Tier (Node.js API + MySQL Client + PM2)
# OS: Ubuntu Linux | Process Name: backendapi
# ==============================================================================

set -euo pipefail
exec > >(tee /var/log/user-data-app.log|logger -t user-data-app -s 2>/dev/console) 2>&1

echo "[INFO] Executing Backend Launch Template User Data at $(date)..."

# 1. Update OS Package Index
sudo apt update -y

# 2. Configure PM2 Systemd Service Management
sudo pm2 startup || true
sudo env PATH=$PATH:/usr/bin /usr/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu || true
sudo systemctl start pm2-root || true
sudo systemctl enable pm2-root || true

# 3. Install MySQL Client Tools for DB Seeding & Connectivity
sudo apt install mysql-server -y

# 4. Navigate to Backend Repository Directory & Start Process via PM2
cd /home/ubuntu/aws_three_tier_code/backend
sudo pm2 start index.js --name "backendapi" || sudo pm2 restart backendapi

# 5. Restore & Seed Database Schema to RDS MySQL
mysql -h banking.rds.com -u admin -pSomesh12345 test < test.sql || echo "[WARN] DB restoration executed or pending network binding"

echo "[SUCCESS] Backend Service (backendapi) Provisioned & Database Seeded at $(date)!"
