# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Amazon RDS Multi-AZ Database Cluster
# ==============================================================================

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "banking-db-subnet-group"
  subnet_ids = [var.private_db_4a_id, var.private_db_4b_id]

  tags = {
    Name = "banking-db-subnet-group"
  }
}

resource "aws_db_instance" "rds_primary" {
  identifier            = "banking-prod-db"
  allocated_storage     = 100
  max_allocated_storage = 500
  engine                = "postgres"
  engine_version        = "15.4"
  instance_class        = "db.m6i.large"

  db_name  = "banking_db"
  username = "db_admin"
  password = var.db_password

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]

  storage_encrypted   = true
  skip_final_snapshot = false
  final_snapshot_identifier = "banking-db-final-snapshot"

  backup_retention_period = 35
  backup_window           = "03:00-04:00"

  tags = {
    Name        = "banking-prod-db"
    Environment = "production"
  }
}
