#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Frontend Launch Template User Data
# Component: Frontend Presentation Tier (Apache2 Web Server)
# OS: Ubuntu Linux
# ==============================================================================

set -euo pipefail
exec > >(tee /var/log/user-data-web.log|logger -t user-data-web -s 2>/dev/console) 2>&1

echo "[INFO] Executing Frontend Launch Template User Data at $(date)..."

# 1. Update OS Package Index
sudo apt update -y

# 2. Delay to allow initial AMI initialization and network binding
sleep 90

# 3. Start Apache Web Server Service
sudo systemctl start apache2.service
sudo systemctl enable apache2.service

echo "[SUCCESS] Frontend Apache Web Server Started at $(date)!"
