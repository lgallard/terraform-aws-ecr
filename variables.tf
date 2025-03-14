# General vars
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
    error_message = "The image_tag_mutability value must be either MUTABLE or IMMUTABLE. Got: ${var.image_tag_mutability}"
  }
}

# Image scanning configuration
variable "image_scanning_configuration" {
  description = <<-EOT
    Configuration block that defines image scanning configuration for the repository.
    Can be provided as either:
    1. A map of configuration options (legacy format)
    2. An object with scan_on_push boolean (new format)
    If null (default), will use the scan_on_push variable setting.
    Example: { scan_on_push = true }
  EOT
  type        = any
  default     = null

  validation {
    condition = var.image_scanning_configuration == null || (
      can(tobool(try(var.image_scanning_configuration.scan_on_push, false)))
    )
    error_message = "The image_scanning_configuration must either be null or contain a 'scan_on_push' key with a boolean value (true/false)."
  }
}

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

# Timeouts
variable "timeouts" {
  description = <<-EOT
    Timeout configuration for repository operations.
    Specify as a map with 'delete' key containing a duration string (e.g. "20m").
    Example: { delete = "20m" }

    Note: While additional keys are allowed for backwards compatibility,
    only the 'delete' key is currently used by this module.
  EOT
  type        = any
  default     = {}

  validation {
    condition = (
      var.timeouts == null ||
      var.timeouts == {} ||
      (
        lookup(var.timeouts, "delete", null) == null ||
        (
          can(lookup(var.timeouts, "delete", "")) &&
          length(lookup(var.timeouts, "delete", "")) > 0 &&
          can(regex("^[0-9]+(s|m|h)$", lookup(var.timeouts, "delete", "")))
        )
      )
    )
    error_message = "If 'delete' key is provided in timeouts, it must be a non-empty string duration (e.g. '20m', '1h', '300s')."
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

# Repository policy configuration
variable "policy" {
  description = <<-EOT
    JSON string representing the repository policy.
    If null (default), no repository policy will be created.
    See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html
  EOT
  type        = string
  default     = null
}

# Lifecycle policy configuration
variable "lifecycle_policy" {
  description = <<-EOT
    JSON string representing the lifecycle policy.
    If null (default), no lifecycle policy will be created.
    See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html
  EOT
  type        = string
  default     = null
}

# Resource tags
variable "tags" {
  description = <<-EOT
    A map of tags to assign to all resources created by this module.
    Tags are key-value pairs that help you manage, identify, organize, search for and filter resources.
    Example: { Environment = "Production", Owner = "Team" }
  EOT
  type        = map(string)
  default     = {}
}

# Repository encryption configuration
variable "encryption_type" {
  description = "The encryption type. Allowed values are \"KMS\" or \"AES256\"."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["KMS", "AES256"], var.encryption_type)
    error_message = "encryption_type must be either \"KMS\" or \"AES256\"."
  }
}

# KMS key configuration
variable "kms_key" {
  description = <<-EOT
    The ARN of an existing KMS key to use for repository encryption.
    Only applicable when encryption_type is set to 'KMS'.
    If not specified when using KMS encryption:
    - A new KMS key will be created if encryption_type = "KMS"
    - The default AWS managed key will be used if encryption_type = "AES256"
  EOT
  type        = string
  default     = null
}
