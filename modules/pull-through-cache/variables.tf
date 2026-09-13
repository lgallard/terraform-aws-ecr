# ----------------------------------------------------------
# Input Variables for Pull-Through Cache Submodule
# ----------------------------------------------------------

variable "name" {
  description = "The name to use for the ECR repository and related resources."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID."
  type        = string
}

variable "pull_through_cache_rules" {
  description = "List of pull-through cache rules to create."
  type = list(object({
    ecr_repository_prefix      = string
    upstream_registry_url      = string
    credential_arn             = optional(string)
    custom_role_arn            = optional(string)
    upstream_repository_prefix = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.pull_through_cache_rules :
      rule.ecr_repository_prefix == "ROOT" || can(regex("^[a-z0-9]+([-._][a-z0-9]+)*$", rule.ecr_repository_prefix))
    ])
    error_message = "ECR repository prefix must be ROOT or lowercase alphanumeric with optional hyphens, periods, or underscores."
  }

  validation {
    condition = alltrue([
      for rule in var.pull_through_cache_rules :
      rule.upstream_repository_prefix == null || rule.ecr_repository_prefix != "ROOT"
    ])
    error_message = "Upstream repository prefix can only be set when ecr_repository_prefix is not ROOT."
  }

  validation {
    condition = alltrue([
      for rule in var.pull_through_cache_rules : length(rule.upstream_registry_url) > 0
    ])
    error_message = "Upstream registry URL must be specified."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
