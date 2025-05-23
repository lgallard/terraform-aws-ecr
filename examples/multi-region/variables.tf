variable "primary_region" {
  description = "Primary AWS region for the ECR repository"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for the ECR repository"
  type        = string
  default     = "us-west-2"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "multi-region-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}