############################################
# Root Terraform Configuration
# Infrastructure for Node.js Web App on AWS
############################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "nodejs-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

############################################
# Networking / VPC Module
############################################

module "vpc" {
  source               = "./modules/vpc"
  app_name             = var.app_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

############################################
# IAM Module
############################################

module "iam" {
  source                    = "./modules/iam"
  app_name                  = var.app_name
  environment               = var.environment
  secrets_arns              = var.secrets_arns
  cicd_principal_identifiers = var.cicd_principal_identifiers
}

############################################
# ECS Module (Container Orchestration)
############################################

module "ecs" {
  source          = "./modules/ecs"
  cluster_name    = "${var.app_name}-ecs-cluster"
  aws_region      = var.aws_region
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  image           = var.image
  desired_count   = var.desired_count
  service_sg      = module.iam.service_security_group_id
}

############################################
# RDS Module (Database)
############################################

module "rds" {
  source                 = "./modules/rds"
  app_name               = var.app_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnets
  allowed_security_groups = [module.ecs.service_security_group_id]
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  multi_az               = var.db_multi_az
  allocated_storage      = var.db_allocated_storage
}

############################################
# Monitoring Module
############################################

module "monitoring" {
  source              = "./modules/monitoring"
  app_name            = var.app_name
  environment         = var.environment
  alb_name            = "${var.app_name}-alb"
  sns_topic_arn       = var.sns_topic_arn
  aws_region          = var.aws_region
  cluster_name        = module.ecs.cluster_name
  service_name        = var.service_name
}