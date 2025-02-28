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
  description = "The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`)"
  value       = aws_ecr_repository.repo.repository_url
}
