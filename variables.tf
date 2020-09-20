# General vars
variable "name" {
  description = "Name of the repository."
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`."
  type        = string
  default     = "MUTABLE"
}

# Image scanning configuration
variable "image_scanning_configuration" {
  description = "Configuration block that defines image scanning configuration for the repository. By default, image scanning must be manually triggered. See the ECR User Guide for more information about image scanning."
  type        = map
  default     = {}
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = true
}

# Timeouts
variable "timeouts" {
  description = "Timeouts map."
  type        = map
  default     = {}
}

variable "timeouts_delete" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = string
  default     = null
}

# Policy
variable "policy" {
  description = "Manages the ECR repository policy"
  type        = string
  default     = null
}

# Lifecycle policy
variable "lifecycle_policy" {
  description = "Manages the ECR repository lifecycle policy"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# Encryption type
variable "encryption_type" {
  description = "The encryption type to use for the repository. Must be one of: `AES256` or `KMS`."
  type        = string
  default     = "AES256"
}

# KMS key
variable "kms_key" {
  description = "The ARN of the KMS key to use when encryption type is KMS. If not specified, uses the default AWS managed key for ECR."
  type        = string
  default     = null
}
