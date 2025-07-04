output "advanced_tagging_repository_url" {
  description = "Repository URL for advanced tagging test"
  value       = module.ecr_advanced_tagging.repository_url
}

output "advanced_tagging_applied_tags" {
  description = "Applied tags for advanced tagging test"
  value       = module.ecr_advanced_tagging.applied_tags
}

output "advanced_tagging_strategy" {
  description = "Tagging strategy for advanced tagging test"
  value       = module.ecr_advanced_tagging.tagging_strategy
}

output "advanced_tagging_compliance_status" {
  description = "Tag compliance status for advanced tagging test"
  value       = module.ecr_advanced_tagging.tag_compliance_status
}

output "basic_tagging_repository_url" {
  description = "Repository URL for basic tagging test"
  value       = module.ecr_basic_tagging.repository_url
}

output "basic_tagging_applied_tags" {
  description = "Applied tags for basic tagging test"
  value       = module.ecr_basic_tagging.applied_tags
}

output "legacy_tagging_repository_url" {
  description = "Repository URL for legacy tagging test"
  value       = module.ecr_legacy_tagging.repository_url
}

output "legacy_tagging_applied_tags" {
  description = "Applied tags for legacy tagging test"
  value       = module.ecr_legacy_tagging.applied_tags
}
