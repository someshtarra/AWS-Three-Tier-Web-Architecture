#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Backend Application Tier User Data Script
# OS: Ubuntu Linux | Engine: Node.js 18 + Express API + PM2
# Repository: https://github.com/jadalaramani/aws_three_tier_code.git
# ==============================================================================

set -euo pipefail
exec > >(tee /var/log/user-data-app.log|logger -t user-data-app -s 2>/dev/console) 2>&1

echo "[INFO] Initializing Backend Application Server Provisioning at $(date)..."

# 1. Update OS package repositories & install Node.js 18.x
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
sudo apt-get install -y nodejs
sudo apt update -y
sudo npm install -g pm2 -y

# 2. Clone application repository
WORK_DIR="/opt/app"
sudo mkdir -p "${WORK_DIR}"
sudo chown -R ubuntu:ubuntu "${WORK_DIR}"
cd "${WORK_DIR}"

git clone https://github.com/jadalaramani/aws_three_tier_code.git
cd aws_three_tier_code/server

# 3. Configure Database Credentials Environment (.env)
cat << 'EOF' > .env
PORT=8080
DB_HOST=book.rbs.com
DB_USER=admin
DB_PASS=sJOMVBzQizbvvmLtqoG8
DB_NAME=test
EOF

# 4. Install dependencies & start service via PM2
npm install
pm2 start index.js --name "backend-api"
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu || true

echo "[SUCCESS] Backend Application Service Provisioned & Active at $(date)!"
