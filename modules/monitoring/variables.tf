variable "app_name" {
     description = "The name prefix for all resources"
    type        = string
    default     = "./variables.tf"
}
variable "environment" {}
variable "aws_region" {}
variable "cluster_name" {}
variable "service_name" {}
variable "alb_name" {}
variable "sns_topic_arn" {}