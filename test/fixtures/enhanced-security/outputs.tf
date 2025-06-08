output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "security_status" {
  description = "Security configuration status"
  value       = module.ecr.security_status
}

output "registry_scanning_status" {
  description = "Registry scanning configuration status"
  value       = module.ecr.registry_scanning_status
}

output "pull_through_cache_rules" {
  description = "Pull-through cache rules"
  value       = module.ecr.pull_through_cache_rules
}

output "registry_scanning_configuration_arn" {
  description = "Registry scanning configuration ARN"
  value       = module.ecr.registry_scanning_configuration_arn
}