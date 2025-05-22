# Handle state migration for the repository resources
# This ensures a smooth migration from the previous version to the new consolidated resource

# Migrate from the count-based non-protected repository to the new consolidated resource
moved {
  from = aws_ecr_repository.repo[0]
  to   = aws_ecr_repository.repo
}

# Migrate from the count-based protected repository to the new consolidated resource
moved {
  from = aws_ecr_repository.repo_protected[0]
  to   = aws_ecr_repository.repo
}

# Handle migration from the original non-count resources (for backward compatibility)
moved {
  from = aws_ecr_repository.repo
  to   = aws_ecr_repository.repo
}

# Handle dependent resources that reference the repository
moved {
  from = aws_ecr_repository_policy.policy
  to   = aws_ecr_repository_policy.policy[0]
}

moved {
  from = aws_ecr_lifecycle_policy.lifecycle_policy
  to   = aws_ecr_lifecycle_policy.lifecycle_policy[0]
}
