variable "name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "protected-test-repo"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}