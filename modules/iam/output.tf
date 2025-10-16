output "ecs_task_exec_role_arn" {
  value       = aws_iam_role.ecs_task_exec.arn
  description = "IAM Role ARN for ECS task execution"
}

output "cicd_deploy_role_arn" {
  value       = aws_iam_role.cicd_deploy.arn
  description = "IAM Role ARN for CI/CD deployment"
}

output "monitoring_role_arn" {
  value       = aws_iam_role.monitoring.arn
  description = "IAM Role ARN for monitoring access"
}

output "secrets_policy_arn" {
  value       = aws_iam_policy.ecs_secrets_read.arn
  description = "IAM Policy ARN granting ECS access to secrets"
}
