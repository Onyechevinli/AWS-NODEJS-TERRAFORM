############################################
# Root Outputs
############################################

output "vpc_id" {
  description = "VPC ID for the infrastructure"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "RDS endpoint for the database"
  value       = module.rds.rds_endpoint
}

output "monitoring_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "cicd_deploy_role_arn" {
  description = "IAM Role ARN for CI/CD deployments"
  value       = module.iam.cicd_deploy_role_arn
}