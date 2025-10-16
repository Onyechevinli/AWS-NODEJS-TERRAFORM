# Create CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
name = "/ecs/${var.app_name}"
retention_in_days = 30
tags = {
Environment = var.environment
Application = var.app_name
}
}


# Create Log Group for Application Load Balancer
resource "aws_cloudwatch_log_group" "alb" {
name = "/aws/elb/${var.app_name}-alb"
retention_in_days = 30
tags = {
Environment = var.environment
Application = var.app_name
}
}


# CloudWatch Metric Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
alarm_name = "${var.app_name}-cpu-high"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "CPUUtilization"
namespace = "AWS/ECS"
period = 60
statistic = "Average"
threshold = 80
alarm_description = "Alarm when ECS CPU exceeds 80%"
dimensions = {
ClusterName = var.cluster_name
ServiceName = var.service_name
}
alarm_actions = [var.sns_topic_arn]
}


resource "aws_cloudwatch_metric_alarm" "memory_high" {
alarm_name = "${var.app_name}-memory-high"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "MemoryUtilization"
namespace = "AWS/ECS"
period = 60
statistic = "Average"
threshold = 80
alarm_description = "Alarm when ECS Memory exceeds 80%"
dimensions = {
ClusterName = var.cluster_name
}
}

# ALB Target 5xx Error Alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
alarm_name = "${var.app_name}-alb-5xx"
comparison_operator = "GreaterThanThreshold"
evaluation_periods = 2
metric_name = "HTTPCode_Target_5XX_Count"
namespace = "AWS/ApplicationELB"
period = 60
statistic = "Sum"
threshold = 10
alarm_description = "Alarm when ALB Target 5XX exceeds 10 in 2 minutes"
dimensions = {
LoadBalancer = var.alb_name
}
alarm_actions = [var.sns_topic_arn]
}


# CloudWatch Dashboard for ECS and ALB metrics
resource "aws_cloudwatch_dashboard" "app_dashboard" {
dashboard_name = "${var.app_name}-dashboard"
dashboard_body = jsonencode({
widgets = [
{
type = "metric",
x = 0,
y = 0,
width = 12,
height = 6,
properties = {
metrics = [
["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name],
["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]
],
view = "timeSeries",
stacked = false,
region = var.aws_region,
title = "ECS CPU and Memory Utilization"
}
},
{
type = "metric",
x = 0,
y = 6,
width = 12,
height = 6,
properties = {
metrics = [
["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_name],
["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_name]
],
view = "timeSeries",
stacked = false,
region = var.aws_region,
title = "ALB Requests and 5XX Errors"
}
}
]
})
}