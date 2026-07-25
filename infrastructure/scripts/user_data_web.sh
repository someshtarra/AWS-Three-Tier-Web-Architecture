#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Web Tier Bootstrap Script
# Component: Frontend Web Server (Nginx / Reverse Proxy)
# Author: Senior Cloud & DevOps Engineer
# ==============================================================================

set -euo pipefail

# Log all output to user-data log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "[INFO] Starting Web Tier Provisioning at $(date)..."

# Update packages & install dependencies
yum update -y
amazon-linux-extras install nginx1 -y || yum install -y nginx
yum install -y amazon-cloudwatch-agent curl jq htop

# Configure CloudWatch Agent
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 30
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/banking-platform/web/nginx-access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/banking-platform/web/nginx-error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Configure Nginx Reverse Proxy
cat << 'EOF' > /etc/nginx/conf.d/banking_app.conf
upstream backend_app {
    server 10.0.5.10:8080 max_fails=3 fail_timeout=10s;
    server 10.0.6.10:8080 max_fails=3 fail_timeout=10s;
    keepalive 32;
}

server {
    listen 80 default_server;
    server_name _;

    # Security Headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Health Check Endpoint for ALB
    location /healthz {
        access_log off;
        return 200 '{"status":"UP","tier":"web","timestamp":"$time_iso8601"}';
        add_header Content-Type application/json;
    }

    # Proxy traffic to Logic Tier (Backend EC2 Instances)
    location /api/ {
        proxy_pass http://backend_app/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout 60s;
    }

    # Static Assets
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
EOF

# Enable & start Nginx
systemctl enable nginx
systemctl restart nginx

echo "[SUCCESS] Web Tier provisioned successfully at $(date)!"
