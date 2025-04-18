# Default repository outputs
output "repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "registry_id" {
  description = "ID of the ECR registry"
  value       = module.ecr.registry_id
}

# Logging outputs
output "ecr_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for ECR logs"
  value       = module.ecr.cloudwatch_log_group_arn
}

output "ecr_logging_role_arn" {
  description = "ARN of the IAM role used for ECR logging"
  value       = module.ecr.logging_role_arn
}

# Protected repository outputs
output "protected_repository_url" {
  description = "URL of the protected ECR repository"
  value       = module.ecr_protected.repository_url
}

output "protected_repository_arn" {
  description = "ARN of the protected ECR repository"
  value       = module.ecr_protected.repository_arn
}

output "protected_repository_name" {
  description = "Name of the protected ECR repository"
  value       = module.ecr_protected.repository_name
}
