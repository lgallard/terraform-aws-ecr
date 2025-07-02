output "lifecycle_template_repository_url" {
  description = "Repository URL for lifecycle template test"
  value       = module.lifecycle_template_test.repository_url
}

output "lifecycle_helper_vars_repository_url" {
  description = "Repository URL for lifecycle helper vars test"
  value       = module.lifecycle_helper_vars_test.repository_url
}

output "lifecycle_manual_override_repository_url" {
  description = "Repository URL for lifecycle manual override test"
  value       = module.lifecycle_manual_override_test.repository_url
}
