variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "enable_registry_scanning" {
  description = "Enable enhanced registry scanning"
  type        = bool
  default     = false
}

variable "registry_scan_type" {
  description = "Type of registry scanning"
  type        = string
  default     = "ENHANCED"
}

variable "enable_secret_scanning" {
  description = "Enable secret scanning"
  type        = bool
  default     = false
}

variable "registry_scan_filters" {
  description = "Registry scan filters"
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}

variable "enable_pull_through_cache" {
  description = "Enable pull-through cache"
  type        = bool
  default     = false
}

variable "pull_through_cache_rules" {
  description = "Pull-through cache rules"
  type = list(object({
    ecr_repository_prefix = string
    upstream_registry_url = string
    credential_arn        = optional(string)
  }))
  default = []
}

variable "scan_repository_filters" {
  description = "Repository filters for scanning"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}