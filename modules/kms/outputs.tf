# ----------------------------------------------------------
# KMS Key Outputs
# ----------------------------------------------------------

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key"
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "The globally unique identifier for the KMS key"
  value       = aws_kms_key.this.key_id
}

output "key_usage" {
  description = "The key usage of the KMS key"
  value       = aws_kms_key.this.key_usage
}

output "multi_region" {
  description = "Whether the KMS key is a multi-region key"
  value       = aws_kms_key.this.multi_region
}

output "enable_key_rotation" {
  description = "Whether key rotation is enabled"
  value       = aws_kms_key.this.enable_key_rotation
}

output "rotation_period_in_days" {
  description = "The rotation period for the KMS key in days"
  value       = aws_kms_key.this.rotation_period_in_days
}

output "deletion_window_in_days" {
  description = "The deletion window for the KMS key in days"
  value       = aws_kms_key.this.deletion_window_in_days
}

# ----------------------------------------------------------
# KMS Alias Outputs
# ----------------------------------------------------------

output "alias_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS alias"
  value       = var.create_alias ? aws_kms_alias.this[0].arn : null
}

output "alias_name" {
  description = "The display name of the KMS alias"
  value       = var.create_alias ? aws_kms_alias.this[0].name : null
}

output "target_key_id" {
  description = "The key identifier that the alias refers to"
  value       = var.create_alias ? aws_kms_alias.this[0].target_key_id : null
}

# ----------------------------------------------------------
# Combined Outputs
# ----------------------------------------------------------

output "kms_key" {
  description = "Complete KMS key information"
  value = {
    arn                     = aws_kms_key.this.arn
    id                      = aws_kms_key.this.key_id
    usage                   = aws_kms_key.this.key_usage
    multi_region            = aws_kms_key.this.multi_region
    enable_key_rotation     = aws_kms_key.this.enable_key_rotation
    rotation_period_in_days = aws_kms_key.this.rotation_period_in_days
    deletion_window_in_days = aws_kms_key.this.deletion_window_in_days
  }
}

output "kms_alias" {
  description = "Complete KMS alias information"
  value = var.create_alias ? {
    arn           = aws_kms_alias.this[0].arn
    name          = aws_kms_alias.this[0].name
    target_key_id = aws_kms_alias.this[0].target_key_id
  } : null
}

# ----------------------------------------------------------
# Configuration Summary
# ----------------------------------------------------------

output "configuration_summary" {
  description = "Summary of KMS configuration"
  value = {
    key_created                 = true
    alias_created               = var.create_alias
    default_policy_enabled      = var.enable_default_policy
    ecr_service_allowed         = var.allow_ecr_service
    administrators_count        = length(var.key_administrators)
    users_count                 = length(var.key_users)
    additional_principals_count = length(var.additional_principals)
    custom_statements_count     = length(var.custom_policy_statements)
    custom_policy_used          = var.custom_policy != null
    key_rotation_enabled        = var.enable_key_rotation
    rotation_period             = var.key_rotation_period
    multi_region                = var.multi_region
    tags_applied                = local.final_tags
  }
}
