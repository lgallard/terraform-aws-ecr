variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "terratest-ecr-complete"
}
