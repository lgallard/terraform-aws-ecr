# ----------------------------------------------------------
# KMS Key Configuration Variables
# ----------------------------------------------------------

variable "name" {
  description = "Name prefix for KMS resources (typically the ECR repository name)"
  type        = string
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Number of days to wait before actually deleting the key (7-30 days)"
  type        = number
  default     = 7
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Whether to enable automatic key rotation"
  type        = bool
  default     = true
}

variable "key_rotation_period" {
  description = "Number of days between automatic key rotations (90-2555 days, AWS managed keys only)"
  type        = number
  default     = null
  validation {
    condition = var.key_rotation_period == null ? true : (
      var.key_rotation_period >= 90 && var.key_rotation_period <= 2555
    )
    error_message = "Key rotation period must be between 90 and 2555 days if specified."
  }
}

variable "multi_region" {
  description = "Whether to create a multi-region key"
  type        = bool
  default     = false
}

variable "key_usage" {
  description = "Key usage (ENCRYPT_DECRYPT, SIGN_VERIFY, GENERATE_VERIFY_MAC)"
  type        = string
  default     = "ENCRYPT_DECRYPT"
  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "Key usage must be ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

# ----------------------------------------------------------
# KMS Key Policy Configuration
# ----------------------------------------------------------

variable "enable_default_policy" {
  description = "Whether to enable the default KMS key policy"
  type        = bool
  default     = true
}

variable "additional_principals" {
  description = "List of additional IAM principals (ARNs) to grant access to the KMS key"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for arn in var.additional_principals :
      can(regex("^arn:aws:iam::[0-9]{12}:(root|user/.+|role/.+)$", arn))
    ])
    error_message = "All additional principals must be valid IAM ARNs."
  }
}

variable "key_administrators" {
  description = "List of IAM principals (ARNs) who can administer the KMS key"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "List of IAM principals (ARNs) who can use the KMS key for cryptographic operations"
  type        = list(string)
  default     = []
}

variable "allow_ecr_service" {
  description = "Whether to allow the ECR service to use the KMS key"
  type        = bool
  default     = true
}

variable "custom_policy_statements" {
  description = "List of custom policy statements to add to the KMS key policy"
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

variable "custom_policy" {
  description = "Complete custom policy JSON for the KMS key (overrides all other policy settings)"
  type        = string
  default     = null
}

# ----------------------------------------------------------
# KMS Alias Configuration
# ----------------------------------------------------------

variable "create_alias" {
  description = "Whether to create a KMS alias for the key"
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "Custom alias name for the KMS key (without 'alias/' prefix). If not provided, uses 'ecr/{name}'"
  type        = string
  default     = null
  validation {
    condition = var.alias_name == null ? true : (
      can(regex("^[a-zA-Z0-9:/_-]+$", var.alias_name)) && !startswith(var.alias_name, "alias/")
    )
    error_message = "Alias name must contain only alphanumeric characters, colons, underscores, and hyphens, and must not start with 'alias/'."
  }
}

# ----------------------------------------------------------
# Tagging
# ----------------------------------------------------------

variable "tags" {
  description = "Map of tags to assign to the KMS key and alias"
  type        = map(string)
  default     = {}
}

variable "kms_tags" {
  description = "Additional tags specific to KMS resources"
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------
# AWS Account Information
# ----------------------------------------------------------

variable "aws_account_id" {
  description = "AWS Account ID (used for policy generation)"
  type        = string
}
