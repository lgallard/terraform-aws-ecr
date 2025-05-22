# Handle state migration for the repository resource
# This ensures the existing aws_ecr_repository.repo is moved to aws_ecr_repository.repo[0]
# when protect_destroy=false or to aws_ecr_repository.repo_protected[0] when protect_destroy=true
moved {
  from = aws_ecr_repository.repo
  to   = aws_ecr_repository.repo[0]
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
