#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Frontend Web Tier User Data Script
# OS: Ubuntu Linux | Engine: Apache2 + Node.js 18 + React Client Build
# Repository: https://github.com/jadalaramani/aws_three_tier_code.git
# ==============================================================================

set -euo pipefail
exec > >(tee /var/log/user-data-web.log|logger -t user-data-web -s 2>/dev/console) 2>&1

echo "[INFO] Initializing Frontend Web Server Provisioning at $(date)..."

# 1. Update OS package repositories & install Apache2
sudo apt update -y
sudo apt install apache2 -y

# 2. Install Node.js 18.x runtime & Corepack / Yarn
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
sudo apt-get install -y nodejs
sudo apt update -y

sudo npm install -g corepack -y
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2 -y

# 3. Clone application repository
WORK_DIR="/opt/app"
sudo mkdir -p "${WORK_DIR}"
sudo chown -R ubuntu:ubuntu "${WORK_DIR}"
cd "${WORK_DIR}"

git clone https://github.com/jadalaramani/aws_three_tier_code.git
cd aws_three_tier_code/client

# 4. Configure API endpoint in src/pages/config.js
cat << 'EOF' > src/pages/config.js
export const API_BASE_URL = "https://api.b17facebook.xyz";
EOF

# 5. Build React production bundle
npm install
npm run build

# 6. Deploy static assets to Apache web root directory
sudo rm -rf /var/www/html/*
sudo cp -r build/* /var/www/html/

# 7. Restart & enable Apache2 service
sudo systemctl enable apache2
sudo systemctl restart apache2

echo "[SUCCESS] Frontend Web Server Provisioned & Active at $(date)!"
