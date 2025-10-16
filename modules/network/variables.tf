variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "public_subnets" {
    description = "List of public subnet CIDR blocks"
    type        = list(string)
}

variable "private_subnets" {
    description = "List of private subnet CIDR blocks"
    type        = list(string)
}

variable "name" {
    description = "The name prefix for all resources"
    type        = string
    default     = "./variables.tf"
}
variable "azs" {
    description = "A list of availability zones to use"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b"]
}