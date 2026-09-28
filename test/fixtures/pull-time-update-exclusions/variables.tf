variable "region" {
  description = "AWS region for the test fixture"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name of the ECR repository for the test fixture"
  type        = string
  default     = "test-pull-time-update-exclusions"
}
