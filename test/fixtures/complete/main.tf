provider "aws" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

module "ecr" {
  source = "../../../"

  name                 = var.name
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true  # Set to true for tests to ensure clean teardown
  encryption_type      = "KMS" # Test KMS encryption

  # Repository policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TestPolicy"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })

  # Lifecycle policy
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = "test"
    Terraform   = "true"
    Test        = "true"
  }
}