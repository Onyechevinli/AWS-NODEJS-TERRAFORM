###########################################
# IAM Module — ECS, CI/CD & Monitoring Roles
###########################################

# ECS Task Execution Role
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_exec" {
  name               = "${var.app_name}-ecs-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

# Attach Amazon ECS Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for Secrets Manager read (least privilege)
data "aws_iam_policy_document" "ecs_secrets_read" {
  statement {
    actions = ["secretsmanager:GetSecretValue", "kms:Decrypt"]
    resources = var.secrets_arns
  }
}

resource "aws_iam_policy" "ecs_secrets_read" {
  name   = "${var.app_name}-ecs-secrets-read"
  policy = data.aws_iam_policy_document.ecs_secrets_read.json
}

resource "aws_iam_role_policy_attachment" "ecs_attach_secrets" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = aws_iam_policy.ecs_secrets_read.arn
}

###########################################
# CI/CD Deployment Role (GitHub Actions or CodePipeline)
###########################################

data "aws_iam_policy_document" "cicd_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = var.cicd_principal_identifiers
    }
  }
}

resource "aws_iam_role" "cicd_deploy" {
  name               = "${var.app_name}-cicd-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.cicd_assume_role.json

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

data "aws_iam_policy_document" "cicd_policy" {
  statement {
    sid     = "ECRPushAccess"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "ECSDeployAccess"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeClusters"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "CloudWatchLogsAccess"
    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cicd_policy" {
  name   = "${var.app_name}-cicd-deploy-policy"
  policy = data.aws_iam_policy_document.cicd_policy.json
}

resource "aws_iam_role_policy_attachment" "cicd_attach_policy" {
  role       = aws_iam_role.cicd_deploy.name
  policy_arn = aws_iam_policy.cicd_policy.arn
}

###########################################
# Monitoring Role (Read-only)
###########################################

data "aws_iam_policy_document" "monitor_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  name               = "${var.app_name}-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.monitor_assume_role.json
}

resource "aws_iam_role_policy_attachment" "monitor_attach" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
