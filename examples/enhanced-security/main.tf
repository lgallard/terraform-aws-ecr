# Enhanced Security ECR Example
# This example demonstrates advanced security features including:
# - Enhanced scanning with AWS Inspector
# - Pull-through cache configuration
# - Secret scanning capabilities

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# ECR repository with enhanced security features
module "ecr_enhanced_security" {
  source = "../.."

  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete
  encryption_type      = "KMS"
  scan_on_push         = true

  # Enhanced scanning configuration
  enable_registry_scanning = true
  registry_scan_type       = "ENHANCED"
  enable_secret_scanning   = true

  # Enhanced scanning filters for high and critical vulnerabilities
  registry_scan_filters = [
    {
      name   = "PACKAGE_VULNERABILITY_SEVERITY"
      values = ["HIGH", "CRITICAL"]
    }
  ]

  # Pull-through cache configuration for Docker Hub
  enable_pull_through_cache = var.enable_pull_through_cache
  pull_through_cache_rules = var.enable_pull_through_cache ? [
    {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
    },
    {
      ecr_repository_prefix = "quay"
      upstream_registry_url = "quay.io"
    }
  ] : []

  # Enable logging for security monitoring
  enable_logging     = true
  log_retention_days = 90

  # Repository policy with strict access controls
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnhancedSecurityAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings"
        ]
        Condition = {
          StringEquals = {
            "ecr:ResourceTag/Environment" = var.environment
          }
        }
      },
      {
        Sid    = "SecurePushAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ECRSecurePushRole"
        }
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Condition = {
          StringEquals = {
            "ecr:ResourceTag/Environment" = var.environment
          }
        }
      }
    ]
  })

  # Lifecycle policy for security compliance
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Delete untagged images after 7 days for security"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only last 50 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "release-"]
          countType     = "imageCountMoreThan"
          countNumber   = 50
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment   = var.environment
    SecurityLevel = "Enhanced"
    Compliance    = "SOC2"
    ManagedBy     = "Terraform"
    Project       = "Enhanced-Security-ECR"
  }
}
