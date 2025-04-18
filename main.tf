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

  tags = merge(
    {
      "Name"      = var.name
      "ManagedBy" = "Terraform"
    },
    var.tags
  )
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

  tags = merge(
    {
      "Name"      = var.name
      "ManagedBy" = "Terraform"
    },
    var.tags
  )
}

# Local reference to whichever repository was created
locals {
  repository_id   = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].id : aws_ecr_repository.repo[0].id
  repository_name = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].name : aws_ecr_repository.repo[0].name
  repository_url  = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].repository_url : aws_ecr_repository.repo[0].repository_url
  registry_id     = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].registry_id : aws_ecr_repository.repo[0].registry_id
}

# Repository policy - controls access to the repository
resource "aws_ecr_repository_policy" "policy" {
  count      = var.policy == null ? 0 : 1
  repository = local.repository_name
  policy     = var.policy

  # Ensure policy is applied after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
}

# Lifecycle policy - controls image retention and cleanup
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count      = var.lifecycle_policy == null ? 0 : 1
  repository = local.repository_name
  policy     = var.lifecycle_policy

  # Ensure policy is applied after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
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

# CloudWatch Log Group for ECR logs
resource "aws_cloudwatch_log_group" "ecr_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/ecr/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Name      = "${var.name}-logs"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

# IAM Role for ECR logging
resource "aws_iam_role" "ecr_logging" {
  count = var.enable_logging ? 1 : 0
  name  = "ecr-logging-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name      = "${var.name}-logging-role"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

# IAM Policy for ECR logging
resource "aws_iam_role_policy" "ecr_logging" {
  count = var.enable_logging ? 1 : 0
  name  = "ecr-logging-${var.name}"
  role  = aws_iam_role.ecr_logging[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.ecr_logs[0].arn}:*"
        ]
      }
    ]
  })
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

  # Logging configuration
  logging_configuration = var.enable_logging ? {
    log_group_arn = aws_cloudwatch_log_group.ecr_logs[0].arn
    role_arn      = aws_iam_role.ecr_logging[0].arn
  } : null
}
