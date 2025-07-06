variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "trusted_account_id" {
  description = "AWS Account ID that should have cross-account access to the KMS key"
  type        = string
  default     = "111122223333"
}
