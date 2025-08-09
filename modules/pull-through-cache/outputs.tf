# ----------------------------------------------------------
# Outputs for Pull-Through Cache Submodule
# ----------------------------------------------------------

output "pull_through_cache_rules" {
  description = "List of pull-through cache rules"
  value = [
    for rule in aws_ecr_pull_through_cache_rule.cache_rules : {
      ecr_repository_prefix = rule.ecr_repository_prefix
      upstream_registry_url = rule.upstream_registry_url
      registry_id           = rule.registry_id
    }
  ]
}

output "pull_through_cache_role_arn" {
  description = "The ARN of the IAM role used for pull-through cache operations"
  value       = try(aws_iam_role.pull_through_cache[0].arn, null)
}

output "pull_through_cache_role_name" {
  description = "The name of the IAM role used for pull-through cache operations"
  value       = try(aws_iam_role.pull_through_cache[0].name, null)
}