variable "app_name" {
   description = "The name prefix for all resources"
    type        = string
    default     = "./variables.tf"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "secrets_arns" {
  description = "List of Secrets Manager ARNs ECS tasks can access"
  type        = list(string)
  default     = []
}

variable "cicd_principal_identifiers" {
  description = "Principal identifiers (OIDC or AWS service) allowed to assume the CI/CD deploy role"
  type        = list(string)
  default     = ["codepipeline.amazonaws.com"]
}
