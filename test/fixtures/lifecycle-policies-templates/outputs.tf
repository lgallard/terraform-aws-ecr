output "repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr_template_test.repository_url
}

output "lifecycle_policy_json" {
  description = "The generated lifecycle policy JSON"
  value       = module.ecr_template_test.lifecycle_policy
}

output "repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr_template_test.repository_name
}