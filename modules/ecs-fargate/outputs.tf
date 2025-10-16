output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.service.name
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_exec.arn
}
