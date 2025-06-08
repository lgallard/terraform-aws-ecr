output "repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr_with_replication.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr_with_replication.repository_arn
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr_with_replication.repository_name
}

output "replication_status" {
  description = "Replication configuration status"
  value       = module.ecr_with_replication.replication_status
}

output "replication_regions" {
  description = "Regions where images are replicated"
  value       = module.ecr_with_replication.replication_regions
}

output "replication_configuration_arn" {
  description = "ARN of the replication configuration"
  value       = module.ecr_with_replication.replication_configuration_arn
}