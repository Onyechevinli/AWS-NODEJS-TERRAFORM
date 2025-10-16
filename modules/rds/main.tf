############################################
# RDS Module — Highly Available Database
############################################

# Create DB subnet group (for private subnets)
resource "aws_db_subnet_group" "this" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  description = "Subnet group for ${var.app_name} RDS"

  tags = {
    Name        = "${var.app_name}-db-subnet-group"
    Environment = var.environment
  }
}

# Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-rds-sg"
  description = "Security group for ${var.app_name} RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic from ECS or App Security Group"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-rds-sg"
    Environment = var.environment
  }
}

# RDS Parameter Group (optional tuning)
resource "aws_db_parameter_group" "this" {
  name        = "${var.app_name}-db-params"
  family      = var.db_family
  description = "Parameter group for ${var.app_name}"

  tags = {
    Environment = var.environment
  }
}

# Create RDS instance (multi-AZ, encrypted)
resource "aws_db_instance" "this" {
  identifier              = "${var.app_name}-rds"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = var.db_port
  multi_az                = var.multi_az
  storage_encrypted       = true
  backup_retention_period = var.backup_retention
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = var.apply_immediately
  db_subnet_group_name    = aws_db_subnet_group.this.name
  parameter_group_name    = aws_db_parameter_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = false

  tags = {
    Name        = "${var.app_name}-rds"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
