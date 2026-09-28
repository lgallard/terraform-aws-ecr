output "pull_time_update_exclusion_principal_arns" {
  description = "IAM role ARNs excluded from ECR pull-time updates"
  value       = module.ecr.pull_time_update_exclusion_principal_arns
}
