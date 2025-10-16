###########################################
# ECS Fargate Cluster, Service & Autoscale
###########################################

# Create ECR Repository
resource "aws_ecr_repository" "app" {
    name = "${var.app_name}-ecr-repository"
    image_tag_mutability = "MUTABLE"
    tags = {
        Name = "${var.app_name}-ecr_repository"
    }
    }

# ECS cluster
resource "aws_ecs_cluster" "main" {
    name = "${var.app_name}-ecs-cluster"
    tags = {
        Name = "${var.app_name}-ecs-cluster"
    }
    }

# Application load balancer
resource "aws_lb" "alb" {
    name = "${var.app_name}-alb"
    internal = false
    load_balancer_type = "application"
    subnets = var.public_subnets
    security_groups = [var.alb_sg]
    tags = {
        Name = "${var.app_name}-alb"
    }
}

resource "aws_lb_target_group" "tg" {
name = "${var.app_name}-tg"
port = var.container_port
protocol = "HTTP"
vpc_id = var.vpc_id
target_type = "ip"
health_check {
path = "/health"
interval = 30
healthy_threshold = 2
unhealthy_threshold = 2
timeout = 5
matcher = "200-399"
}
tags = {
  Name = "${var.app_name}-tg"
}
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
}
}


# Task role and execution role
resource "aws_iam_role" "ecs_task_exec" {
name = "ecs-task-exec-${var.app_name}"
assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}
resource "aws_iam_role_policy_attachment" "exec_attach" {
role = aws_iam_role.ecs_task_exec.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_ecs_task_definition" "task" {
family = "${var.app_name}-task"
requires_compatibilities = ["FARGATE"]
network_mode = "awsvpc"
cpu = var.task_cpu
memory = var.task_memory
execution_role_arn = aws_iam_role.ecs_task_exec.arn
runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
}
container_definitions = jsonencode([
{
name = "app"
image = var.image
portMappings = [{ containerPort = var.container_port, hostPort = var.container_port, protocol = "tcp" }]
logConfiguration = {
logDriver = "awslogs",
options = {
"awslogs-group" = aws_cloudwatch_log_group.ecs.name
"awslogs-region" = var.aws_region
"awslogs-stream-prefix" = "ecs"
}
}
environment = [for k, v in var.env_vars : { name = k, value = v }]
}
])
}


resource "aws_ecs_service" "service" {
    name = "${var.app_name}-svc"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.task.arn
    desired_count = var.desired_count
    launch_type = "FARGATE"
network_configuration {
    subnets = var.private_subnets
    security_groups = [var.service_sg]
    assign_public_ip = false
}
load_balancer {
target_group_arn = aws_lb_target_group.tg.arn
container_name = "app"
container_port = var.container_port
}
lifecycle {
    ignore_changes = [task_definition]
}
tags = {
    Name = "${var.app_name}-service"
}
}

# Auto-scaling for ECS service (application autoscaling)
resource "aws_appautoscaling_target" "ecs" {
service_namespace = "ecs"
resource_id = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.service.name}"
scalable_dimension = "ecs:service:DesiredCount"
min_capacity = var.min_capacity
max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "cpu" {
name = "${var.app_name}-cpu-policy"
policy_type = "TargetTrackingScaling"
resource_id = aws_appautoscaling_target.ecs.resource_id
scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
service_namespace = aws_appautoscaling_target.ecs.service_namespace
target_tracking_scaling_policy_configuration {
predefined_metric_specification {
predefined_metric_type = "ECSServiceAverageCPUUtilization"
}
target_value = 60
scale_in_cooldown = 120
scale_out_cooldown = 60
}
}