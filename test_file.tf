# Test file to demonstrate Claude Code Review functionality
# This file contains intentional issues for testing the review modes

resource "aws_ecr_repository" "test_repo" {
  name                 = "test-repo"
  image_tag_mutability = "MUTABLE" # Potential security issue - should be IMMUTABLE

  # Missing encryption configuration - security vulnerability
  # Missing image scanning configuration - security issue

  lifecycle {
    prevent_destroy = true
  }

  # Hard-coded values instead of variables - code quality issue
  tags = {
    Environment = "dev" # Should use variables
    Team        = "platform"
  }
}

# Performance issue - inefficient resource creation pattern
resource "aws_ecr_lifecycle_policy" "test_policy" {
  repository = aws_ecr_repository.test_repo.name

  # Inefficient JSON encoding - should use templatefile
  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# Bug: Missing required argument
resource "aws_ecr_repository_policy" "test_repo_policy" {
  repository = aws_ecr_repository.test_repo.name
  # Missing policy argument - this will cause terraform error
}
