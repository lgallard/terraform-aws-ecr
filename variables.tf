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
  description = <<-EOT
    Whether to delete the repository even if it contains images.
    Setting this to true will delete all images in the repository when the repository is deleted.
    Use with caution as this operation cannot be undone.
    Defaults to false for safety.
  EOT
  type        = bool
  default     = false
  validation {
    condition     = can(tobool(var.force_delete))
    error_message = "The force_delete variable must be a boolean value (true/false)."
  }
}

variable "prevent_destroy" {
  description = <<-EOT
    Whether to protect the repository from being destroyed.
    When set to true, the repository will have the lifecycle block with prevent_destroy = true.
    When set to false, the repository can be destroyed.
    This provides a way to dynamically control protection against accidental deletion.
    Defaults to false to allow repository deletion.
  EOT
  type        = bool
  default     = false
  validation {
    condition     = can(tobool(var.prevent_destroy))
    error_message = "The prevent_destroy variable must be a boolean value (true/false)."
  }
}

variable "image_tag_mutability" {
  description = <<-EOT
    The tag mutability setting for the repository.
    - MUTABLE: Image tags can be overwritten
    - IMMUTABLE: Image tags cannot be overwritten (recommended for production)
    Defaults to MUTABLE to maintain backwards compatibility.
  EOT
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "The image_tag_mutability value must be either MUTABLE or IMMUTABLE."
  }
}

# ----------------------------------------------------------
# Image Scanning Configuration
# ----------------------------------------------------------

variable "scan_on_push" {
  description = <<-EOT
    Indicates whether images should be scanned for vulnerabilities after being pushed to the repository.
    - true: Images will be automatically scanned after each push
    - false: Images must be scanned manually
    Only used if image_scanning_configuration is null.
  EOT
  type        = bool
  default     = true
}

variable "image_scanning_configuration" {
  description = <<-EOT
    Configuration block that defines image scanning configuration for the repository.
    Set to null to use the scan_on_push variable setting.
    Example: { scan_on_push = true }
  EOT
  type = object({
    scan_on_push = bool
  })
  default = null
}

# ----------------------------------------------------------
# Timeouts Configuration
# ----------------------------------------------------------

variable "timeouts" {
  description = <<-EOT
    Timeout configuration for repository operations.
    Specify as an object with a 'delete' key containing a duration string (e.g. "20m").
    Example: { delete = "20m" }
  EOT
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

variable "timeouts_delete" {
  description = <<-EOT
    Deprecated: Use timeouts = { delete = "duration" } instead.
    How long to wait for a repository to be deleted.
    Specify as a duration string, e.g. "20m" for 20 minutes.
  EOT
  type        = string
  default     = null
}

# ----------------------------------------------------------
# Repository Policies
# ----------------------------------------------------------

variable "policy" {
  description = <<-EOT
    JSON string representing the repository policy.
    If null (default), no repository policy will be created.
    See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html
  EOT
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = <<-EOT
    JSON string representing the lifecycle policy.
    If null (default), no lifecycle policy will be created.
    Takes precedence over helper variables and templates if specified.
    See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html
  EOT
  type        = string
  default     = null
}

# ----------------------------------------------------------
# Lifecycle Policy Helper Variables
# ----------------------------------------------------------

variable "lifecycle_keep_latest_n_images" {
  description = <<-EOT
    Number of latest images to keep in the repository.
    If specified, creates a lifecycle policy rule to keep only the N most recent images.
    When used with lifecycle_tag_prefixes_to_keep, only applies to images with those tag prefixes.
    Other images are not affected by this rule and may be managed by other rules.
    Range: 1-10000 images. Set to null to disable this rule.

    Examples:
    - 30: Keep the 30 most recent images
    - 100: Keep the 100 most recent images (production default)
    - 10: Keep only 10 images (cost optimization)
  EOT
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
  description = <<-EOT
    Number of days after which untagged images should be expired.
    If specified, creates a lifecycle policy rule to delete untagged images older than N days.
    This rule applies to ALL untagged images regardless of lifecycle_tag_prefixes_to_keep.
    Range: 1-3650 days (up to 10 years). Set to null to disable this rule.

    Examples:
    - 7: Delete untagged images after 7 days (development default)
    - 14: Delete untagged images after 14 days (production default)
    - 1: Delete untagged images daily (aggressive cleanup)
  EOT
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
  description = <<-EOT
    Number of days after which tagged images should be expired.
    If specified, creates a lifecycle policy rule to delete tagged images older than N days.
    This rule applies to ALL tagged images regardless of lifecycle_tag_prefixes_to_keep.
    Use with caution as this may delete images you want to keep long-term.
    Range: 1-3650 days (up to 10 years). Set to null to disable this rule.

    Examples:
    - 90: Delete tagged images after 90 days (production default)
    - 30: Delete tagged images after 30 days (cost optimization)
    - 365: Delete tagged images after 1 year (compliance)
  EOT
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
  description = <<-EOT
    List of tag prefixes for images that should be managed by the keep-latest rule.
    When used with lifecycle_keep_latest_n_images, applies the keep rule ONLY to images with these tag prefixes.
    Images without these prefixes are not affected by the keep-latest rule.
    The expire rules (untagged/tagged) still apply to ALL images regardless of this setting.

    Common patterns:
    - ["v"]: Apply keep rule to semantic versions (v1.0.0, v2.1.3, etc.)
    - ["release-", "prod-"]: Apply to release and production builds
    - ["main", "develop"]: Apply to main branch builds
    - []: Apply keep rule to ALL images (empty list)

    Constraints: Maximum 100 prefixes, each up to 255 characters.
    Set to empty list to apply rules to all images.
  EOT
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
  description = <<-EOT
    Predefined lifecycle policy template to use for common scenarios.
    Templates provide tested configurations and best practices for different environments.

    Available templates:

    - "development": Optimized for dev workflows with frequent builds
      * Keep 50 images
      * Expire untagged after 7 days
      * No tagged expiry (developers may need old builds)
      * Tag prefixes: ["dev", "feature"]

    - "production": Balanced retention for production stability
      * Keep 100 images
      * Expire untagged after 14 days
      * Expire tagged after 90 days
      * Tag prefixes: ["v", "release", "prod"]

    - "cost_optimization": Aggressive cleanup to minimize storage costs
      * Keep 10 images
      * Expire untagged after 3 days
      * Expire tagged after 30 days
      * Tag prefixes: [] (applies to all images)

    - "compliance": Long retention for audit and compliance
      * Keep 200 images
      * Expire untagged after 30 days
      * Expire tagged after 365 days (1 year)
      * Tag prefixes: ["v", "release", "audit"]

    Set to null to use custom helper variables or manual lifecycle_policy.

    Configuration precedence:
    1. Manual lifecycle_policy (highest - overrides template)
    2. Template lifecycle_policy_template (overrides helper variables)
    3. Helper variables (lowest precedence)

    Note: When using a template, all helper variables (lifecycle_keep_latest_n_images,
    lifecycle_expire_untagged_after_days, etc.) will be ignored to prevent conflicts.
  EOT
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
  description = "The encryption type for the repository. Valid values are \"KMS\" or \"AES256\"."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["KMS", "AES256"], var.encryption_type)
    error_message = "Encryption type must be either \"KMS\" or \"AES256\"."
  }
}

variable "kms_key" {
  description = <<-EOT
    The ARN of an existing KMS key to use for repository encryption.
    Only applicable when encryption_type is set to 'KMS'.
    If not specified when using KMS encryption, a new KMS key will be created.
  EOT
  type        = string
  default     = null
}

# ----------------------------------------------------------
# Tagging
# ----------------------------------------------------------

variable "tags" {
  description = <<-EOT
    A map of tags to assign to all resources created by this module.
    Tags are key-value pairs that help you manage, identify, organize, search for and filter resources.
    Example: { Environment = "Production", Owner = "Team" }
  EOT
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------
# Advanced Tagging Configuration
# ----------------------------------------------------------

variable "enable_default_tags" {
  description = <<-EOT
    Whether to enable automatic default tags for all resources.
    When enabled, standard organizational tags will be automatically applied.
    Defaults to true for better resource management and compliance.
  EOT
  type        = bool
  default     = true
}

variable "default_tags_template" {
  description = <<-EOT
    Predefined default tag template to use for organizational compliance.
    
    Available templates:
    - "basic": Minimal set of organizational tags (CreatedBy, ManagedBy, Environment)
    - "cost_allocation": Tags optimized for cost tracking and allocation
    - "compliance": Tags required for security and compliance frameworks
    - "sdlc": Tags for software development lifecycle management
    - null: Use custom default_tags configuration
    
    When using a template, it will override individual default_tags_* variables.
  EOT
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
  description = <<-EOT
    Environment tag value to be automatically applied to all resources.
    Common values: production, staging, development, test
    Set to null to disable automatic environment tagging.
  EOT
  type        = string
  default     = null
}

variable "default_tags_owner" {
  description = <<-EOT
    Owner tag value to be automatically applied to all resources.
    Should specify the team, department, or individual responsible for the resource.
    Example: "platform-team", "data-engineering", "john.doe@company.com"
    Set to null to disable automatic owner tagging.
  EOT
  type        = string
  default     = null
}

variable "default_tags_project" {
  description = <<-EOT
    Project tag value to be automatically applied to all resources.
    Should specify the project or application name this resource belongs to.
    Example: "web-app", "data-pipeline", "user-service"
    Set to null to disable automatic project tagging.
  EOT
  type        = string
  default     = null
}

variable "default_tags_cost_center" {
  description = <<-EOT
    Cost center tag value for financial tracking and allocation.
    Should specify the cost center, budget code, or billing department.
    Example: "engineering", "marketing", "cc-1234"
    Set to null to disable automatic cost center tagging.
  EOT
  type        = string
  default     = null
}

variable "enable_tag_validation" {
  description = <<-EOT
    Whether to enable tag validation to ensure compliance with organizational standards.
    When enabled, validates that required tags are present and follow naming conventions.
    Defaults to false to maintain backward compatibility.
  EOT
  type        = bool
  default     = false
}

variable "required_tags" {
  description = <<-EOT
    List of tag keys that are required to be present.
    Validation will fail if any of these tags are missing from the final tag set.
    Example: ["Environment", "Owner", "Project"]
    Empty list disables required tag validation.
  EOT
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.required_tags) <= 50
    error_message = "Maximum of 50 required tags allowed."
  }
}

variable "tag_key_case" {
  description = <<-EOT
    Enforce consistent casing for tag keys.
    - "PascalCase": Capitalize first letter of each word (Environment, CostCenter)
    - "camelCase": First word lowercase, subsequent words capitalized (environment, costCenter)  
    - "snake_case": All lowercase with underscores (environment, cost_center)
    - "kebab-case": All lowercase with hyphens (environment, cost-center)
    - null: No case enforcement (preserve original casing)
  EOT
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
  description = <<-EOT
    Whether to enable automatic tag normalization.
    When enabled, normalizes tag keys to consistent casing and handles special characters.
    Defaults to true for better tag consistency across resources.
  EOT
  type        = bool
  default     = true
}

variable "normalize_tag_values" {
  description = <<-EOT
    Whether to normalize tag values by trimming whitespace and handling special characters.
    Applies common normalizations like removing leading/trailing spaces.
    Defaults to true for cleaner tag values.
  EOT
  type        = bool
  default     = true
}

# ----------------------------------------------------------
# Logging Configuration
# ----------------------------------------------------------

variable "enable_logging" {
  description = <<-EOT
    Whether to enable CloudWatch logging for the repository.
    When enabled, ECR API actions and image push/pull events will be logged to CloudWatch.
    Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = <<-EOT
    Number of days to retain ECR logs in CloudWatch.
    Only applicable when enable_logging is true.
    Defaults to 30 days.
  EOT
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
  description = <<-EOT
    Whether to enable cross-region replication for the ECR registry.
    When enabled, images will be automatically replicated to the specified regions.
    Note: This is a registry-level configuration that affects all repositories in the account.
    Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "replication_regions" {
  description = <<-EOT
    List of AWS regions to replicate ECR images to.
    Only applicable when enable_replication is true.
    Example: ["us-west-2", "eu-west-1"]
  EOT
  type        = list(string)
  default     = []
}

# ----------------------------------------------------------
# Enhanced Scanning Configuration
# ----------------------------------------------------------

variable "enable_registry_scanning" {
  description = <<-EOT
    Whether to enable enhanced scanning for the ECR registry.
    Enhanced scanning uses Amazon Inspector to provide detailed vulnerability assessments.
    This is a registry-level configuration that affects all repositories in the account.
    Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "registry_scan_type" {
  description = <<-EOT
    The type of scanning to configure for the registry.
    - BASIC: Basic scanning for OS vulnerabilities
    - ENHANCED: Enhanced scanning with Amazon Inspector integration
    Only applicable when enable_registry_scanning is true.
  EOT
  type        = string
  default     = "ENHANCED"
  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.registry_scan_type)
    error_message = "Registry scan type must be either BASIC or ENHANCED."
  }
}

variable "registry_scan_filters" {
  description = <<-EOT
    List of scan filters for filtering scan results when querying ECR scan findings.
    These filters can be used by external tools or scripts to filter scan results by criteria such as vulnerability severity.
    Each filter should specify name and values.
    Example: [{ name = "PACKAGE_VULNERABILITY_SEVERITY", values = ["HIGH", "CRITICAL"] }]

    Note: These filters are not applied at the registry scanning configuration level, but are made available
    as outputs for use in querying and filtering scan results.
  EOT
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}

# ----------------------------------------------------------
# Pull-Through Cache Configuration
# ----------------------------------------------------------

variable "enable_pull_through_cache" {
  description = <<-EOT
    Whether to create pull-through cache rules.
    Pull-through cache rules allow you to cache images from upstream registries.
    Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "pull_through_cache_rules" {
  description = <<-EOT
    List of pull-through cache rules to create.
    Each rule should specify ecr_repository_prefix and upstream_registry_url.
    Example: [{ ecr_repository_prefix = "docker-hub", upstream_registry_url = "registry-1.docker.io" }]
  EOT
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
  description = <<-EOT
    Whether to enable secret scanning as part of enhanced scanning.
    This feature detects secrets like API keys, passwords, and tokens in container images.
    When enabled, automatically sets the registry scan type to ENHANCED, overriding registry_scan_type.
    Requires enable_registry_scanning to be true.
    Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "scan_repository_filters" {
  description = <<-EOT
    List of repository filters to apply for registry scanning.
    Each filter specifies which repositories should be scanned.
    Supports wildcard patterns using '*' character.
    If empty, defaults to scanning all repositories ("*").
    Example: ["my-app-*", "important-service"]
  EOT
  type        = list(string)
  default     = ["*"]
}

# ----------------------------------------------------------
# Monitoring Configuration
# ----------------------------------------------------------

variable "enable_monitoring" {
  description = <<-EOT
    Whether to enable CloudWatch monitoring and alerting for the ECR repository.
    When enabled, creates metric alarms for storage usage, API calls, and security findings.
    Defaults to false to maintain backward compatibility.
  EOT
  type        = bool
  default     = false
}

variable "monitoring_threshold_storage" {
  description = <<-EOT
    Storage usage threshold in GB to trigger CloudWatch alarm.
    When repository storage exceeds this threshold, an alarm will be triggered.
    Only applicable when enable_monitoring is true.
    Defaults to 10 GB.
  EOT
  type        = number
  default     = 10
  validation {
    condition     = var.monitoring_threshold_storage > 0
    error_message = "Storage threshold must be greater than 0 GB."
  }
}

variable "monitoring_threshold_api_calls" {
  description = <<-EOT
    API call volume threshold per minute to trigger CloudWatch alarm.
    When API calls exceed this threshold, an alarm will be triggered.
    Only applicable when enable_monitoring is true.
    Defaults to 1000 calls per minute.
  EOT
  type        = number
  default     = 1000
  validation {
    condition     = var.monitoring_threshold_api_calls > 0
    error_message = "API call threshold must be greater than 0."
  }
}

variable "monitoring_threshold_security_findings" {
  description = <<-EOT
    Security findings threshold to trigger CloudWatch alarm.
    When security findings exceed this threshold, an alarm will be triggered.
    Only applicable when enable_monitoring is true.
    Defaults to 10 findings.
  EOT
  type        = number
  default     = 10
  validation {
    condition     = var.monitoring_threshold_security_findings >= 0
    error_message = "Security findings threshold must be greater than or equal to 0."
  }
}

variable "create_sns_topic" {
  description = <<-EOT
    Whether to create an SNS topic for CloudWatch alarm notifications.
    When enabled, creates a new SNS topic for sending alerts.
    Only applicable when enable_monitoring is true.
    Defaults to false.
  EOT
  type        = bool
  default     = false
}

variable "sns_topic_name" {
  description = <<-EOT
    Name of the SNS topic to create or use for alarm notifications.
    If create_sns_topic is true, this will be the name of the created topic.
    If create_sns_topic is false, this should be the name of an existing topic.
    Only applicable when enable_monitoring is true.
    Defaults to null.
  EOT
  type        = string
  default     = null
}

variable "sns_topic_subscribers" {
  description = <<-EOT
    List of email addresses to subscribe to the SNS topic for alarm notifications.
    Each email address will receive notifications when alarms are triggered.
    Only applicable when enable_monitoring and create_sns_topic are true.
    Example: ["admin@company.com", "devops@company.com"]
  EOT
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
