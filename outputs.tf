output "arn" {
  description = "Full ARN of the repository"
  value       = aws_ecr_repository.repo.arn
}

output "name" {
  description = "The name of the repository."
  value       = aws_ecr_repository.repo.name
}

output "registry_id" {
  description = "The AWS account ID associated with the registry that contains the repository"
  value       = aws_ecr_repository.repo.registry_id
}

output "repository_url" {
  value       = aws_ecr_repository.repo.repository_url
  description = "The URL of the created ECR repository."
}

output "repository_arn" {
  value       = aws_ecr_repository.repo.arn
  description = "The ARN of the created ECR repository."
}

output "kms_key_arn" {
  value       = local.should_create_kms_key ? aws_kms_key.kms_key[0].arn : var.kms_key
  description = "The ARN of the KMS key used for repository encryption."
}
