# ----------------------------------------------------------
# Outputs for Pull-Through Cache Example
# ----------------------------------------------------------

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr_with_pull_through_cache.repository_url
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr_with_pull_through_cache.repository_arn
}

output "pull_through_cache_rules" {
  description = "List of configured pull-through cache rules"
  value       = module.ecr_with_pull_through_cache.pull_through_cache_rules
}

output "pull_through_cache_role_arn" {
  description = "ARN of the IAM role used for pull-through cache operations"
  value       = module.ecr_with_pull_through_cache.pull_through_cache_role_arn
}

output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = module.ecr_with_pull_through_cache.registry_id
}

# ----------------------------------------------------------
# Usage Examples Outputs
# ----------------------------------------------------------

output "docker_pull_examples" {
  description = "Example docker pull commands using the configured cache rules"
  value = {
    docker_hub = "docker pull ${module.ecr_with_pull_through_cache.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/docker-hub/library/nginx:latest"
    quay       = "docker pull ${module.ecr_with_pull_through_cache.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/quay/prometheus/prometheus:latest"
    ghcr       = "docker pull ${module.ecr_with_pull_through_cache.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/ghcr/actions/runner:latest"
    public_ecr = "docker pull ${module.ecr_with_pull_through_cache.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/public-ecr/amazonlinux:latest"
  }
}

# Data source for current AWS region
data "aws_region" "current" {}