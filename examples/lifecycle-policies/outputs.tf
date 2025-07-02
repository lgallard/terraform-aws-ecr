output "development_repository_url" {
  description = "Repository URL for development ECR"
  value       = module.ecr_development.repository_url
}

output "production_repository_url" {
  description = "Repository URL for production ECR"
  value       = module.ecr_production.repository_url
}

output "custom_repository_url" {
  description = "Repository URL for custom configured ECR"
  value       = module.ecr_custom.repository_url
}

output "cost_optimized_repository_url" {
  description = "Repository URL for cost optimized ECR"
  value       = module.ecr_cost_optimized.repository_url
}

output "compliance_repository_url" {
  description = "Repository URL for compliance ECR"
  value       = module.ecr_compliance.repository_url
}

output "manual_repository_url" {
  description = "Repository URL for manual policy ECR"
  value       = module.ecr_manual.repository_url
}
