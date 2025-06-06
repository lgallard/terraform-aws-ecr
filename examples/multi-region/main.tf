################################################################################
# Multi-Region ECR Repository Example
################################################################################
# This example demonstrates two approaches for multi-region ECR setups:
# 1. Built-in replication using the module's replication features
# 2. Manual multi-region setup with separate repositories

# Primary region provider
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

# Secondary region provider
provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

# Approach 1: Using Built-in Replication (Recommended)
# This approach uses the module's built-in replication feature
module "ecr_with_replication" {
  source = "../.."
  providers = {
    aws = aws.primary
  }

  name                 = "${var.repository_name}-replicated"
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"

  # Enable automatic replication to secondary region
  enable_replication  = var.enable_replication
  replication_regions = var.enable_replication ? [var.secondary_region] : []

  # Optional: Enable logging for monitoring
  enable_logging = var.enable_logging

  tags = {
    Environment = var.environment
    Approach    = "built-in-replication"
    ManagedBy   = "Terraform"
  }
}

# Approach 2: Manual Multi-Region Setup (Alternative)
# This approach manually creates repositories in each region
# Create ECR repository in primary region
module "ecr_primary" {
  count = var.use_manual_setup ? 1 : 0
  source = "../.."
  providers = {
    aws = aws.primary
  }

  name                 = "${var.repository_name}-manual"
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"  # Use immutable tags for consistency across regions
  
  # Example policy allowing replication
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossRegionReplication"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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

  tags = {
    Environment = var.environment
    Region      = var.primary_region
    Replication = "source"
    Approach    = "manual-setup"
  }
}

# Create ECR repository in secondary region (manual approach)
module "ecr_secondary" {
  count = var.use_manual_setup ? 1 : 0
  source = "../.."
  providers = {
    aws = aws.secondary
  }

  name                 = "${var.repository_name}-manual"
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"  # Match primary region configuration
  
  # Example policy - more restrictive since this is a replica
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LimitedPullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })

  # Use same lifecycle policy as primary for consistency
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

  tags = {
    Environment = var.environment
    Region      = var.secondary_region
    Replication = "replica"
    Approach    = "manual-setup"
  }
}

# Manual replication configuration (only for manual approach)
resource "aws_ecr_replication_configuration" "manual_replication" {
  count    = var.use_manual_setup ? 1 : 0
  provider = aws.primary
  
  replication_configuration {
    rule {
      destination {
        region      = var.secondary_region
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }

  # Ensure replication is configured after repositories are created
  depends_on = [
    module.ecr_primary,
    module.ecr_secondary
  ]
}

# Get current account ID
data "aws_caller_identity" "current" {
  provider = aws.primary
}