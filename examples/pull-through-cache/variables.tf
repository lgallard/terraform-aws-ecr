# ----------------------------------------------------------
# Input Variables for Pull-Through Cache Example
# ----------------------------------------------------------

variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "my-cached-repo"

  validation {
    condition     = can(regex("^[a-z0-9]+([-._][a-z0-9]+)*$", var.repository_name))
    error_message = "Repository name must be lowercase alphanumeric with optional hyphens, periods, or underscores."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "force_delete" {
  description = "Whether to force delete the repository even if it contains images"
  type        = bool
  default     = false
}

variable "quay_credentials_arn" {
  description = "ARN of AWS Secrets Manager secret containing Quay.io credentials (optional)"
  type        = string
  default     = null
}

variable "github_credentials_arn" {
  description = "ARN of AWS Secrets Manager secret containing GitHub Container Registry credentials (optional)"
  type        = string
  default     = null
}
