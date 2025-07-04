# Cost allocation example outputs
output "cost_allocation_repo_url" {
  description = "URL of the cost allocation repository"
  value       = module.ecr_cost_allocation.repository_url
}

output "cost_allocation_applied_tags" {
  description = "Final tags applied to cost allocation repository"
  value       = module.ecr_cost_allocation.applied_tags
}

output "cost_allocation_tagging_strategy" {
  description = "Tagging strategy used for cost allocation repository"
  value       = module.ecr_cost_allocation.tagging_strategy
}

# Compliance example outputs
output "compliance_repo_url" {
  description = "URL of the compliance repository"
  value       = module.ecr_compliance.repository_url
}

output "compliance_applied_tags" {
  description = "Final tags applied to compliance repository"
  value       = module.ecr_compliance.applied_tags
}

output "compliance_tag_compliance_status" {
  description = "Tag compliance status for compliance repository"
  value       = module.ecr_compliance.tag_compliance_status
}

# SDLC example outputs
output "sdlc_repo_url" {
  description = "URL of the SDLC repository"
  value       = module.ecr_sdlc.repository_url
}

output "sdlc_applied_tags" {
  description = "Final tags applied to SDLC repository"
  value       = module.ecr_sdlc.applied_tags
}

# Custom defaults example outputs
output "custom_defaults_repo_url" {
  description = "URL of the custom defaults repository"
  value       = module.ecr_custom_defaults.repository_url
}

output "custom_defaults_applied_tags" {
  description = "Final tags applied to custom defaults repository"
  value       = module.ecr_custom_defaults.applied_tags
}

# Legacy compatibility example outputs
output "legacy_repo_url" {
  description = "URL of the legacy compatible repository"
  value       = module.ecr_legacy_compatible.repository_url
}

output "legacy_applied_tags" {
  description = "Final tags applied to legacy repository"
  value       = module.ecr_legacy_compatible.applied_tags
}

# Summary outputs
output "tagging_examples_summary" {
  description = "Summary of all tagging examples and their strategies"
  value = {
    cost_allocation = {
      template_used         = "cost_allocation"
      validation_enabled    = true
      normalization_enabled = true
      key_case              = "PascalCase"
    }
    compliance = {
      template_used         = "compliance"
      validation_enabled    = true
      normalization_enabled = true
      key_case              = "PascalCase"
    }
    sdlc = {
      template_used         = "sdlc"
      validation_enabled    = true
      normalization_enabled = true
      key_case              = "camelCase"
    }
    custom_defaults = {
      template_used         = null
      validation_enabled    = true
      normalization_enabled = true
      key_case              = "snake_case"
    }
    legacy_compatible = {
      template_used         = null
      validation_enabled    = false
      normalization_enabled = false
      key_case              = null
    }
  }
}