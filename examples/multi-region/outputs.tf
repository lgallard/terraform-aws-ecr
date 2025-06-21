# Built-in Replication Outputs (recommended approach)
output "replicated_repository_url" {
  description = "URL of the ECR repository with built-in replication"
  value       = module.ecr_with_replication.repository_url
}

output "replicated_repository_arn" {
  description = "ARN of the ECR repository with built-in replication"
  value       = module.ecr_with_replication.repository_arn
}

output "replication_status" {
  description = "Replication configuration status"
  value       = module.ecr_with_replication.replication_status
}

output "replication_regions" {
  description = "Regions where images are replicated"
  value       = module.ecr_with_replication.replication_regions
}

# Manual Setup Outputs (alternative approach)
output "primary_repository_url" {
  description = "URL of the primary ECR repository (manual setup)"
  value       = var.use_manual_setup ? module.ecr_primary[0].repository_url : null
}

output "primary_repository_arn" {
  description = "ARN of the primary ECR repository (manual setup)"
  value       = var.use_manual_setup ? module.ecr_primary[0].repository_arn : null
}

output "secondary_repository_url" {
  description = "URL of the secondary ECR repository (manual setup)"
  value       = var.use_manual_setup ? module.ecr_secondary[0].repository_url : null
}

output "secondary_repository_arn" {
  description = "ARN of the secondary ECR repository (manual setup)"
  value       = var.use_manual_setup ? module.ecr_secondary[0].repository_arn : null
}

# Comparison Output
output "approach_summary" {
  description = "Summary of the multi-region approach being used"
  value = {
    built_in_replication = var.enable_replication
    manual_setup         = var.use_manual_setup
    primary_region       = var.primary_region
    secondary_region     = var.secondary_region
  }
}