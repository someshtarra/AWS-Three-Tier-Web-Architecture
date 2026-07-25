<div align="center">

# 🏦 Enterprise Banking Platform on AWS
### 🚀 Production-Ready Three-Tier Cloud Architecture

[![AWS Architecture](https://img.shields.io/badge/AWS-3--Tier_Architecture-ff9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![DevOps Ready](https://img.shields.io/badge/DevOps-Production_Grade-0052cc?style=for-the-badge&logo=azure-devops&logoColor=white)](https://aws.amazon.com/devops/)
[![High Availability](https://img.shields.io/badge/Availability-99.99%25_Multi--AZ-00d26a?style=for-the-badge&logo=statuspage&logoColor=white)](#high-availability-design)
[![Security Compliance](https://img.shields.io/badge/Security-PCI--DSS%20%7C%20SOC2-red?style=for-the-badge&logo=shield&logoColor=white)](#security-architecture)
[![IaC Ready](https://img.shields.io/badge/IaC-Terraform_&_CloudFormation-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](#future-improvements)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

---

![Enterprise AWS Three-Tier Architecture Banner](assets/aws_banner.png)

</div>

---

## 📌 Table of Contents
- [📖 Project Overview](#-project-overview)
- [📐 Architecture Diagram](#-architecture-diagram)
- [🛠️ AWS Services Used](#%EF%B8%8F-aws-services-used)
- [🌐 Network Architecture](#-network-architecture)
- [⚡ High Availability Design](#-high-availability-design)
- [🔒 Security Architecture](#-security-architecture)
- [💾 Storage Layer](#-storage-layer)
- [📊 Monitoring & Observability](#-monitoring--observability)
- [🚀 Deployment Workflow](#-deployment-workflow)
- [💻 AWS CLI Commands](#-aws-cli-commands)
- [🐧 Linux Administration](#-linux-administration)
- [🔧 DevOps Troubleshooting](#-devops-troubleshooting)
- [🔍 Common Linux Troubleshooting](#-common-linux-troubleshooting)
- [📂 Folder Structure](#-folder-structure)
- [⭐ Key Features](#-key-features)
- [🧠 Skills Demonstrated](#-skills-demonstrated)
- [🔮 Future Improvements](#-future-improvements)

---

## 📖 Project Overview

This repository demonstrates the design, provisioning, deployment, and management of a **highly available, secure, scalable, fault-tolerant, and production-grade Enterprise Banking Application on AWS**, following industry-standard **DevOps best practices** and the **AWS Well-Architected Framework**.

The application is structured into a strictly isolated **Three-Tier Architecture**:
1. **Presentation Tier (Web Tier)**: External HTTPS endpoints fronted by Amazon CloudFront, AWS WAF, and Application Load Balancer (ALB) routing to auto-scaled Nginx Web Servers in Public/Private Subnets.
2. **Logic Tier (App Tier)**: Core microservices hosted on stateless EC2 instances managed by Auto Scaling Groups across multiple Availability Zones with internal load balancing.
3. **Data Tier (Database Tier)**: High-performance Amazon RDS PostgreSQL/MySQL Multi-AZ DB Cluster in dedicated isolated DB subnets with automated read replicas and failover capabilities.

### 🌟 Key Architectural Pillars

- 🔄 **High Availability**: Multi-AZ deployments across Availability Zone A (`us-east-1a`) and Availability Zone B (`us-east-1b`) ensuring 99.99% uptime.
- 📈 **Scalability**: Dynamic Auto Scaling Groups (ASG) based on CPU, Memory, and Request-Count metrics to handle unexpected transaction spikes.
- 🛡️ **Fault Tolerance**: Automatic target deregistration, self-healing EC2 instances, and sub-minute RDS Multi-AZ failover.
- 🔐 **Security**: Zero-Trust network boundary model utilizing AWS WAF, Security Groups, Network ACLs, private DB subnets, and AWS SSM Session Manager (no open port 22).
- ⚙️ **Infrastructure Automation**: Modularized Launch Templates, automated AMI baking, user-data bootstrap automation, and IaC-ready architecture.
- 📊 **Monitoring & Observability**: Real-time CloudWatch dashboards, custom memory metrics, audit trails via CloudTrail, and automated SNS alert triggers.
- ⚡ **CI/CD Ready**: Integrated pipeline hook designs supporting zero-downtime rolling updates and instance refresh strategies.
- 🔄 **Zero Downtime Deployment**: Connection draining, ALB target group health checks, and rolling instance deployments.
- ⚖️ **Load Balancing**: Cross-zone Application Load Balancer with TLS termination via AWS Certificate Manager (ACM).
- 🚑 **Disaster Recovery**: Automated multi-AZ RDS backups, point-in-time recovery (PITR), cross-region AMI replication, and EBS lifecycle snapshots.
- ☁️ **Cloud Monitoring**: Centralized logging using AWS CloudWatch Logs Agent and VPC Flow Logs.
- 🏗️ **Infrastructure as Code Ready**: Standardized configuration layout ready for Terraform, Bicep, or AWS CloudFormation deployment.

---

## 📐 Architecture Diagram

### 🏗️ Enterprise AWS 3-Tier Network & Traffic Topology

```
                                    +--------------------------------------------------------+
                                    |                   INTERNET USERS                       |
                                    +---------------------------+----------------------------+
                                                                | HTTPS (Port 443)
                                                                v
                                    +--------------------------------------------------------+
                                    |                 AMAZON ROUTE 53 (DNS)                  |
                                    +---------------------------+----------------------------+
                                                                |
                                                                v
                                    +--------------------------------------------------------+
                                    |            AMAZON CLOUDFRONT (CDN Edge)                |
                                    |              + AWS WAF (Web App Firewall)              |
                                    |              + ACM SSL/TLS Certificate                 |
                                    +---------------------------+----------------------------+
                                                                |
                                                                v
                                    +--------------------------------------------------------+
                                    |               INTERNET GATEWAY (IGW)                   |
                                    +---------------------------+----------------------------+
                                                                |
  ==============================================================|==============================================================
  VPC (10.0.0.0/16)                                             v
  =============================================================================================================================
  
        +---------------------------------------------------+        +---------------------------------------------------+
        | AVAILABILITY ZONE A (us-east-1a)                  |        | AVAILABILITY ZONE B (us-east-1b)                  |
        +---------------------------------------------------+        +---------------------------------------------------+
        
  --- [ PUBLIC SUBNET 1A: 10.0.1.0/24 ] ---------------------        --- [ PUBLIC SUBNET 1B: 10.0.2.0/24 ] ---------------------
  |                                                         |        |                                                         |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |   |            NAT GATEWAY 1A (Elastic IP)          |   |        |   |            NAT GATEWAY 1B (Elastic IP)          |   |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |                                                         |        |                                                         |
  |   +--------------------------------------------------------------------------------------------------------------------+   |
  |   |                                  EXTERNAL APPLICATION LOAD BALANCER (ALB)                                           |   |
  |   |                                          ACM TLS 1.3 Encryption                                                     |   |
  |   +--------------------------------------------------+-----------------------------------------------------------------+   |
  -------------------------------------------------------|------------------------------------------------------------------
                                                         | Forward Rules / Target Groups
                                                         v
  --- [ PRIVATE WEB SUBNET 2A: 10.0.3.0/24 ] ---------------        --- [ PRIVATE WEB SUBNET 2B: 10.0.4.0/24 ] ---------------
  |                                                         |        |                                                         |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |   |  Frontend EC2 Instance (AZ-A)                   |   |        |   |  Frontend EC2 Instance (AZ-B)                   |   |
  |   |  AMI: Golden Linux 2023 | Nginx Web Server     |   |        |   |  AMI: Golden Linux 2023 | Nginx Web Server     |   |
  |   |  Storage: EBS gp3 30GB Encrypted                |   |        |   |  Storage: EBS gp3 30GB Encrypted                |   |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |                            ^                            |        |                            ^                            |
  |                            +---------- AUTO SCALING GROUP (WEB TIER) -----------------+                            |
  -------------------------------------------------------|------------------------------------------------------------------
                                                         | Internal Traffic Routing
                                                         v
  --- [ PRIVATE APP SUBNET 3A: 10.0.5.0/24 ] ---------------        --- [ PRIVATE APP SUBNET 3B: 10.0.6.0/24 ] ---------------
  |                                                         |        |                                                         |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |   |  Backend EC2 Instance (AZ-A)                    |   |        |   |  Backend EC2 Instance (AZ-B)                    |   |
  |   |  AMI: Node.js/Java App Service                  |   |        |   |  AMI: Node.js/Java App Service                  |   |
  |   |  Storage: EBS gp3 50GB + EFS Mount              |   |        |   |  Storage: EBS gp3 50GB + EFS Mount              |   |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |                            ^                            |        |                            ^                            |
  |                            +---------- AUTO SCALING GROUP (APP TIER) -----------------+                            |
  -------------------------------------------------------|------------------------------------------------------------------
                                                         | DB Connections (Port 3306 / 5432)
                                                         v
  --- [ PRIVATE DB SUBNET 4A: 10.0.7.0/24 ] ---------------        --- [ PRIVATE DB SUBNET 4B: 10.0.8.0/24 ] ---------------
  |                                                         |        |                                                         |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |   |  Amazon RDS Multi-AZ Primary DB                 |   |        |   |  Amazon RDS Multi-AZ Standby DB (Sync Replica)  |   |
  |   |  Engine: PostgreSQL/MySQL | EBS Encrypted       |<==|========|==>|  Automated Failover & Storage Auto-scaling       |   |
  |   +-------------------------------------------------+   |        |   +-------------------------------------------------+   |
  |                                                         |        |                                                         |
  -----------------------------------------------------------        -----------------------------------------------------------

  =============================================================================================================================
  SHARED ENTERPRISE SERVICES & MANAGED UTILITIES
  =============================================================================================================================
  +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+
  | Amazon EFS            |  | AWS CloudWatch        |  | AWS CloudTrail        |  | IAM Roles & Profiles  |
  | Shared Persistent Storage| | Metrics, Logs & Alarms | | Management Audit Logs | | Least-Privilege SSM   |
  +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+
  +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+
  | Private Hosted Zone   |  | VPC Peering           |  | GitHub / CI-CD        |  | AWS CLI               |
  | Internal DNS Resolution| | Management VPC Peer   |  | Automated Build Pipeline| | Operator Automation   |
  +-----------------------+  +-----------------------+  +-----------------------+  +-----------------------+
```

---

## 🛠️ AWS Services Used

| AWS Service | Category | Core Purpose | Real-World Enterprise Usage |
| :--- | :--- | :--- | :--- |
| **Amazon EC2** | Compute | Virtual application servers | Hosts web servers (Nginx) & backend API logic across isolated subnets. |
| **Amazon Machine Image (AMI)** | Compute | Standardized OS template | Pre-configured golden images baked with security patches, agents, & app code. |
| **EC2 Launch Template** | Compute | Instance configuration versioning | Standardizes instance types, user-data, IAM profiles, EBS & security groups. |
| **Application Load Balancer (ALB)** | Networking | Layer 7 traffic routing | Distributes incoming HTTPS web traffic across multi-AZ EC2 instances with TLS offloading. |
| **ALB Target Groups** | Networking | Backend health checking | Routes traffic to healthy EC2 targets and performs automated health probes every 15s. |
| **Auto Scaling Group (ASG)** | Compute | Elastic capacity scaling | Dynamically expands/contracts EC2 fleets based on CPU utilization and request count. |
| **Amazon EBS** | Storage | High-performance block storage | Primary encrypted OS root storage (`gp3` / `io2`) for EC2 nodes with snapshot policies. |
| **Amazon EFS** | Storage | Shared NFS file system | Provides multi-AZ POSIX-compliant shared file storage for stateless app tiers. |
| **Amazon RDS Multi-AZ** | Database | Managed relational database | High-availability database cluster with synchronous replication and auto-failover. |
| **RDS Subnet Group** | Database | Network isolation for DB | Restricts database instance placement strictly to isolated private DB subnets. |
| **Amazon Route 53** | DNS | High-availability DNS service | External domain routing with failover routing policies and health checks. |
| **Amazon CloudFront** | CDN | Edge content delivery | Global edge caching for static assets, lowering latency and offloading web tier load. |
| **AWS CloudWatch** | Monitoring | Log & metric collection | Real-time monitoring of CPU, RAM, disk usage, application logs, and alarm triggers. |
| **AWS CloudTrail** | Security | API governance & auditing | Records every API call across the AWS account for compliance and security forensics. |
| **AWS IAM** | Identity | Identity & Access Management | Enforces Least Privilege access via role-based EC2 instance profiles and policies. |
| **Security Groups** | Security | Stateful instance firewalls | Controls inbound and outbound port-level traffic at the EC2/RDS interface level. |
| **Network ACL (NACL)** | Security | Stateless subnet firewalls | Subnet-level network filtering acting as a second layer of defense. |
| **AWS ACM** | Security | SSL/TLS Certificate Manager | Provisions and automatically renews public TLS certificates for CloudFront & ALB. |
| **Amazon VPC** | Networking | Isolated virtual network | Dedicated network enclosure (`10.0.0.0/16`) containing public, app, and DB subnets. |
| **NAT Gateway** | Networking | Outbound internet proxy | Allows private subnet EC2 instances to fetch OS patches without receiving inbound traffic. |
| **Internet Gateway (IGW)** | Networking | Public internet entrypoint | Connects public subnets and ALB directly to the external internet. |
| **Elastic IP (EIP)** | Networking | Static public IPv4 address | Provides stable static public IPs for NAT Gateways for IP whitelisting. |
| **Private Hosted Zone** | DNS | Internal DNS resolution | Resolves internal domain endpoints (e.g., `db.internal.banking.com`) privately. |
| **Public Hosted Zone** | DNS | Public DNS resolution | Maps public domain names (e.g., `banking.example.com`) to CloudFront and ALB. |
| **AWS CLI** | Management | Programmatic cloud automation | Scriptable administration, CI/CD pipeline interaction, and cloud operations. |

---

## 🌐 Network Architecture

The network layout uses an enterprise VPC CIDR block `10.0.0.0/16` segmented across **two Availability Zones** (`us-east-1a` and `us-east-1b`) for complete redundancy.

```
VPC CIDR Block: 10.0.0.0/16
├── Public Subnet 1A (AZ-A): 10.0.1.0/24  --> NAT Gateway 1A, ALB Interface
├── Public Subnet 1B (AZ-B): 10.0.2.0/24  --> NAT Gateway 1B, ALB Interface
├── Private Web Subnet 2A (AZ-A): 10.0.3.0/24 --> Nginx Web Instances
├── Private Web Subnet 2B (AZ-B): 10.0.4.0/24 --> Nginx Web Instances
├── Private App Subnet 3A (AZ-A): 10.0.5.0/24 --> App Server Node.js
├── Private App Subnet 3B (AZ-B): 10.0.6.0/24 --> App Server Node.js
├── Private DB Subnet 4A (AZ-A): 10.0.7.0/24  --> Amazon RDS Master
└── Private DB Subnet 4B (AZ-B): 10.0.8.0/24  --> Amazon RDS Standby
```

### 🛣️ Routing Tables Strategy

1. **Public Route Table**: Associated with Public Subnets (`10.0.1.0/24`, `10.0.2.0/24`). Contains default route `0.0.0.0/0` targeted to the **Internet Gateway (IGW)**.
2. **Private Web/App Route Tables**: Dedicated per AZ (`AZ-A` and `AZ-B`). Contains default route `0.0.0.0/0` targeted to the respective **NAT Gateway** in that AZ, ensuring outbound access for system updates while preventing inbound public internet access.
3. **Private DB Route Table**: No internet routing (`0.0.0.0/0` omitted). Accepts traffic strictly from Private App Subnets.

### 🔗 VPC Peering & Subnet Isolation

- **Management VPC Peering**: A secure VPC Peering connection bridges the Production VPC with a dedicated Operations/Bastion Management VPC (`172.16.0.0/16`) for administrative access.
- **NACL & Security Group Layering**:
  - **Stateful Filtering (Security Groups)**: Micro-segmented at the EC2/RDS resource interface level.
  - **Stateless Filtering (NACLs)**: Subnet boundary rule sets enforcing explicit IP and port ranges.

---

## ⚡ High Availability Design

<details>
<summary><b>Click to expand High Availability Architecture Details</b></summary>

### 🔄 Multi-AZ Redundancy
- **Active-Active Compute**: Web and Application EC2 fleets are distributed equally across `us-east-1a` and `us-east-1b`. If an entire AWS Availability Zone experiences an outage, the remaining zone handles 100% of application traffic automatically.
- **Multi-AZ RDS Replication**: Amazon RDS operates in a Multi-AZ configuration using synchronous block-level storage replication. In the event of primary database node hardware failure, RDS triggers an automated DNS failover to the standby node within 60 seconds.

### 📈 Dynamic Auto Scaling & Health Monitoring
- **Target Tracking Scaling Policy**: Auto Scaling Groups scale out when average CPU utilization exceeds **70%** or Target Request Count per instance exceeds **1,000 requests/min**.
- **ELB & EC2 Health Checks**: The ALB continuously polls the `/healthz` endpoint on targets every **15 seconds**. Instances failing 3 consecutive health checks are automatically deregistered and terminated by ASG, which immediately launches healthy replacement instances from the Launch Template.

```
       +-----------------------------------------------------------+
       |               ALB Target Group Health Probe               |
       +-----------------------------+-----------------------------+
                                     |
                                     v
                       +---------------------------+
                       | HTTP /healthz Check (15s) |
                       +-------------+-------------+
                                     |
                   +-----------------+-----------------+
                   |                                   |
            [ Status 200 OK ]                   [ Status 500/Timeout ]
                   |                                   |
                   v                                   v
          Mark Target HEALTHY                  Increment Failure Count
                   |                                   |
       Keep Traffic Routing                 [ Failed 3 Consecutive Checks ]
                                                       |
                                                       v
                                            Deregister Target from ALB
                                                       |
                                                       v
                                            ASG Terminates Unhealthy Node
                                                       |
                                                       v
                                            ASG Spins Up Replacement Node
```

</details>

---

## 🔒 Security Architecture

This architecture implements a robust **Defense-in-Depth** security posture compliant with financial enterprise security mandates (PCI-DSS, SOC2):

```
       [ INTERNET ]
            │
            ▼ (HTTPS / WAF Rules)
     [ AWS WAF / ALB ]  <-- TLS 1.3 Termination (ACM Cert)
            │
            ▼ (Port 80 / 443 - Security Group: Web-SG)
     [ WEB TIER EC2 ]   <-- IAM Instance Profile (No SSH / SSM Only)
            │
            ▼ (Port 8080 - Security Group: App-SG)
     [ APP TIER EC2 ]   <-- Encrypted EBS (KMS) + EFS (TLS)
            │
            ▼ (Port 3306/5432 - Security Group: DB-SG)
     [ DATABASE TIER ]  <-- Private Subnet Only (No Internet Route)
```

- 🔑 **Identity & Access Management (IAM)**: Strict enforcement of **Least Privilege**. EC2 instances run using custom IAM Roles with attached managed policies (e.g., `AmazonSSMManagedInstanceCore`, `CloudWatchAgentServerPolicy`) without hardcoded credentials.
- 🛡️ **Zero Open Ports (SSM Session Manager)**: Standard port 22 SSH ingress is disabled across all subnets. System administrators authenticate securely via **AWS Systems Manager (SSM) Session Manager** with Multi-Factor Authentication (MFA).
- 🌐 **Edge & Perimeter Defense**: **AWS WAF** inspects incoming request payloads against standard SQL injection, Cross-Site Scripting (XSS), and rate-limiting rules.
- 🔒 **Data Encryption in Transit & at Rest**:
  - **In-Transit**: Full TLS 1.3 encryption from edge to load balancer managed by **AWS Certificate Manager (ACM)**. Internal tier-to-tier communication uses encrypted private channels.
  - **At-Rest**: All EBS volumes, EFS file systems, and RDS storage clusters are encrypted using customer-managed **AWS KMS Keys (SSE-KMS)**.
- 🔐 **Secrets Management**: Database passwords and API keys are stored centrally in **AWS Secrets Manager** with dynamic secret rotation enabled.

---

## 💾 Storage Layer

| Storage Type | AWS Service | Storage Engine | IOPS / Throughput | Backup & Lifecycle Policy |
| :--- | :--- | :--- | :--- | :--- |
| **Block Storage** | Amazon EBS | `gp3` / `io2` | 3,000 IOPS / 125 MB/s baseline | AWS Data Lifecycle Manager (DLM) daily snapshots with 30-day retention. |
| **Shared File System** | Amazon EFS | Elastic NFSv4 | Dynamic auto-scaling throughput | Multi-AZ lifecycle management moving cold data to EFS IA after 30 days. |
| **Database Storage** | Amazon RDS | Provisioned IOPS | Auto-scaling storage up to 64TB | Automated daily backups, 35-day PITR, and multi-region snapshot copy. |
| **Golden OS Images** | Amazon EC2 AMI | EBS-backed AMI | N/A | Automated AMI baking via Packer pipeline with monthly vulnerability patches. |

---

## 📊 Monitoring & Observability

Observability is maintained through an integrated AWS native monitoring stack:

```
                          +-----------------------------------+
                          |     AWS CLOUDWATCH DASHBOARD      |
                          +-----------------+-----------------+
                                            |
            +-------------------------------+-------------------------------+
            |                               |                               |
            v                               v                               v
  [ Compute Metrics ]             [ Custom OS Metrics ]           [ Application Logs ]
  • CPU Utilization (>80%)        • Memory Used Percent           • Nginx Access/Error Logs
  • Network In / Network Out      • Disk Space Used (%)           • Node.js App Exception Trace
  • EC2 Status Check Failed       • Active Connections            • RDS Slow Query Logs
            |                               |                               |
            +-------------------------------+-------------------------------+
                                            |
                                            v
                          +-----------------------------------+
                          |      CLOUDWATCH ALARM TRIGGER     |
                          +-----------------+-----------------+
                                            |
                                            v
                          +-----------------------------------+
                          |   AWS SNS -> PAGERDUTY / SLACK    |
                          +-----------------------------------+
```

- 📈 **Key CloudWatch Metrics Monitored**:
  - `AWS/EC2`: `CPUUtilization`, `StatusCheckFailed`, `NetworkIn`, `NetworkOut`
  - `CWAgent (Custom)`: `mem_used_percent`, `disk_used_percent`
  - `AWS/ApplicationELB`: `HTTPCode_Target_5XX_Count`, `TargetResponseTime`, `RequestCount`
  - `AWS/RDS`: `CPUUtilization`, `DatabaseConnections`, `FreeStorageSpace`, `ReadLatency`
- 🕵️ **CloudTrail Governance**: Audits all management and data events across the AWS account, delivering logs to an immutable, KMS-encrypted S3 bucket.

---

## 🚀 Deployment Workflow

Continuous delivery to the 3-Tier architecture follows a zero-downtime rolling update strategy:

```
+----------------+      +----------------+      +------------------+      +------------------+
|   Developer    | ---> | GitHub Repo    | ---> | CI/CD Build      | ---> | AMI / Artifact   |
|   Commits Code |      | (main branch)  |      | (GitHub Actions) |      | Creation (Packer)|
+----------------+      +----------------+      +------------------+      +--------+---------+
                                                                                   |
                                                                                   v
+----------------+      +----------------+      +------------------+      +------------------+
| Production     | <--- | Target Group   | <--- | Auto Scaling     | <--- | EC2 Launch       |
| Live Traffic   |      | Health Check   |      | Instance Refresh |      | Template Update  |
+----------------+      +----------------+      +------------------+      +------------------+
```

1. **Commit & Push**: Developer pushes verified code changes to GitHub repository.
2. **Automated Build & Test**: GitHub Actions builds dependencies, runs unit/integration tests, and security scans.
3. **AMI / Artifact Provisioning**: Packer bakes an updated Golden AMI containing the application release.
4. **Launch Template Update**: Terraform/AWS CLI creates a new version of the EC2 Launch Template with the updated AMI ID.
5. **ASG Instance Refresh**: Auto Scaling Group triggers a **Rolling Instance Refresh** (Minimum Healthy Percentage = 50%, Warmup = 300s).
6. **ALB Target Verification**: ALB performs health checks on newly deployed instances before draining traffic from legacy nodes.

---

## 💻 AWS CLI Commands

<details>
<summary><b>Click to view Production AWS CLI Reference Commands</b></summary>

### 🖥️ EC2 & Launch Templates
```bash
# List all running production EC2 instances with IP addresses
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=production" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" \
  --output table

# Create a new version of Launch Template
aws ec2 create-launch-template-version \
  --launch-template-name banking-web-template \
  --version-description "v2.0-release" \
  --launch-template-data '{"ImageId":"ami-0abcdef1234567890","InstanceType":"t3.medium"}'
```

### ⚖️ Auto Scaling Groups & Application Load Balancers
```bash
# Start an ASG Instance Refresh (Zero-Downtime Deployment)
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name banking-web-asg \
  --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 300}'

# Check target group health status
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/banking-web-tg/a1b2c3d4e5f6

# Describe ALB listener rules
aws elbv2 describe-rules \
  --listener-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/banking-alb/123456/789012
```

### 🗄️ Database, Storage & Monitoring
```bash
# Fail over an RDS Multi-AZ DB Cluster manually for testing
aws rds reboot-db-instance \
  --db-instance-identifier banking-prod-db \
  --force-failover

# Describe EFS Mount Targets
aws efs describe-mount-targets \
  --file-system-id fs-0a1b2c3d4e5f67890

# Query active CloudWatch alarms in ALARM state
aws cloudwatch describe-alarms \
  --state-value ALARM \
  --query "MetricAlarms[*].[AlarmName,MetricName,StateUpdatedTimestamp]" \
  --output table
```

</details>

---

## 🐧 Linux Administration

<details>
<summary><b>Click to view Linux Systems Administration Reference</b></summary>

### 🛠️ Service & Process Management
```bash
# Systemctl service controls
systemctl status nginx
systemctl restart nginx
systemctl enable nginx

# Real-time journal logs filtering
journalctl -u nginx.service -f --since "10 min ago"
journalctl -u nodejs-backend -n 100 --no-pager

# Process inspection & termination
ps aux | grep node
top -b -n 1 | head -n 20
htop
kill -9 <PID>
```

### 🌐 Networking & Port Troubleshooting
```bash
# Inspect listening TCP/UDP ports and associated PIDs
ss -tulnp
netstat -tulnp

# Find process bound to specific port (e.g., port 8080)
lsof -i :8080

# Network connectivity testing
curl -Iv https://localhost/healthz
nc -zv 10.0.5.10 3306
dig +short db.internal.banking.com
```

### 📂 File System, Permissions & Archiving
```bash
# Disk space & memory usage
df -h
free -h

# File searching & manipulation
find /var/log -type f -name "*.log" -mtime -1
grep -rn "ERROR" /var/log/nginx/
awk '{print $1, $7, $9}' /var/log/nginx/access.log | head -n 30
sed -i 's/PORT=8000/PORT=8080/g' /opt/banking-api/.env

# Permissions & ownership
chmod 600 /etc/banking/db_creds.env
chown -R nginx:nginx /var/www/html

# Transfer & archiving
tar -czvf app-backup-$(date +%F).tar.gz /opt/banking-api/
rsync -avz -e "ssh" /var/log/app/ user@remote-backup:/backups/
```

</details>

---

## 🔧 DevOps Troubleshooting

| # | Issue | Symptoms | Root Cause | Resolution Strategy |
| :---: | :--- | :--- | :--- | :--- |
| 1 | **Port Already in Use** | Service fail to start (`EADDRINUSE`) | Existing orphan process bound to target port. | Run `lsof -i :<port>` or `ss -tulnp`, identify PID, and execute `kill -9 <PID>`. |
| 2 | **Permission Denied** | Application crash on file write | Process user lacks file system permissions. | Adjust ownership with `chown -R appuser:appgroup /path` and permissions with `chmod 755`. |
| 3 | **SSH Timeout** | Connection timed out on port 22 | Security group or route table blocking SSH. | Verify Security Group inbound rules allow port 22 or switch to AWS SSM Session Manager. |
| 4 | **502 Bad Gateway** | Nginx returns HTTP 502 to client | Backend App EC2 process crashed or unreachable. | Check backend app status (`systemctl status app`), verify port 8080 listening with `ss -tulnp`. |
| 5 | **504 Gateway Timeout** | Request hangs and times out (504) | App process running slow or DB lock wait. | Inspect backend app response time, check DB CPU/locks, increase Nginx `proxy_read_timeout`. |
| 6 | **503 Service Unavailable** | ALB returns HTTP 503 | No healthy instances registered in Target Group. | Verify EC2 health check endpoint (`/healthz`), check Security Group rules between ALB and EC2. |
| 7 | **Application Unhealthy** | ASG terminating EC2 instances | `/healthz` returning 5xx or failing timeout. | Inspect `/var/log/user-data.log`, verify dependencies (DB, Redis) are reachable. |
| 8 | **ALB Health Check Failed** | Target status shows `Unhealthy` | Health check path misconfigured or firewall blocking. | Match Target Group health check path to app route (`/health`), verify Security Group allows ALB IP. |
| 9 | **Node.js Crashed** | Service stopped unexpected | Unhandled exception or Out-Of-Memory (OOM). | Check `pm2 logs` or `journalctl -u node`, use PM2 auto-restart (`pm2 start server.js --max-memory-restart 500M`). |
| 10 | **Apache Failed** | HTTP daemon fails to boot | Syntax error in `httpd.conf` or port conflict. | Test syntax with `apachectl configtest`, check system logs via `journalctl -u httpd`. |
| 11 | **Nginx Failed** | Nginx service fails on reload | Directives syntax error in `/etc/nginx/nginx.conf`. | Execute `nginx -t` to pinpoint line error and correct syntax before running `systemctl reload nginx`. |
| 12 | **RDS Connection Timeout** | App log: `ETIMEDOUT` to DB | Security Group missing rule or subnet routing issue. | Add rule in RDS Security Group allowing inbound traffic on 3306/5432 from App Security Group. |
| 13 | **MySQL Auth Failed** | `Access denied for user` | Invalid DB credentials or missing privileges. | Verify credentials in AWS Secrets Manager, check DB user host permissions (`'user'@'10.0.%.%'`). |
| 14 | **Security Group Issue** | Traffic dropped silently | Stateful rule missing for target port/source. | Audit Security Group rules using `aws ec2 describe-security-groups` and add explicit ingress. |
| 15 | **Network ACL Issue** | Inter-subnet traffic blocked | Stateless NACL missing ephemeral outbound rule. | Ensure NACL allows return traffic on ports `1024-65535` for public/private subnet communication. |
| 16 | **DNS Propagation Delay** | Domain resolves to old IP | TTL cached by local DNS resolver or ISP. | Lower DNS record TTL prior to migration, clear local DNS cache (`sudo dsnscacheutil -flushcache`). |
| 17 | **CloudFront Cache Stale** | Outdated web contents rendered | Edge location caching old static assets. | Create CloudFront invalidation (`aws cloudfront create-invalidation --distribution-id ID --paths "/*"`). |
| 18 | **Route53 Record Issue** | Domain failing DNS lookup | Alias record pointing to wrong ALB ARN. | Verify Route53 Alias target matches exact ALB DNS name and hosted zone ID. |
| 19 | **Disk Full** | OS throws `No space left on device` | Log files filled up root EBS volume. | Clean logs (`journalctl --vacuum-size=100M`), truncate `/var/log`, or expand EBS volume online via AWS CLI. |
| 20 | **Memory Full (OOM)** | Linux Kernel OOM Killer killing processes | RAM exhausted by application memory leak. | Analyze memory usage (`free -m`, `top`), create swap file, rightsize EC2 instance type. |
| 21 | **CPU 100% Saturation** | Server unresponsive, high load | Infinite loop or high request traffic concurrency. | Identify offending process with `htop`, scale out ASG capacity, optimize app query logic. |
| 22 | **EBS Attachment Issue** | Volume stuck in `attaching` state | Volume stuck in different AZ than EC2. | Verify EBS volume and EC2 instance are located in identical Availability Zone (e.g., `us-east-1a`). |
| 23 | **AMI Boot Issue** | Instance fails kernel boot | Missing kernel drivers or invalid `/etc/fstab`. | Inspect EC2 Serial Console logs, repair `/etc/fstab` UUID entries via rescue volume mount. |
| 24 | **Launch Template Error** | ASG failing to launch nodes | Invalid AMI ID or deprecated instance type. | Update Launch Template version with valid AMI ID and active instance family (e.g., `t3.medium`). |
| 25 | **Auto Scaling Failure** | ASG status: `EC2 launch template error` | Insufficient AWS account vCPU quota limit. | Request EC2 vCPU quota increase via AWS Service Quotas console or delete idle instances. |
| 26 | **EFS Mount Failure** | Command hangs: `mount.nfs: connection timed out` | Security Group missing NFS port 2049 ingress. | Verify EFS Security Group permits port 2049 ingress from App EC2 Security Group. |
| 27 | **IAM Access Denied** | AWS API calls returning `403 Forbidden` | Missing policy permission in IAM Role. | Inspect IAM policy JSON, add required action (e.g., `s3:GetObject`), attach to Instance Profile. |
| 28 | **AWS CLI Auth Failure** | `Unable to locate credentials` | Expired AWS SSO token or missing config file. | Re-authenticate via `aws sso login` or update `~/.aws/credentials` with valid keys. |
| 29 | **Certificate Validation Failed** | ACM status stuck in `Pending validation` | Missing DNS CNAME validation record in Route53. | Copy ACM validation CNAME record into Route53 Public Hosted Zone to complete domain verification. |
| 30 | **HTTPS Not Working** | Browser warning: `Connection Not Secure` | ALB listener missing 443 HTTPS binding or cert. | Add HTTPS Listener on ALB port 443, attach ACM SSL certificate, configure HTTP to HTTPS redirect. |
| 31 | **SSL Mismatch** | `SSL_ERROR_BAD_CERT_DOMAIN` | Domain name does not match ACM SAN name. | Re-issue ACM certificate including wildcard domain (`*.banking.example.com`). |
| 32 | **App Crash on Startup** | Process exits immediately on start | Missing mandatory environment variables. | Verify `.env` configuration file presence and mandatory database environment variables. |
| 33 | **Environment Variables Missing** | `TypeError: Cannot read property of undefined` | Secrets Manager variables not injected. | Inject secrets at runtime via user-data script or AWS Parameter Store integration. |
| 34 | **DB Migration Failed** | Deploy pipeline fails on schema update | Schema lock or syntax error in SQL migration script. | Inspect migration log, unlock migration table (`SELECT RELEASE_LOCK()`), test migration locally. |
| 35 | **Git Merge Conflicts** | Deployment blocked by git conflict markers | Concurrent edits on identical file lines. | Resolve conflicts locally using `git merge --abort` or git rebase, commit clean state. |
| 36 | **GitHub Auth Failed** | `Permission denied (publickey)` | Expired SSH key or missing GitHub Personal Access Token. | Add SSH key to `ssh-agent` (`ssh-add ~/.ssh/id_ed25519`) or refresh GitHub PAT token permissions. |

---

## 🔍 Common Linux Troubleshooting

```bash
# 1. Identify network listeners and open sockets
lsof -i -P -n | grep LISTEN
ss -tulnp

# 2. Force terminate unresponsive process
kill -9 <PID>

# 3. PM2 Process Manager Monitoring & Logs
pm2 status
pm2 logs banking-backend --lines 50
pm2 restart banking-backend

# 4. Systemd Service Auditing
systemctl status nginx.service
systemctl restart nginx.service
journalctl -u nginx.service --since "1 hour ago"

# 5. Resource Utilization Inspection
df -h                   # Human readable disk space
free -m                 # RAM usage in Megabytes
uptime                  # Load average overview
top                     # System process snapshot

# 6. Real-time Log Streaming
tail -f /var/log/nginx/access.log /var/log/nginx/error.log

# 7. Endpoint Connectivity & Health Testing
curl -Iv http://localhost:8080/health
ping -c 4 db.internal.banking.com
telnet 10.0.5.10 3306
nc -zvw3 10.0.5.10 5432

# 8. DNS Lookup Troubleshooting
dig +trace banking.example.com
nslookup db.internal.banking.com

# 9. Database Direct Connection Verification
mysql -h db.internal.banking.com -u bank_user -p -e "SHOW STATUS LIKE 'Ssl_cipher';"
```

---

## 📂 Folder Structure

```
AWS_CLOUD/
├── .github/
│   └── workflows/
│       ├── ci-cd-pipeline.yml         # GitHub Actions deployment automation
│       └── security-scan.yml          # Trivy & Checkov IaC security scanning
├── assets/
│   └── aws_banner.png                 # Enterprise 3-Tier Architecture visual diagram
├── app/
│   ├── api/
│   │   ├── package.json               # Backend Node.js service dependencies
│   │   ├── server.js                  # Express API server & health check endpoints
│   │   └── Dockerfile                 # Container manifest for local testing
│   ├── web/
│   │   ├── nginx.conf                 # Nginx reverse proxy & security headers conf
│   │   └── index.html                 # Frontend presentation application landing
│   └── db/
│       ├── schema.sql                 # Initial database table schema
│       └── migrations/                # Database versioned migration scripts
├── infrastructure/
│   ├── scripts/
│   │   ├── user_data_web.sh           # Nginx Web Tier bootstrap user-data
│   │   └── user_data_app.sh           # Node.js App Tier bootstrap user-data
│   ├── vpc/
│   │   ├── main.tf                    # VPC, Subnets, IGW, NAT Gateways IaC
│   │   └── variables.tf               # CIDR & Subnet layout variables
│   ├── alb/
│   │   ├── alb.tf                     # Application Load Balancer & Target Groups
│   │   └── acm.tf                     # ACM SSL Certificate provisioning
│   ├── ec2/
│   │   ├── launch_templates.tf        # Launch templates for Web & App fleets
│   │   └── auto_scaling.tf            # ASG policies & health check triggers
│   └── rds/
│       └── rds_multi_az.tf            # Amazon RDS Multi-AZ DB Cluster IaC
├── monitoring/
│   ├── cloudwatch_dashboard.json      # CloudWatch centralized metrics dashboard
│   └── alarms_config.json             # Alarm threshold & SNS alert definitions
├── docs/
│   ├── architecture_spec.md           # Detailed architecture design document
│   └── runbooks/
│       ├── incident_response.md       # Production outage incident runbook
│       └── disaster_recovery.md        # RDS failover & restoration guide
└── README.md                          # Master Enterprise Documentation
```

---

## ⭐ Key Features

- 🟢 **High Availability**: 99.99% multi-AZ fault tolerant deployment.
- ⚡ **Auto Scaling**: Automated horizontal compute fleet expansion.
- ⚖️ **Load Balancing**: Layer 7 traffic routing with cross-zone balancing.
- 📊 **Cloud Monitoring**: Integrated CloudWatch metrics, alarms, and dashboards.
- 📜 **Centralized Logging**: CloudWatch log aggregation with audit trails.
- 🔒 **HTTPS & TLS 1.3**: ACM certificate offloading with strict cipher suites.
- 🚀 **Scalable**: Multi-tier architecture capable of scaling to millions of hits.
- 🛡️ **Highly Secure**: Micro-segmented subnets, zero public DB access, WAF security.
- 🚑 **Fault Tolerant**: Automatic health probes and self-healing infrastructure.
- 🏭 **Production Ready**: Fully documented enterprise repository structure.

---

## 🧠 Skills Demonstrated

`AWS Cloud Engineering` • `DevOps Practice` • `Linux Systems Administration` • `VPC Networking` • `Cloud Security & Compliance` • `Layer-7 Load Balancing` • `Auto Scaling & Elasticity` • `DNS Management (Route53)` • `SSL/TLS Encryption` • `Monitoring & Observability` • `Troubleshooting & Forensics` • `Infrastructure Automation` • `Cloud Operations`

---

## 🔮 Future Improvements

- 🏗️ **Full Terraform & CloudFormation Provisioning**: Modularize 100% of infrastructure as code.
- 📦 **Containerization with Docker**: Containerize API services for uniform dev/prod environments.
- ☸️ **Amazon EKS Migration**: Migrate EC2 app tiers to Kubernetes (EKS) with Helm charts.
- 🤖 **GitOps CI/CD Pipelines**: Implement automated GitOps workflows via AWS CodePipeline or Jenkins.
- 🔵🟢 **Blue/Green & Canary Deployments**: Implement AWS CodeDeploy blue/green traffic shifting.
- 📊 **Advanced Observability Stack**: Integrate Prometheus and Grafana dashboards for deep metric insights.

---

<div align="center">

### 👨‍💻 Maintained by Senior Cloud & DevOps Engineering Team

*Crafted with best practices from the AWS Well-Architected Framework.*

</div>
