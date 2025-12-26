# ----------------------------------------------------------
# General ECR Repository Configuration
# ----------------------------------------------------------

variable "name" {
  description = "Name of the ECR repository. This name must be unique within the AWS account and region."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-_./]*$", var.name))
    error_message = "Repository name must start with a letter or number and can only contain lowercase letters, numbers, hyphens, underscores, forward slashes and periods."
  }
}

variable "force_delete" {
  description = "Whether to delete the repository even if it contains images. Use with caution."
  type        = bool
  default     = false
}

variable "prevent_destroy" {
  description = "Whether to protect the repository from being destroyed via lifecycle prevent_destroy."
  type        = bool
  default     = false
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Either MUTABLE, IMMUTABLE, IMMUTABLE_WITH_EXCLUSION, or MUTABLE_WITH_EXCLUSION."
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE", "IMMUTABLE_WITH_EXCLUSION", "MUTABLE_WITH_EXCLUSION"], var.image_tag_mutability)
    error_message = "The image_tag_mutability value must be either MUTABLE, IMMUTABLE, IMMUTABLE_WITH_EXCLUSION, or MUTABLE_WITH_EXCLUSION."
  }
}

# ----------------------------------------------------------
# Image Scanning Configuration
# ----------------------------------------------------------

variable "scan_on_push" {
  description = "Whether images should be scanned after being pushed to the repository."
  type        = bool
  default     = true
}

variable "image_scanning_configuration" {
  description = "Image scanning configuration block. Set to null to use scan_on_push variable."
  type = object({
    scan_on_push = bool
  })
  default = null
}

# ----------------------------------------------------------
# Timeouts Configuration
# ----------------------------------------------------------

variable "timeouts" {
  description = "Timeout configuration for repository operations. Example: { delete = \"20m\" }"
  type = object({
    delete = optional(string)
  })
  default = {}

  validation {
    condition = (
      var.timeouts == null ||
      var.timeouts == {} ||
      try(var.timeouts.delete == null, true) ||
      try(can(regex("^[0-9]+(s|m|h)$", var.timeouts.delete)), false)
    )
    error_message = "If 'delete' key is provided in timeouts, it must be a duration string (e.g. '20m', '1h', '300s')."
  }
}


# ----------------------------------------------------------
# Repository Policies
# ----------------------------------------------------------

variable "policy" {
  description = "JSON string representing the repository policy. If null, no policy is created."
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "JSON string representing the lifecycle policy. Takes precedence over helper variables."
  type        = string
  default     = null
}

# ----------------------------------------------------------
# Lifecycle Policy Helper Variables
# ----------------------------------------------------------

variable "lifecycle_keep_latest_n_images" {
  description = "Number of latest images to keep in the repository (1-10000). Null to disable."
  type        = number
  default     = null
  validation {
    condition = var.lifecycle_keep_latest_n_images == null ? true : (
      var.lifecycle_keep_latest_n_images > 0 && var.lifecycle_keep_latest_n_images <= 10000
    )
    error_message = "lifecycle_keep_latest_n_images must be between 1 and 10000 if specified."
  }
}

variable "lifecycle_expire_untagged_after_days" {
  description = "Number of days after which untagged images expire (1-3650). Null to disable."
  type        = number
  default     = null
  validation {
    condition = var.lifecycle_expire_untagged_after_days == null ? true : (
      var.lifecycle_expire_untagged_after_days > 0 && var.lifecycle_expire_untagged_after_days <= 3650
    )
    error_message = "lifecycle_expire_untagged_after_days must be between 1 and 3650 days if specified."
  }
}

variable "lifecycle_expire_tagged_after_days" {
  description = "Number of days after which tagged images expire (1-3650). Use with caution."
  type        = number
  default     = null
  validation {
    condition = var.lifecycle_expire_tagged_after_days == null ? true : (
      var.lifecycle_expire_tagged_after_days > 0 && var.lifecycle_expire_tagged_after_days <= 3650
    )
    error_message = "lifecycle_expire_tagged_after_days must be between 1 and 3650 days if specified."
  }
}

variable "lifecycle_tag_prefixes_to_keep" {
  description = "List of tag prefixes for keep-latest rule. Empty list applies to all images. Max 100 prefixes."
  type        = list(string)
  default     = []
  validation {
    condition = (
      length(var.lifecycle_tag_prefixes_to_keep) <= 100 &&
      alltrue([for prefix in var.lifecycle_tag_prefixes_to_keep : length(prefix) <= 255])
    )
    error_message = "Maximum of 100 tag prefixes allowed, each with maximum length of 255 characters."
  }
}

# ----------------------------------------------------------
# Lifecycle Policy Templates
# ----------------------------------------------------------

variable "lifecycle_policy_template" {
  description = "Predefined lifecycle policy template. Options: development, production, cost_optimization, compliance."
  type        = string
  default     = null
  validation {
    condition = var.lifecycle_policy_template == null ? true : contains(
      ["development", "production", "cost_optimization", "compliance"],
      var.lifecycle_policy_template
    )
    error_message = "lifecycle_policy_template must be one of: development, production, cost_optimization, compliance."
  }
}

# ----------------------------------------------------------
# Encryption Configuration
# ----------------------------------------------------------

variable "encryption_type" {
  description = "Repository encryption type. Either KMS or AES256."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["KMS", "AES256"], var.encryption_type)
    error_message = "Encryption type must be either \"KMS\" or \"AES256\"."
  }
}

variable "kms_key" {
  description = "ARN of existing KMS key for repository encryption. If null, a new key is created."
  type        = string
  default     = null
}

# ----------------------------------------------------------
# Enhanced KMS Configuration
# ----------------------------------------------------------

variable "kms_deletion_window_in_days" {
  description = "Number of days to wait before deleting the KMS key (7-30 days)."
  type        = number
  default     = 7
  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "kms_enable_key_rotation" {
  description = "Whether to enable automatic key rotation for the KMS key."
  type        = bool
  default     = true
}

variable "kms_key_rotation_period" {
  description = "Number of days between automatic key rotations (90-2555 days)."
  type        = number
  default     = null
  validation {
    condition = var.kms_key_rotation_period == null ? true : (
      var.kms_key_rotation_period >= 90 && var.kms_key_rotation_period <= 2555
    )
    error_message = "KMS key rotation period must be between 90 and 2555 days if specified."
  }
}

variable "kms_multi_region" {
  description = "Whether to create a multi-region KMS key."
  type        = bool
  default     = false
}

variable "kms_additional_principals" {
  description = "List of additional IAM principals (ARNs) to grant KMS key access."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.kms_additional_principals :
      can(regex("^arn:aws:iam::[0-9]{12}:(root|user/.+|role/.+)$", arn))
    ])
    error_message = "All additional principals must be valid IAM ARNs."
  }
}

variable "kms_key_administrators" {
  description = "List of IAM principals (ARNs) who can administer the KMS key."
  type        = list(string)
  default     = []
}

variable "kms_key_users" {
  description = "List of IAM principals (ARNs) who can use the KMS key for crypto operations."
  type        = list(string)
  default     = []
}

variable "kms_custom_policy_statements" {
  description = "List of custom policy statements to add to the KMS key policy."
  type = list(object({
    sid    = optional(string)
    effect = string
    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    actions   = list(string)
    resources = optional(list(string), ["*"])
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

variable "kms_custom_policy" {
  description = "Complete custom policy JSON for the KMS key. Use with caution."
  type        = string
  default     = null
}

variable "kms_alias_name" {
  description = "Custom alias name for the KMS key (without 'alias/' prefix)."
  type        = string
  default     = null
  validation {
    condition = var.kms_alias_name == null ? true : (
      can(regex("^[a-zA-Z0-9:/_-]+$", var.kms_alias_name)) && !startswith(var.kms_alias_name, "alias/")
    )
    error_message = "KMS alias name must contain only alphanumeric characters, colons, underscores, and hyphens, and must not start with 'alias/'."
  }
}

variable "kms_tags" {
  description = "Additional tags specific to KMS resources."
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------
# Tagging
# ----------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------
# Advanced Tagging Configuration
# ----------------------------------------------------------

variable "enable_default_tags" {
  description = "Whether to enable automatic default tags for all resources."
  type        = bool
  default     = true
}

variable "default_tags_template" {
  description = "Predefined default tag template. Options: basic, cost_allocation, compliance, sdlc."
  type        = string
  default     = null
  validation {
    condition = var.default_tags_template == null ? true : contains(
      ["basic", "cost_allocation", "compliance", "sdlc"],
      var.default_tags_template
    )
    error_message = "default_tags_template must be one of: basic, cost_allocation, compliance, sdlc."
  }
}

variable "default_tags_environment" {
  description = "Environment tag value applied to all resources. Null to disable."
  type        = string
  default     = null
}

variable "default_tags_owner" {
  description = "Owner tag value applied to all resources. Null to disable."
  type        = string
  default     = null
}

variable "default_tags_project" {
  description = "Project tag value applied to all resources. Null to disable."
  type        = string
  default     = null
}

variable "default_tags_cost_center" {
  description = "Cost center tag value for financial tracking. Null to disable."
  type        = string
  default     = null
}

variable "enable_tag_validation" {
  description = "Whether to enable tag validation to ensure compliance with organizational standards."
  type        = bool
  default     = false
}

variable "required_tags" {
  description = "List of tag keys that are required to be present. Empty list disables validation."
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.required_tags) <= 50
    error_message = "Maximum of 50 required tags allowed."
  }
}

variable "tag_key_case" {
  description = "Enforce consistent casing for tag keys. Options: PascalCase, camelCase, snake_case, kebab-case."
  type        = string
  default     = "PascalCase"
  validation {
    condition = var.tag_key_case == null ? true : contains(
      ["PascalCase", "camelCase", "snake_case", "kebab-case"],
      var.tag_key_case
    )
    error_message = "tag_key_case must be one of: PascalCase, camelCase, snake_case, kebab-case."
  }
}

variable "enable_tag_normalization" {
  description = "Whether to enable automatic tag normalization."
  type        = bool
  default     = true
}

variable "normalize_tag_values" {
  description = "Whether to normalize tag values by trimming whitespace."
  type        = bool
  default     = true
}

# ----------------------------------------------------------
# Logging Configuration
# ----------------------------------------------------------

variable "enable_logging" {
  description = "Whether to enable CloudWatch logging for the repository."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain ECR logs in CloudWatch."
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

# ----------------------------------------------------------
# Replication Configuration
# ----------------------------------------------------------

variable "enable_replication" {
  description = "Whether to enable cross-region replication for the ECR registry."
  type        = bool
  default     = false
}

variable "replication_regions" {
  description = "List of AWS regions to replicate ECR images to."
  type        = list(string)
  default     = []
}

# ----------------------------------------------------------
# Enhanced Scanning Configuration
# ----------------------------------------------------------

variable "enable_registry_scanning" {
  description = "Whether to enable enhanced scanning for the ECR registry."
  type        = bool
  default     = false
}

variable "registry_scan_type" {
  description = "The type of scanning to configure for the registry. Either BASIC or ENHANCED."
  type        = string
  default     = "ENHANCED"
  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.registry_scan_type)
    error_message = "Registry scan type must be either BASIC or ENHANCED."
  }
}

variable "registry_scan_filters" {
  description = "List of scan filters for filtering scan results when querying ECR findings."
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}

# ----------------------------------------------------------
# ECR Account Settings Configuration
# ----------------------------------------------------------

variable "manage_account_setting" {
  description = "Whether to manage ECR account-level settings. When enabled, this will configure account settings such as basic scan type version."
  type        = bool
  default     = false
}

variable "basic_scan_type_version" {
  description = "The scanning type version for basic scans. AWS_NATIVE uses Amazon's native scanning technology (recommended), CLAIR uses the deprecated CLAIR-based scanning."
  type        = string
  default     = "AWS_NATIVE"
  validation {
    condition     = contains(["AWS_NATIVE", "CLAIR"], var.basic_scan_type_version)
    error_message = "Basic scan type version must be either AWS_NATIVE or CLAIR."
  }
}

# ----------------------------------------------------------
# Pull-Through Cache Configuration
# ----------------------------------------------------------

variable "enable_pull_through_cache" {
  description = "Whether to create pull-through cache rules."
  type        = bool
  default     = false
}

variable "pull_through_cache_rules" {
  description = "List of pull-through cache rules to create."
  type = list(object({
    ecr_repository_prefix = string
    upstream_registry_url = string
    credential_arn        = optional(string)
  }))
  default = []
}

# ----------------------------------------------------------
# Secret Scanning Configuration
# ----------------------------------------------------------

variable "enable_secret_scanning" {
  description = "Whether to enable secret scanning. Detects secrets in container images."
  type        = bool
  default     = false
}

variable "scan_repository_filters" {
  description = "List of repository filters to apply for registry scanning. Supports wildcards."
  type        = list(string)
  default     = ["*"]
}

# ----------------------------------------------------------
# Monitoring Configuration
# ----------------------------------------------------------

variable "enable_monitoring" {
  description = "Whether to enable CloudWatch monitoring and alerting for the ECR repository."
  type        = bool
  default     = false
}

variable "monitoring_threshold_storage" {
  description = "Storage usage threshold in GB to trigger CloudWatch alarm."
  type        = number
  default     = 10
  validation {
    condition     = var.monitoring_threshold_storage > 0
    error_message = "Storage threshold must be greater than 0 GB."
  }
}

variable "monitoring_threshold_api_calls" {
  description = "API call volume threshold per minute to trigger CloudWatch alarm."
  type        = number
  default     = 1000
  validation {
    condition     = var.monitoring_threshold_api_calls > 0
    error_message = "API call threshold must be greater than 0."
  }
}

variable "monitoring_threshold_security_findings" {
  description = "Security findings threshold to trigger CloudWatch alarm."
  type        = number
  default     = 10
  validation {
    condition     = var.monitoring_threshold_security_findings >= 0
    error_message = "Security findings threshold must be greater than or equal to 0."
  }
}

variable "monitoring_threshold_image_push" {
  description = "Image push frequency threshold per 5-minute period to trigger CloudWatch alarm."
  type        = number
  default     = 10
  validation {
    condition     = var.monitoring_threshold_image_push > 0
    error_message = "Image push threshold must be greater than 0."
  }
}

variable "monitoring_threshold_image_pull" {
  description = "Image pull frequency threshold per 5-minute period to trigger CloudWatch alarm."
  type        = number
  default     = 100
  validation {
    condition     = var.monitoring_threshold_image_pull > 0
    error_message = "Image pull threshold must be greater than 0."
  }
}

variable "create_sns_topic" {
  description = "Whether to create an SNS topic for CloudWatch alarm notifications."
  type        = bool
  default     = false
}

variable "sns_topic_name" {
  description = "Name of the SNS topic to create or use for alarm notifications."
  type        = string
  default     = null
}

variable "sns_topic_subscribers" {
  description = "List of email addresses to subscribe to the SNS topic for alarm notifications."
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for email in var.sns_topic_subscribers :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All SNS topic subscribers must be valid email addresses."
  }
}

# ----------------------------------------------------------
# Pull Request Rules Configuration
# ----------------------------------------------------------

variable "enable_pull_request_rules" {
  description = "Whether to enable pull request rules for enhanced governance and quality control."
  type        = bool
  default     = false
}

variable "pull_request_rules" {
  description = "List of pull request rule configurations for enhanced governance."
  type = list(object({
    name    = string
    type    = string
    enabled = bool
    conditions = optional(object({
      tag_patterns            = optional(list(string), [])
      severity_threshold      = optional(string, "MEDIUM")
      require_scan_completion = optional(bool, true)
      allowed_principals      = optional(list(string), [])
    }), {})
    actions = optional(object({
      require_approval_count = optional(number, 1)
      notification_topic_arn = optional(string)
      webhook_url            = optional(string)
      block_on_failure       = optional(bool, true)
      approval_timeout_hours = optional(number, 24)
    }), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.pull_request_rules : contains(["approval", "security_scan", "ci_integration"], rule.type)
    ])
    error_message = "Pull request rule type must be one of: approval, security_scan, ci_integration."
  }
}
