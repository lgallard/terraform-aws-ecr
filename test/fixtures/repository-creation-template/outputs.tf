output "repository_creation_template_status" {
  description = "Status of ECR repository creation template configuration"
  value       = module.repository_creation_template.repository_creation_template_status
}

output "repository_creation_templates" {
  description = "Map of ECR repository creation templates keyed by prefix"
  value       = module.repository_creation_template.repository_creation_templates
}
