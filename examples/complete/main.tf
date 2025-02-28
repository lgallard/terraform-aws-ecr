# Get current AWS account ID
data "aws_caller_identity" "current" {}

module "ecr" {

  source = "../.."

  name                 = "ecr-repo-dev"
  timeouts_delete      = "60m"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  encryption_type      = "KMS"

  image_scanning_configuration = {
    scan_on_push = true
  }


  # Note that currently only one policy may be applied to a repository.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LimitedAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      },
      {
        Sid    = "AdminAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  })

  # Only one lifecycle policy can be used per repository.
  # To apply multiple rules, combine them in one policy JSON.
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Tags - using merge to combine with default tags
  tags = merge(
    {
      Name        = "ecr-repo-dev"
      Owner       = "DevOps team"
      Environment = "development"
      Project     = "example"
      CreatedAt   = timestamp()
    },
    var.tags
  )

}
