# ECR repository details
output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = local.repository_id
}

output "repository_url" {
  description = "URL of the ECR repository"
  value       = local.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = local.repository_name
}

output "registry_id" {
  description = "ID of the ECR registry"
  value       = local.registry_id
}

output "kms_key_arn" {
  value       = local.should_create_kms_key ? aws_kms_key.kms_key[0].arn : var.kms_key
  description = "The ARN of the KMS key used for repository encryption."
}

# Logging outputs
output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group used for ECR logs (if logging is enabled)"
  value       = try(aws_cloudwatch_log_group.ecr_logs[0].arn, null)
}

output "logging_role_arn" {
  description = "The ARN of the IAM role used for ECR logging (if logging is enabled)"
  value       = try(aws_iam_role.ecr_logging[0].arn, null)
}

# Replication outputs
output "replication_configuration_arn" {
  description = "The ARN of the ECR replication configuration (if replication is enabled)"
  value       = try(aws_ecr_replication_configuration.replication[0].id, null)
}

output "replication_regions" {
  description = "List of regions where ECR images are replicated to (if replication is enabled)"
  value       = var.enable_replication ? var.replication_regions : []
}

output "replication_status" {
  description = "Status of ECR replication configuration"
  value = {
    enabled = var.enable_replication
    regions = var.enable_replication ? var.replication_regions : []
  }
}

# Enhanced scanning outputs
output "registry_scanning_configuration_arn" {
  description = "The ARN of the ECR registry scanning configuration (if enhanced scanning is enabled)"
  value       = try(aws_ecr_registry_scanning_configuration.scanning[0].id, null)
}

output "registry_scanning_status" {
  description = "Status of ECR registry scanning configuration"
  value = {
    enabled                = var.enable_registry_scanning
    scan_type             = var.enable_registry_scanning ? var.registry_scan_type : null
    secret_scanning_enabled = var.enable_secret_scanning
  }
}

# Pull-through cache outputs
output "pull_through_cache_rules" {
  description = "List of pull-through cache rules (if enabled)"
  value = var.enable_pull_through_cache ? [
    for rule in aws_ecr_pull_through_cache_rule.cache_rules : {
      ecr_repository_prefix = rule.ecr_repository_prefix
      upstream_registry_url = rule.upstream_registry_url
      registry_id          = rule.registry_id
    }
  ] : []
}

output "pull_through_cache_role_arn" {
  description = "The ARN of the IAM role used for pull-through cache operations (if enabled)"
  value       = try(aws_iam_role.pull_through_cache[0].arn, null)
}

output "security_status" {
  description = "Comprehensive security status of the ECR configuration"
  value = {
    basic_scanning_enabled     = local.image_scanning_configuration[0].scan_on_push
    enhanced_scanning_enabled  = var.enable_registry_scanning
    secret_scanning_enabled   = var.enable_secret_scanning
    pull_through_cache_enabled = var.enable_pull_through_cache
    encryption_type           = var.encryption_type
    kms_encryption_enabled    = var.encryption_type == "KMS"
    image_tag_mutability      = var.image_tag_mutability
    replication_enabled       = var.enable_replication
  }
}
