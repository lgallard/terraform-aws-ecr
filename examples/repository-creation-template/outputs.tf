output "repository_creation_templates" {
  description = "Map of ECR repository creation templates keyed by prefix"
  value       = module.ecr_with_repository_creation_templates.repository_creation_templates
}

output "repository_creation_template_status" {
  description = "Status of ECR repository creation template configuration"
  value       = module.ecr_with_repository_creation_templates.repository_creation_template_status
}

output "pull_through_cache_rules" {
  description = "Configured pull-through cache rules"
  value       = module.ecr_with_repository_creation_templates.pull_through_cache_rules
}
