############################################
# Root Variables
############################################

variable "aws_region" {
  description = "AWS region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "nodejs-app"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# IAM
variable "secrets_arns" {
  description = "Secrets Manager ARNs accessible by ECS tasks"
  type        = list(string)
  default     = []
}

variable "cicd_principal_identifiers" {
  description = "List of principals (OIDC or AWS services) for CI/CD role"
  type        = list(string)
  default     = ["codepipeline.amazonaws.com"]
}

# ECS
variable "image" {
  description = "Docker image for Node.js app (e.g., ECR URI)"
  type        = string
}
variable "container_image" {
  description = "Docker image for Node.js app (e.g., ECR URI)"
  type        = string
}

variable "container_port" {
  description = "Application port exposed by the container"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
}

# RDS
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable RDS multi-AZ"
  type        = bool
  default     = true
}

variable "db_allocated_storage" {
  description = "Initial RDS storage size (GB)"
  type        = number
  default     = 20
}

# Monitoring
variable "sns_alert_emails" {
  description = "Email addresses for CloudWatch/SNS alerts"
  type        = list(string)
  default     = []
}

# Add your variable declarations here
variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for monitoring notifications"
  type        = string
}
variable "service_name" {
  description = "The name of the ECS service to monitor"
  type        = string
  default     = "${var.app_name}-service"
}