resource "aws_ecr_repository" "repo" {
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

  tags = merge(
    {
      "Name"      = var.name
      "ManagedBy" = "Terraform"
    },
    var.tags
  )
}

# Repository policy - controls access to the repository
resource "aws_ecr_repository_policy" "policy" {
  count      = var.policy == null ? 0 : 1
  repository = aws_ecr_repository.repo.name
  policy     = var.policy

  # Ensure policy is applied after repository is created
  depends_on = [aws_ecr_repository.repo]
}

# Lifecycle policy - controls image retention and cleanup
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count      = var.lifecycle_policy == null ? 0 : 1
  repository = aws_ecr_repository.repo.name
  policy     = var.lifecycle_policy

  # Ensure policy is applied after repository is created
  depends_on = [aws_ecr_repository.repo]
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# KMS key
resource "aws_kms_key" "kms_key" {
  count                   = local.should_create_kms_key ? 1 : 0
  description             = "KMS key for ECR repository ${var.name} encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = false

  tags = merge(
    {
      Name      = "${var.name}-kms-key"
      ManagedBy = "Terraform"
    },
    var.tags
  )

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM Root User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow ECR Service to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:Encrypt"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Key Users"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# KMS alias for easier key identification and management
resource "aws_kms_alias" "kms_key_alias" {
  count         = local.should_create_kms_key ? 1 : 0
  name          = "alias/ecr/${var.name}"
  target_key_id = aws_kms_key.kms_key[0].key_id

  # Note: AWS KMS aliases don't support tags directly,
  # but we're adding a lifecycle rule to prevent unnecessary updates
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Determine if we need to create a new KMS key
  should_create_kms_key = var.encryption_type == "KMS" && var.kms_key == null

  # Configure encryption settings based on encryption type and KMS key
  encryption_configuration = (
    var.encryption_type == "KMS" ? [{
      encryption_type = "KMS"
      kms_key         = local.should_create_kms_key ? aws_kms_key.kms_key[0].arn : var.kms_key
    }] : []
  )

  # Image scanning configuration with default fallback
  image_scanning_configuration = [{
    scan_on_push = coalesce(
      try(var.image_scanning_configuration.scan_on_push, null),
      var.scan_on_push
    )
  }]

  # Timeouts configuration with default fallback
  timeouts = (
    length(var.timeouts) > 0 ? [var.timeouts] : (
      var.timeouts_delete != null ? [{
        delete = var.timeouts_delete
      }] : []
    )
  )
}
