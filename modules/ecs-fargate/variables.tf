
variable "app_name" {
    description = "The name prefix for all resources"
    type        = string
    default     = "./variables.tf"
}

variable "public_subnets" {
    description = "A list of public subnet IDs"
    type        = list(string)
}

variable "private_subnets" {
    description = "A list of private subnet IDs"
    type        = list(string)
}

variable "vpc_id" {
    description = "The VPC ID"
    type        = string
}

variable "service_sg" {
    description = "The security group for the ECS service"
    type        = string
}

variable "task_cpu" {
    description = "The CPU units for the task"
    type        = string
    default     = "256"
}

variable "task_memory" {
    description = "The memory for the task"
    type        = string
    default     = "512"
}

variable "image" {
    description = "The container image to use"
    type        = string
}

variable "aws_region" {
    description = "AWS region where resources will be created"
    type = string
}

variable "desired_count" {
  description = "The desired number of ECS service tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "The minimum capacity for the ECS service auto-scaling"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum capacity for the ECS service auto-scaling"
  type        = number
  default     = 5
}
variable "container_port" {
  description = "The port on which the container listens"
  type        = number
  default     = 3000
}
variable "env_vars" {
  description = "A map of environment variables to set in the container"
  type        = map(string)
  default     = {}
}
variable "alb_sg" {
  description = "The security group for the Application Load Balancer"
  type        = string
  
}