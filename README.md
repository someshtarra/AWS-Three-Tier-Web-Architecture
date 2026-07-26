<div align="center">

# 📚 MindCircuit Book Store – AWS 3-Tier Architecture
### 🚀 Production-Ready Three-Tier Cloud Infrastructure

[![AWS Architecture](https://img.shields.io/badge/AWS-3--Tier_Architecture-ff9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![DevOps Ready](https://img.shields.io/badge/DevOps-Production_Grade-0052cc?style=for-the-badge&logo=azure-devops&logoColor=white)](https://aws.amazon.com/devops/)
[![High Availability](https://img.shields.io/badge/Availability-99.99%25_Multi--AZ-00d26a?style=for-the-badge&logo=statuspage&logoColor=white)](#high-availability-design)
[![Security Compliance](https://img.shields.io/badge/Security-Private_Subnets_&_NACL-red?style=for-the-badge&logo=shield&logoColor=white)](#security-architecture)
[![IaC Ready](https://img.shields.io/badge/IaC-Terraform_&_CloudFormation-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](#future-improvements)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

---

![MindCircuit Book Store AWS 3-Tier Architecture Banner](assets/aws_banner.png)

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

This repository demonstrates the deployment of a **highly available, secure, scalable, fault-tolerant, and production-grade MindCircuit Book Store application on AWS** using a strict **Three-Tier Architecture** following DevOps best practices and the **AWS Well-Architected Framework**.

The application is deployed inside a dedicated **Amazon VPC (`10.20.0.0/16`)** spanned across two Availability Zones (`us-east-1a` and `us-east-1b`):

1. **Presentation Tier (Frontend)**: React + Apache web servers hosted in Private Subnets (`10.20.3.0/24` & `10.20.4.0/24`), fronted by **Frontend ALB** and public DNS endpoint **`virat.rebel7781.xyz`**.
2. **Application Tier (Backend)**: Node.js + Express + PM2 API services hosted in Private Subnets (`10.20.5.0/24` & `10.20.6.0/24`), fronted by **Backend ALB** and public API endpoint **`api.rebel7781.xyz`**.
3. **Database Tier (Data)**: Amazon RDS MySQL Multi-AZ Database Cluster (DB Name: `test`) isolated in Private Subnets (`10.20.7.0/24` & `10.20.8.0/24`), resolved internally via Private Hosted Zone endpoint **`book.rbs.com`**.

---

## 📐 Architecture Diagram

### 🏗️ MindCircuit Book Store - AWS 3-Tier Network Topology

```
                                      +--------------------------------------------------------+
                                      |                     INTERNET USERS                     |
                                      +---------------------------+----------------------------+
                                                                  |
                                                                  | HTTPS (Port 443)
                                                                  v
                                      +--------------------------------------------------------+
                                      |            AMAZON ROUTE 53 PUBLIC HOSTED ZONE          |
                                      |                  Domain: rebel7781.xyz                 |
                                      |   • virat.rebel7781.xyz  ==> Frontend ALB (React+Apache)|
                                      |   • api.rebel7781.xyz    ==> Backend ALB (Node.js+PM2) |
                                      +---------------------------+----------------------------+
                                                                  |
                                                                  v
                                      +--------------------------------------------------------+
                                      |               INTERNET GATEWAY (IGW)                   |
                                      +---------------------------+----------------------------+
                                                                  |
  ================================================================|===============================================================
  VPC: 10.20.0.0/16                                               v
  ================================================================================================================================
  
        +----------------------------------------------------+        +----------------------------------------------------+
        | AVAILABILITY ZONE A (us-east-1a)                   |        | AVAILABILITY ZONE B (us-east-1b)                   |
        +----------------------------------------------------+        +----------------------------------------------------+
        
  --- [ PUBLIC SUBNET 10.20.1.0/24 (AZ-a) ] ------------------        --- [ PUBLIC SUBNET 10.20.2.0/24 (AZ-b) ] ------------------
  |                                                          |        |                                                          |
  |   +-------------------+          +-------------------+   |        |   +-------------------+          +-------------------+   |
  |   | Frontend ALB      |          | NAT Gateway (AZ-a)|   |        |   | Frontend ALB      |          | NAT Gateway (AZ-b)|   |
  |   +---------+---------+          +---------+---------+   |        |   +---------+---------+          +---------+---------+   |
  ----------------|----------------------------|--------------        --------------|----------------------------|--------------
                  |                            |                                    |                            |
                  v                            |                                    v                            |
  --- [ PRESENTATION TIER (FRONTEND) PRIVATE SUBNET ] -------        --- [ PRESENTATION TIER (FRONTEND) PRIVATE SUBNET ] -------
  | Private Subnet: 10.20.3.0/24 (AZ-a)                      |        | Private Subnet: 10.20.4.0/24 (AZ-b)                      |
  |                                                          |        |                                                          |
  |   +--------------------------------------------------+   |        |   +--------------------------------------------------+   |
  |   | Frontend EC2 Instances (React + Apache)          |   |        |   | Frontend EC2 Instances (React + Apache)          |   |
  |   +------------------------+-------------------------+   |        |   +------------------------+-------------------------+   |
  -----------------------------|------------------------------        -----------------------------|------------------------------
                               | Internal Backend Traffic                                          |
                               v                                                                   v
  --- [ APPLICATION TIER (BACKEND) PRIVATE SUBNET ] ----------        --- [ APPLICATION TIER (BACKEND) PRIVATE SUBNET ] ----------
  | Private Subnet: 10.20.5.0/24 (AZ-a)                      |        | Private Subnet: 10.20.6.0/24 (AZ-b)                      |
  |                                                          |        |                                                          |
  |   +--------------------------------------------------+   |        |   +--------------------------------------------------+   |
  |   | Backend EC2 Instances (Node.js + Express + PM2)  |   |        |   | Backend EC2 Instances (Node.js + Express + PM2)  |   |
  |   +------------------------+-------------------------+   |        |   +------------------------+-------------------------+   |
  -----------------------------|------------------------------        -----------------------------|------------------------------
                               | Private Database Query (Port 3306)                                |
                               +-----------------------------+-------------------------------------+
                                                             |
                                                             v
  --- [ DATABASE TIER PRIVATE SUBNET ] -------------------------------------------------------------------------------------------
  | Private Subnet 10.20.7.0/24 (AZ-a)                      | Private Subnet 10.20.8.0/24 (AZ-b)                              |
  |                                                          |                                                                  |
  |   +---------------------------------------------------------------------------------------------------------------------+   |
  |   |                        AMAZON RDS MYSQL (MULTI-AZ) DATABASE CLUSTER                                                |   |
  |   |                        DB Name: test  |  Private DNS: book.rbs.com (rbs.com zone)                                |   |
  |   +---------------------------------------------------------------------------------------------------------------------+   |
  --------------------------------------------------------------------------------------------------------------------------------
```

---

## 🛠️ AWS Services Used

| AWS Service | Category | Purpose in MindCircuit Architecture | Real-World Usage |
| :--- | :--- | :--- | :--- |
| **Amazon VPC** | Networking | Virtual private cloud enclosure | Isolated network (`10.20.0.0/16`) spanning AZ-a and AZ-b. |
| **Public Subnets** | Networking | Ingress for Load Balancers & NAT | Hosts Public Subnets `10.20.1.0/24` (AZ-a) and `10.20.2.0/24` (AZ-b). |
| **Private Subnets** | Networking | Workload isolation | Segregates Frontend (`10.20.3.0/24`, `10.20.4.0/24`), Backend (`10.20.5.0/24`, `10.20.6.0/24`), and DB (`10.20.7.0/24`, `10.20.8.0/24`). |
| **Internet Gateway** | Networking | External internet entrypoint | Connects Public Subnets directly to external user traffic. |
| **NAT Gateway** | Networking | Outbound outbound egress | Redundant NAT Gateways in `10.20.1.0/24` & `10.20.2.0/24` for OS updates. |
| **Application Load Balancer (ALB)** | Networking | Layer 7 load balancing | **Frontend ALB** (`virat.rebel7781.xyz`) & **Backend ALB** (`api.rebel7781.xyz`). |
| **Amazon EC2 (Frontend)** | Compute | Presentation Tier nodes | Serves React UI static content via Apache Web Server in private subnets. |
| **Amazon EC2 (Backend)** | Compute | Application Tier nodes | Executes Node.js + Express API microservices managed by PM2 process manager. |
| **Amazon RDS MySQL** | Database | Multi-AZ Relational Storage | Managed MySQL DB Cluster (DB Name: `test`) with auto-failover in `10.20.7.0/24` & `10.20.8.0/24`. |
| **Route 53 Public Zone** | DNS | Domain routing for external users | Resolves `rebel7781.xyz` (`virat.rebel7781.xyz` & `api.rebel7781.xyz`). |
| **Route 53 Private Zone** | DNS | Internal private DNS resolution | Resolves `rbs.com` internal zone (`book.rbs.com` -> RDS Endpoint). |
| **Auto Scaling Group** | Compute | Elastic compute capacity | Auto-scales EC2 nodes based on CPU & traffic load across AZ-a and AZ-b. |
| **AWS ACM** | Security | SSL/TLS Certificate Manager | Manages HTTPS TLS 1.3 certificates for ALB listeners. |
| **Security Groups** | Security | Stateful micro-segmentation | Controls port-level ingress (`80`, `443`, `8080`, `3306`) between tiers. |
| **Network ACLs** | Security | Stateless subnet boundary security | Subnet-level network filtering acting as defense-in-depth. |
| **Amazon CloudWatch** | Monitoring | Log & metric monitoring | Centralizes CPU, memory, disk, network metrics, and logs. |
| **AWS CLI** | Management | Cloud automation scripting | Programmatic deployment and infrastructure management. |

---

## 🌐 Network Architecture

The network layout uses the dedicated **`10.20.0.0/16`** CIDR block structured as follows:

```
VPC CIDR: 10.20.0.0/16
├── Public Subnet 10.20.1.0/24 (AZ-a)  --> NAT Gateway 1A, Public ALB Listener
├── Public Subnet 10.20.2.0/24 (AZ-b)  --> NAT Gateway 1B, Public ALB Listener
├── Private Subnet 10.20.3.0/24 (AZ-a) --> Presentation Tier (React + Apache)
├── Private Subnet 10.20.4.0/24 (AZ-b) --> Presentation Tier (React + Apache)
├── Private Subnet 10.20.5.0/24 (AZ-a) --> Application Tier (Node.js + Express + PM2)
├── Private Subnet 10.20.6.0/24 (AZ-b) --> Application Tier (Node.js + Express + PM2)
├── Private Subnet 10.20.7.0/24 (AZ-a) --> Database Tier (Amazon RDS MySQL Master)
└── Private Subnet 10.20.8.0/24 (AZ-b) --> Database Tier (Amazon RDS MySQL Standby)
```

### 📍 Route 53 DNS Architecture

1. **Public Hosted Zone (`rebel7781.xyz`)**:
   - `virat.rebel7781.xyz` $\rightarrow$ Frontend Application Load Balancer
   - `api.rebel7781.xyz` $\rightarrow$ Backend Application Load Balancer
2. **Private Hosted Zone (`rbs.com`)**:
   - `book.rbs.com` $\rightarrow$ Amazon RDS MySQL Endpoint (DB Name: `test`)

---

## ⚡ High Availability Design

- **Multi-AZ Deployment**: EC2 fleets and RDS DB nodes are deployed across `us-east-1a` and `us-east-1b`.
- **Dual Load Balancers**: Separate **Frontend ALB** and **Backend ALB** ensure microservices isolation.
- **Target Group Health Checks**: Active `/healthz` HTTP probes check node status every 15 seconds.
- **RDS Multi-AZ Failover**: Automatic synchronous replication to standby node in `10.20.8.0/24` with 60-second DNS failover.

---

## 🔒 Security Architecture

- **Private Subnet Placement**: All Frontend EC2s, Backend EC2s, and RDS MySQL DB nodes run inside isolated private subnets with zero direct public internet exposure.
- **Tier-to-Tier Ingress Rules**:
  - `Frontend-SG`: Accepts traffic only from `Frontend-ALB` on HTTP/HTTPS.
  - `Backend-SG`: Accepts traffic only from `Backend-ALB` on port `8080`.
  - `DB-SG`: Accepts MySQL traffic (port `3306`) strictly from `Backend-SG`.
- **Egress Control**: Private nodes access external APIs/updates exclusively via **NAT Gateways** (`10.20.1.0/24` & `10.20.2.0/24`).

---

## 💾 Storage Layer

- **Amazon EBS**: Encrypted `gp3` root volumes for Frontend & Backend EC2 nodes.
- **Amazon RDS MySQL**: Multi-AZ storage auto-scaling up to 500GB with automated daily snapshots and 35-day Point-In-Time Recovery (PITR).

---

## 📊 Monitoring & Observability

- **CloudWatch Dashboards**: Metrics tracking CPU Utilization, ALB Request Counts, 5XX errors, and MySQL active DB connections.
- **PM2 Log Management**: Real-time process logging and automatic restarts for backend Node.js services.

---

## 🚀 Deployment Workflow

```
Developer Push ──> GitHub ──> Build ──> Launch Template ──> ASG ──> Frontend / Backend ALB ──> EC2 ──> RDS MySQL
```

---

## 💻 AWS CLI Commands

<details>
<summary><b>Click to view AWS CLI Reference Commands for 10.20.0.0/16 Network</b></summary>

```bash
# Describe VPC Subnets in 10.20.0.0/16 network
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-10200000" \
  --query "Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key=='Name'].Value|[0]]" \
  --output table

# Verify RDS MySQL Multi-AZ Status
aws rds describe-db-instances \
  --db-instance-identifier banking-prod-db \
  --query "DBInstance.[DBInstanceIdentifier,DBName,Endpoint.Address,MultiAZ,DBInstanceStatus]"

# Query Route 53 Resource Record Sets for rebel7781.xyz
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890 \
  --query "ResourceRecordSets[?Name=='virat.rebel7781.xyz.' || Name=='api.rebel7781.xyz.']"
```

</details>

---

## 🐧 Linux Administration

```bash
# PM2 Process Manager Commands (Application Tier)
pm2 status
pm2 logs backend-api
pm2 restart backend-api

# Network Socket Auditing on Backend (Port 8080 / 3306)
ss -tulnp | grep 8080
lsof -i :8080

# Systemd & Journalctl Logging
systemctl status apache2
journalctl -u nodejs-api -n 50 --no-pager
```

---

## 🔧 DevOps Troubleshooting

| # | Issue | Symptoms | Root Cause | Resolution Strategy |
| :---: | :--- | :--- | :--- | :--- |
| 1 | **RDS Connection Timeout** | Backend logs `ETIMEDOUT` to `book.rbs.com` | `DB-SG` missing ingress rule for `Backend-SG` on port 3306. | Update MySQL SG to allow port 3306 from `Backend-SG` (`10.20.5.0/24`, `10.20.6.0/24`). |
| 2 | **502 Bad Gateway** | `virat.rebel7781.xyz` returns 502 | Apache/React server crashed in `10.20.3.0/24`. | Check Apache service (`systemctl status apache2`), verify port 80 bound. |
| 3 | **DNS Resolution Failure** | Cannot resolve `book.rbs.com` | Private Hosted Zone `rbs.com` not associated with VPC `10.20.0.0/16`. | Associate `rbs.com` Private Hosted Zone to VPC `10.20.0.0/16`. |
| 4 | **NAT Gateway Egress Failure** | Private EC2 cannot fetch `apt-get` updates | Route table for `10.20.3.0/24` missing `0.0.0.0/0` -> NAT GW. | Add route `0.0.0.0/0` -> NAT Gateway in private route table. |

---

## 📂 Folder Structure

```
AWS_CLOUD/
├── .github/
│   └── workflows/
│       └── ci-cd-pipeline.yml         # GitHub Actions deployment automation
├── assets/
│   └── aws_banner.png                 # MindCircuit Book Store 3-Tier Architecture Diagram
├── app/
│   ├── api/
│   │   ├── package.json               # Backend Node.js service dependencies
│   │   └── server.js                  # Express API server & health check endpoints
│   ├── web/
│   │   ├── nginx.conf                 # Apache / Nginx reverse proxy config
│   │   └── index.html                 # Frontend React presentation landing page
│   └── db/
│       └── schema.sql                 # MySQL initial database table schema (DB: test)
├── infrastructure/
│   ├── scripts/
│   │   ├── user_data_web.sh           # Frontend React + Apache user-data
│   │   └── user_data_app.sh           # Backend Node.js + Express + PM2 user-data
│   ├── vpc/
│   │   └── main.tf                    # VPC 10.20.0.0/16 & Subnet layout IaC
│   ├── alb/
│   │   └── alb.tf                     # Frontend & Backend ALB Terraform module
│   ├── ec2/
│   │   └── auto_scaling.tf            # ASG policies & Launch Templates
│   └── rds/
│       └── rds_multi_az.tf            # Amazon RDS MySQL Multi-AZ cluster (DB: test)
├── monitoring/
│   └── cloudwatch_dashboard.json      # CloudWatch centralized metrics dashboard
├── docs/
│   └── runbooks/
│       ├── incident_response.md       # Incident response runbook
│       └── disaster_recovery.md        # RDS failover runbook
└── README.md                          # Master Enterprise Documentation
```

---

## ⭐ Key Features

- 🟢 **High Availability**: Multi-AZ deployment across `us-east-1a` & `us-east-1b`.
- ⚡ **Auto Scaling**: Elastic compute scaling for React & Node.js tiers.
- ⚖️ **Dual ALB Traffic Routing**: Separate Frontend ALB (`virat.rebel7781.xyz`) & Backend ALB (`api.rebel7781.xyz`).
- 🗺️ **Dual Route 53 Zones**: Public Hosted Zone (`rebel7781.xyz`) & Private Hosted Zone (`rbs.com`).
- 🗄️ **Managed MySQL Multi-AZ**: Amazon RDS MySQL (DB Name: `test`, Endpoint: `book.rbs.com`).
- 🔒 **Zero Public Workload Exposure**: All EC2 & DB instances isolated in Private Subnets (`10.20.3.0/24` - `10.20.8.0/24`).

---

## 🧠 Skills Demonstrated

The following enterprise skills, AWS Console management workflows, and Linux administration capabilities are fully implemented and demonstrated in this repository:

<details open>
<summary><b>1. ☁️ AWS Networking & Core Infrastructure Skills</b></summary>

- 📐 **AWS Architecture Diagram**: End-to-end design of 3-tier, multi-AZ enterprise cloud architecture following AWS Well-Architected Framework.
- 🏢 **VPC Dashboard**: Provisioning virtual private cloud topologies, IPv4 CIDR allocation (`10.20.0.0/16`), and DNS hostnames.
- 🔀 **Public & Private Subnets**: Micro-segmenting public subnets (`10.20.1.0/24`, `10.20.2.0/24`) and private subnets (`10.20.3.0/24` to `10.20.8.0/24`).
- 🛣️ **Route Tables**: Managing public IGW default routing and private NAT Gateway egress route tables across multiple Availability Zones.
- 🌍 **Internet Gateway (IGW)**: Attaching IGW for public subnet internet access and Application Load Balancer entrypoints.
- 🛰️ **NAT Gateway**: Deploying redundant NAT Gateways in `10.20.1.0/24` & `10.20.2.0/24` for outbound private subnet connectivity.
- 🛡️ **Security Groups**: Authorizing stateful micro-segmented firewall rules at the EC2, ALB, and RDS interface levels.
- 🔒 **Network ACLs (NACLs)**: Enforcing stateless subnet-boundary security policies for network isolation.

</details>

<details open>
<summary><b>2. 💻 Compute, Elasticity & Traffic Engineering Skills</b></summary>

- 🖥️ **EC2 Instances**: Provisioning stateless Frontend (React + Apache) and Backend (Node.js + Express + PM2) EC2 fleets across `us-east-1a` and `us-east-1b`.
- 📀 **AMIs (Amazon Machine Images)**: Automated Golden AMI creation pre-configured with security patches and application runtimes.
- 📜 **Launch Template**: Versioning Launch Templates standardizing instance types, IAM profiles, and user-data boot scripts.
- 📈 **Auto Scaling Group (ASG)**: Dynamic target-tracking scaling policies, instance refresh automation, and rolling deployments.
- ⚖️ **Load Balancers (Frontend & Backend ALB)**: Dual Layer-7 Load Balancers routing `virat.rebel7781.xyz` and `api.rebel7781.xyz`.
- 🩺 **Target Group Health Checks**: Active `/healthz` HTTP health probes (15s interval, 3 consecutive check threshold for deregistration).

</details>

<details open>
<summary><b>3. 🌐 Edge, DNS, Security & Delivery Skills</b></summary>

- 🗺️ **Route 53 Hosted Zones**: Public Hosted Zone (`rebel7781.xyz`) and Private Hosted Zone (`rbs.com`).
- 🔐 **ACM Certificate**: Provisioning, attaching, and automatically renewing SSL/TLS 1.3 certificates via AWS Certificate Manager.
- ⚡ **CloudFront Distribution**: Global edge caching and static asset distribution integrated with AWS WAF for perimeter defense.

</details>

<details open>
<summary><b>4. 💾 Database, Storage & Identity Skills</b></summary>

- 🗄️ **RDS Instance**: Amazon RDS MySQL Multi-AZ DB Cluster (DB Name: `test`, Endpoint: `book.rbs.com`).
- 📂 **RDS Subnet Group**: Restricting database instances strictly inside isolated private DB subnets (`10.20.7.0/24` & `10.20.8.0/24`).
- 📁 **EFS File System**: Provisioning shared POSIX-compliant Amazon Elastic File System (EFS) mounted across multi-AZ EC2 fleets.
- 👤 **IAM Users, Groups & Roles**: Enforcing Least Privilege access, role-based EC2 instance profiles, and strict IAM policies.

</details>

<details open>
<summary><b>5. 📊 Observability, Governance & Terminal Administration Skills</b></summary>

- 📊 **CloudWatch Dashboard**: Centralizing CPU, memory, disk, network metrics, and custom log alarm notifications.
- 🕵️ **CloudTrail Event History**: Auditing management and data API calls across the AWS account for compliance and forensics.
- 🖥️ **AWS CLI Terminal Output**: Operational scripting and administration using `aws ec2`, `aws elbv2`, `aws autoscaling`, `aws rds`, and `aws cloudwatch`.
- 🐧 **Linux Terminal (PM2, systemctl, journalctl, ss, lsof)**: Process management with PM2 (`pm2 status`, `pm2 logs`), service orchestration (`systemctl`), and port auditing (`ss -tulnp`, `lsof`).

</details>

---

## 🔮 Future Improvements

- 🏗️ **Full Terraform & CloudFormation Provisioning**: Modularize 100% of infrastructure as code.
- 📦 **Containerization with Docker**: Containerize API services for uniform dev/prod environments.
- ☸️ **Amazon EKS Migration**: Migrate EC2 app tiers to Kubernetes (EKS) with Helm charts.
- 🤖 **GitOps CI/CD Pipelines**: Implement automated GitOps workflows via AWS CodePipeline or Jenkins.

---

<div align="center">

### 👨‍💻 Maintained by Senior Cloud & DevOps Engineering Team

*Crafted with best practices from the AWS Well-Architected Framework.*

</div>
