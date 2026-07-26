# ==============================================================================
# Enterprise AWS Three-Tier Architecture - VPC & Networking Module
# VPC CIDR: 10.20.0.0/16 | Topology: Enterprise Banking Platform AWS 3-Tier Architecture
# ==============================================================================

provider "aws" {
  region = var.aws_region
}

# Master VPC Definition (10.20.0.0/16)
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "banking-prod-vpc"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "banking-prod-igw"
  }
}

# Public Subnets (ALB & NAT Gateways)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "banking-public-subnet-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "banking-public-subnet-1b"
  }
}

# Presentation Tier (Frontend React + Apache) Private Subnets
resource "aws_subnet" "private_frontend_3a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "banking-private-frontend-3a"
  }
}

resource "aws_subnet" "private_frontend_3b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "banking-private-frontend-3b"
  }
}

# Application Tier (Backend Node.js + Express + PM2) Private Subnets
resource "aws_subnet" "private_backend_5a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.5.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "banking-private-backend-5a"
  }
}

resource "aws_subnet" "private_backend_5b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.6.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "banking-private-backend-5b"
  }
}

# Database Tier (Amazon RDS MySQL Multi-AZ) Private Subnets
resource "aws_subnet" "private_db_7a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.7.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "banking-private-db-7a"
  }
}

resource "aws_subnet" "private_db_7b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.8.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "banking-private-db-7b"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip_1a" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_1b" {
  domain = "vpc"
}

# Redundant NAT Gateways
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "banking-nat-gw-1a"
  }
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_eip_1b.id
  subnet_id     = aws_subnet.public_1b.id

  tags = {
    Name = "banking-nat-gw-1b"
  }
}
