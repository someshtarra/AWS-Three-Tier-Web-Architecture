#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Application (Logic) Tier Bootstrap
# Component: Backend API Service (Node.js/Express Engine)
# Author: Senior Cloud & DevOps Engineer
# ==============================================================================

set -euo pipefail

exec > >(tee /var/log/user-data-app.log|logger -t user-data-app -s 2>/dev/console) 2>&1

echo "[INFO] Initializing Application Tier..."

# Update system
yum update -y
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs amazon-efs-utils amazon-cloudwatch-agent jq

# Mount AWS EFS for shared application data
EFS_ID="fs-0a1b2c3d4e5f67890" # Replaced dynamically via Terraform
MOUNT_POINT="/mnt/efs/banking-shared"

mkdir -p "${MOUNT_POINT}"
mount -t efs -o tls "${EFS_ID}:/" "${MOUNT_POINT}" || echo "[WARN] EFS Mount pending DNS propagation"
echo "${EFS_ID}:/ ${MOUNT_POINT} efs _netdev,tls 0 0" >> /etc/fstab

# Install PM2 globally
npm install -g pm2

# Deploy Application Code
APP_DIR="/opt/banking-api"
mkdir -p "${APP_DIR}"

cat << 'EOF' > "${APP_DIR}/server.js"
const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

// Health Check endpoint for ALB / Target Group
app.get('/health', async (req, res) => {
    res.status(200).json({
        status: 'HEALTHY',
        service: 'Banking App Engine',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

app.get('/api/v1/accounts', async (req, res) => {
    res.json({
        accounts: [
            { id: "ACC-98412", type: "Checking", balance: 54320.50, currency: "USD" },
            { id: "ACC-31049", type: "Savings", balance: 125000.00, currency: "USD" }
        ]
    });
});

app.listen(PORT, () => {
    console.log(`[INFO] Banking Backend Service running on port ${PORT}`);
});
EOF

cd "${APP_DIR}"
npm init -y
npm install express mysql2 dotenv

# Start service via PM2
pm2 start server.js --name "banking-backend" --instances max
pm2 save
pm2 startup systemd -u root --hp /root

echo "[SUCCESS] Application Tier Service Started!"
