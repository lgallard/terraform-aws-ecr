variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "development"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "advanced-tagging-demo"
}

variable "owner_team" {
  description = "Team that owns these resources"
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "engineering-demo"
}

variable "enable_strict_validation" {
  description = "Whether to enable strict tag validation"
  type        = bool
  default     = true
}