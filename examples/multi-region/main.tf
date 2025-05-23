################################################################################
# Multi-Region ECR Repository Example
################################################################################

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

# Create ECR repository in primary region
module "ecr_primary" {
  source = "../.."
  providers = {
    aws = aws.primary
  }

  name                 = var.repository_name
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
  }
}

# Create ECR repository in secondary region
module "ecr_secondary" {
  source = "../.."
  providers = {
    aws = aws.secondary
  }

  name                 = var.repository_name
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
  }
}

# Create ECR Replication Configuration
resource "aws_ecr_replication_configuration" "replication" {
  provider = aws.primary
  
  replication_configuration {
    rules {
      destinations {
        region      = var.secondary_region
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

# Get current account ID
data "aws_caller_identity" "current" {
  provider = aws.primary
}