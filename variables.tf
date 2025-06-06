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
    See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html
  EOT
  type        = string
  default     = null
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
  validation {
    condition = length(var.replication_regions) == 0 || alltrue([
      for region in var.replication_regions : can(regex("^[a-z]{2}-[a-z]+-[0-9]$", region))
    ])
    error_message = "Replication regions must be valid AWS region names (e.g., us-west-2, eu-west-1)."
  }
}

variable "replication_kms_key" {
  description = <<-EOT
    The ARN of the KMS key to use for encrypting replicated images.
    If not specified, the default ECR encryption will be used for replicated images.
    Only applicable when enable_replication is true.
  EOT
  type        = string
  default     = null
}
