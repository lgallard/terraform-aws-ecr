variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "repository-template-example"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "example"
}
