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

output "lifecycle_policy" {
  description = "The lifecycle policy JSON applied to the repository (if any)"
  value       = local.final_lifecycle_policy
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
    enabled                 = var.enable_registry_scanning
    scan_type               = var.enable_registry_scanning ? (var.enable_secret_scanning ? "ENHANCED" : var.registry_scan_type) : null
    secret_scanning_enabled = var.enable_secret_scanning
    repository_filters      = var.enable_registry_scanning ? var.scan_repository_filters : []
  }
}

# Pull-through cache outputs
output "pull_through_cache_rules" {
  description = "List of pull-through cache rules (if enabled)"
  value = var.enable_pull_through_cache ? [
    for rule in aws_ecr_pull_through_cache_rule.cache_rules : {
      ecr_repository_prefix = rule.ecr_repository_prefix
      upstream_registry_url = rule.upstream_registry_url
      registry_id           = rule.registry_id
    }
  ] : []
}

output "pull_through_cache_role_arn" {
  description = "The ARN of the IAM role used for pull-through cache operations (if enabled)"
  value       = try(aws_iam_role.pull_through_cache[0].arn, null)
}

output "registry_scan_filters" {
  description = "The configured scan filters for filtering scan results (e.g., by vulnerability severity)"
  value       = var.registry_scan_filters
}

output "security_status" {
  description = "Comprehensive security status of the ECR configuration"
  value = {
    basic_scanning_enabled     = local.image_scanning_configuration[0].scan_on_push
    enhanced_scanning_enabled  = var.enable_registry_scanning
    secret_scanning_enabled    = var.enable_secret_scanning
    pull_through_cache_enabled = var.enable_pull_through_cache
    encryption_type            = var.encryption_type
    kms_encryption_enabled     = var.encryption_type == "KMS"
    image_tag_mutability       = var.image_tag_mutability
    replication_enabled        = var.enable_replication
    scan_filters_configured    = length(var.registry_scan_filters) > 0
  }
}

# ----------------------------------------------------------
# Advanced Tagging Outputs
# ----------------------------------------------------------

output "applied_tags" {
  description = "The final set of tags applied to all resources after normalization and default tag application"
  value       = local.final_tags
}

output "tagging_strategy" {
  description = "Summary of the tagging strategy configuration"
  value = {
    default_tags_enabled      = var.enable_default_tags
    default_tags_template     = var.default_tags_template
    tag_validation_enabled    = var.enable_tag_validation
    tag_normalization_enabled = var.enable_tag_normalization
    tag_key_case              = var.tag_key_case
    required_tags             = var.required_tags
    computed_default_tags     = local.computed_default_tags
  }
}

output "tag_compliance_status" {
  description = "Tag compliance and validation status"
  value = {
    validation_enabled    = var.enable_tag_validation
    validation_passed     = var.enable_tag_validation ? local.tag_validation_check : null
    required_tags_present = var.enable_tag_validation ? length(local.missing_required_tags) == 0 : null
    missing_required_tags = var.enable_tag_validation ? local.missing_required_tags : []
    total_tags_applied    = length(local.final_tags)
    normalization_enabled = var.enable_tag_normalization
    tag_key_case          = var.tag_key_case
  }
}

# ----------------------------------------------------------
# Monitoring Outputs
# ----------------------------------------------------------

output "monitoring_status" {
  description = "Status of CloudWatch monitoring configuration"
  value = {
    enabled                     = var.enable_monitoring
    storage_threshold_gb        = var.enable_monitoring ? var.monitoring_threshold_storage : null
    api_calls_threshold         = var.enable_monitoring ? var.monitoring_threshold_api_calls : null
    security_findings_threshold = var.enable_monitoring ? var.monitoring_threshold_security_findings : null
    sns_topic_created           = var.enable_monitoring && var.create_sns_topic
    sns_topic_name              = var.enable_monitoring && var.create_sns_topic ? aws_sns_topic.ecr_monitoring[0].name : null
    sns_subscribers_count       = var.enable_monitoring && var.create_sns_topic ? length(var.sns_topic_subscribers) : 0
    security_monitoring_enabled = var.enable_monitoring && var.enable_registry_scanning
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for ECR monitoring alerts (if created)"
  value       = var.enable_monitoring && var.create_sns_topic ? aws_sns_topic.ecr_monitoring[0].arn : null
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch alarms created for ECR monitoring"
  value = var.enable_monitoring ? {
    storage_usage_alarm = {
      name = aws_cloudwatch_metric_alarm.repository_storage_usage[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.repository_storage_usage[0].arn
    }
    api_calls_alarm = {
      name = aws_cloudwatch_metric_alarm.api_call_volume[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.api_call_volume[0].arn
    }
    image_push_alarm = {
      name = aws_cloudwatch_metric_alarm.image_push_count[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.image_push_count[0].arn
    }
    image_pull_alarm = {
      name = aws_cloudwatch_metric_alarm.image_pull_count[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.image_pull_count[0].arn
    }
    security_findings_alarm = var.enable_registry_scanning ? {
      name = aws_cloudwatch_metric_alarm.security_findings[0].alarm_name
      arn  = aws_cloudwatch_metric_alarm.security_findings[0].arn
    } : null
  } : {}
}
