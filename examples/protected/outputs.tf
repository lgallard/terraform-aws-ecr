output "repository_url" {
  description = "URL of the protected ECR repository"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the protected ECR repository"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the protected ECR repository"
  value       = module.ecr.repository_name
}

output "registry_id" {
  description = "ID of the ECR registry"
  value       = module.ecr.registry_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = module.ecr.kms_key_arn
}
