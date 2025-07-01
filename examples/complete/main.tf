# Get current AWS account ID
data "aws_caller_identity" "current" {}

module "ecr" {
  source = "../.."

  name                 = "complete-ecr-repo"
  timeouts_delete      = "60m"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  encryption_type      = "KMS"

  # Enable logging configuration
  enable_logging     = true
  log_retention_days = 14

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
  # NOTE: For demonstration of enhanced lifecycle policy features,
  # see examples/lifecycle-policies/ directory
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
      Name        = "complete-ecr-repo"
      Owner       = "DevOps team"
      Environment = "development"
      Project     = "example"
    },
    var.tags
  )
}

# Example of a protected repository with enhanced security settings
module "ecr_protected" {
  source = "../.."

  name                 = "protected-ecr-repo"
  timeouts_delete      = "60m"
  image_tag_mutability = "IMMUTABLE" # Prevent image tags from being overwritten
  force_delete         = false       # Prevent accidental deletion of images
  prevent_destroy      = true        # Protect repository from being destroyed via Terraform
  encryption_type      = "KMS"       # Enable KMS encryption

  image_scanning_configuration = {
    scan_on_push = true # Enable vulnerability scanning
  }

  # Repository policy with stricter access controls
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RestrictedAccess"
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
        Condition = {
          StringLike = {
            "aws:PrincipalArn" : [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AllowedECRRole",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ProductionDeployRole"
            ]
          }
        }
      }
    ]
  })

  # Strict lifecycle policy for production images
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep tagged images indefinitely"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "release"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 36500 # ~100 years
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images after 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Tags for production repository
  tags = merge(
    {
      Name        = "protected-ecr-repo"
      Owner       = "DevOps team"
      Environment = "production"
      Project     = "example"
      Protected   = "true"
    },
    var.tags
  )
}

# Example using enhanced lifecycle policy features instead of manual JSON
module "ecr_enhanced_lifecycle" {
  source = "../.."

  name                 = "enhanced-lifecycle-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  encryption_type      = "KMS"

  # Enhanced lifecycle policy using helper variables
  lifecycle_keep_latest_n_images       = 50
  lifecycle_expire_untagged_after_days = 7
  lifecycle_expire_tagged_after_days   = 90
  lifecycle_tag_prefixes_to_keep       = ["v", "release", "stable"]

  image_scanning_configuration = {
    scan_on_push = true
  }

  # Tags for enhanced example
  tags = merge(
    {
      Name        = "enhanced-lifecycle-repo"
      Owner       = "DevOps team"
      Environment = "development"
      Project     = "example"
      LifecyclePolicy = "enhanced"
    },
    var.tags
  )
}
