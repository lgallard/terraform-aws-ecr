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
