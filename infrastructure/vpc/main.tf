# ==============================================================================
# Enterprise AWS Three-Tier Architecture - VPC & Networking Terraform Module
# ==============================================================================

provider "aws" {
  region = var.aws_region
}

# Master VPC Definition
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
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
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "banking-public-subnet-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "banking-public-subnet-1b"
  }
}

# Private Web Subnets
resource "aws_subnet" "private_web_2a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "banking-private-web-2a"
  }
}

resource "aws_subnet" "private_web_2b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "banking-private-web-2b"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app_3a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "banking-private-app-3a"
  }
}

resource "aws_subnet" "private_app_3b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "banking-private-app-3b"
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db_4a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "banking-private-db-4a"
  }
}

resource "aws_subnet" "private_db_4b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "banking-private-db-4b"
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
