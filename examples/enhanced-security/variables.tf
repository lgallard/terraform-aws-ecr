variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "enhanced-security-repo"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  default     = "dev"
}

variable "force_delete" {
  description = "Whether to delete the repository even if it contains images"
  type        = bool
  default     = false
}

variable "enable_pull_through_cache" {
  description = "Whether to enable pull-through cache rules"
  type        = bool
  default     = true
}
