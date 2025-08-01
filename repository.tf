# ----------------------------------------------------------
# ECR Repository Resources
# ----------------------------------------------------------

# ----------------------------------------------------------
# AWS Identity Data Sources
# ----------------------------------------------------------

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# ----------------------------------------------------------
# ECR Repository
# ----------------------------------------------------------

# ECR Repository - Standard version (prevent_destroy = false)
resource "aws_ecr_repository" "repo" {
  count                = var.prevent_destroy ? 0 : 1
  name                 = var.name
  force_delete         = var.force_delete
  image_tag_mutability = var.image_tag_mutability

  # Encryption configuration for the repository
  dynamic "encryption_configuration" {
    for_each = local.encryption_configuration
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key
    }
  }

  # Configure image scanning settings
  dynamic "image_scanning_configuration" {
    for_each = local.image_scanning_configuration
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  # Repository deletion timeout settings
  dynamic "timeouts" {
    for_each = local.timeouts
    content {
      delete = timeouts.value.delete
    }
  }

  tags = local.final_tags
}

# Repository with prevent_destroy enabled
resource "aws_ecr_repository" "repo_protected" {
  count                = var.prevent_destroy ? 1 : 0
  name                 = var.name
  force_delete         = var.force_delete
  image_tag_mutability = var.image_tag_mutability

  # Encryption configuration for the repository
  dynamic "encryption_configuration" {
    for_each = local.encryption_configuration
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key
    }
  }

  # Configure image scanning settings
  dynamic "image_scanning_configuration" {
    for_each = local.image_scanning_configuration
    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  # Repository deletion timeout settings
  dynamic "timeouts" {
    for_each = local.timeouts
    content {
      delete = timeouts.value.delete
    }
  }

  # Prevent accidental deletion of the repository
  lifecycle {
    prevent_destroy = true
  }

  tags = local.final_tags
}

# ----------------------------------------------------------
# Repository Output References
# ----------------------------------------------------------

# Repository output references for use in other resources and outputs
locals {
  repository_id   = var.prevent_destroy ? one(aws_ecr_repository.repo_protected[*].id) : one(aws_ecr_repository.repo[*].id)
  repository_name = var.prevent_destroy ? one(aws_ecr_repository.repo_protected[*].name) : one(aws_ecr_repository.repo[*].name)
  repository_url  = var.prevent_destroy ? one(aws_ecr_repository.repo_protected[*].repository_url) : one(aws_ecr_repository.repo[*].repository_url)
  registry_id     = var.prevent_destroy ? one(aws_ecr_repository.repo_protected[*].registry_id) : one(aws_ecr_repository.repo[*].registry_id)
}
