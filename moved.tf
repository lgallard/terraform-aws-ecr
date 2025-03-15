# Handle state migration for the repository resource
# This ensures the existing aws_ecr_repository.repo is moved to aws_ecr_repository.repo[0]
# when protect_destroy=false or to aws_ecr_repository.repo_protected[0] when protect_destroy=true
moved {
  from = aws_ecr_repository.repo
  to   = aws_ecr_repository.repo[0]

  # This block will be applied when upgrading this module and prevent_destroy=false
}

moved {
  from = aws_ecr_repository.repo
  to   = aws_ecr_repository.repo_protected[0]

  # This block will be applied when upgrading this module and prevent_destroy=true
}

# Also handle dependent resources that reference the repository
moved {
  from = aws_ecr_repository_policy.policy
  to   = aws_ecr_repository_policy.policy[0]

  # This is needed because we already had a count on this resource
}

moved {
  from = aws_ecr_lifecycle_policy.lifecycle_policy
  to   = aws_ecr_lifecycle_policy.lifecycle_policy[0]

  # This is needed because we already had a count on this resource
}
