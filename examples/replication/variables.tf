variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "replication-example"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_replication" {
  description = "Whether to enable ECR replication"
  type        = bool
  default     = true
}

variable "replication_regions" {
  description = "List of regions to replicate ECR images to"
  type        = list(string)
  default     = ["us-west-2", "eu-west-1"]
}


variable "enable_logging" {
  description = "Whether to enable CloudWatch logging"
  type        = bool
  default     = false # Keep it false by default for simplicity
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "example"
}