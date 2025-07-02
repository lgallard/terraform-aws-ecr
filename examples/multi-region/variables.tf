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

variable "enable_replication" {
  description = "Whether to use built-in ECR replication (recommended)"
  type        = bool
  default     = true
}

variable "use_manual_setup" {
  description = "Whether to demonstrate manual multi-region setup (alternative approach)"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Whether to enable CloudWatch logging"
  type        = bool
  default     = false
}
