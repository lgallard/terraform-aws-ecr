output "repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr_enhanced_security.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr_enhanced_security.repository_arn
}

output "security_status" {
  description = "Security configuration status"
  value       = module.ecr_enhanced_security.security_status
}

output "registry_scanning_status" {
  description = "Registry scanning configuration status"
  value       = module.ecr_enhanced_security.registry_scanning_status
}

output "pull_through_cache_rules" {
  description = "List of configured pull-through cache rules"
  value       = module.ecr_enhanced_security.pull_through_cache_rules
}

output "pull_through_cache_role_arn" {
  description = "ARN of the pull-through cache IAM role"
  value       = module.ecr_enhanced_security.pull_through_cache_role_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = module.ecr_enhanced_security.kms_key_arn
}
