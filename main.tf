# ----------------------------------------------------------
# Configuration Locals
# ----------------------------------------------------------

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

# Repository output references
locals {
  # Repository output references for use in other resources and outputs
  repository_id   = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].id : aws_ecr_repository.repo[0].id
  repository_name = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].name : aws_ecr_repository.repo[0].name
  repository_url  = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].repository_url : aws_ecr_repository.repo[0].repository_url
  registry_id     = var.prevent_destroy ? aws_ecr_repository.repo_protected[0].registry_id : aws_ecr_repository.repo[0].registry_id
}

# ----------------------------------------------------------
# Repository Policies
# ----------------------------------------------------------

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
  count      = local.final_lifecycle_policy != null && local.final_lifecycle_policy != "" ? 1 : 0
  repository = local.repository_name
  policy     = local.final_lifecycle_policy

  # Ensure policy is applied after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
}

# ----------------------------------------------------------
# AWS Identity and KMS Resources
# ----------------------------------------------------------

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

# ----------------------------------------------------------
# Logging Resources
# ----------------------------------------------------------

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

# ----------------------------------------------------------
# Replication Configuration
# ----------------------------------------------------------

# ECR replication configuration for cross-region replication
resource "aws_ecr_replication_configuration" "replication" {
  count = var.enable_replication && length(var.replication_regions) > 0 ? 1 : 0

  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.replication_regions
        content {
          region      = destination.value
          registry_id = data.aws_caller_identity.current.account_id
        }
      }
    }
  }

  # Ensure replication is configured after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
}

# ----------------------------------------------------------
# Enhanced Scanning Configuration
# ----------------------------------------------------------

# Registry scanning configuration for enhanced security scanning
resource "aws_ecr_registry_scanning_configuration" "scanning" {
  count = var.enable_registry_scanning ? 1 : 0

  # Use ENHANCED scan type when secret scanning is enabled, otherwise use the configured type
  scan_type = var.enable_secret_scanning ? "ENHANCED" : var.registry_scan_type

  # Create rules for each repository filter pattern
  dynamic "rule" {
    for_each = var.scan_repository_filters
    content {
      scan_frequency = "SCAN_ON_PUSH"

      repository_filter {
        filter      = rule.value
        filter_type = "WILDCARD"
      }
    }
  }

  # Ensure scanning is configured after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]

  # Validation for secret scanning requirements
  lifecycle {
    precondition {
      condition     = !var.enable_secret_scanning || var.enable_registry_scanning
      error_message = "Secret scanning (enable_secret_scanning = true) requires registry scanning to be enabled (enable_registry_scanning = true). The scan type will be automatically set to ENHANCED when secret scanning is enabled."
    }
  }
}

# ----------------------------------------------------------
# Pull-Through Cache Configuration
# ----------------------------------------------------------

# Pull-through cache rules for upstream registries
resource "aws_ecr_pull_through_cache_rule" "cache_rules" {
  count = var.enable_pull_through_cache ? length(var.pull_through_cache_rules) : 0

  ecr_repository_prefix = var.pull_through_cache_rules[count.index].ecr_repository_prefix
  upstream_registry_url = var.pull_through_cache_rules[count.index].upstream_registry_url
  credential_arn        = var.pull_through_cache_rules[count.index].credential_arn

  # Ensure cache rules are created after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
}

# IAM role for pull-through cache operations
resource "aws_iam_role" "pull_through_cache" {
  count = var.enable_pull_through_cache && length(var.pull_through_cache_rules) > 0 ? 1 : 0
  name  = "ecr-pull-through-cache-${var.name}"

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
      Name      = "${var.name}-pull-through-cache-role"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

# IAM policy for pull-through cache operations
resource "aws_iam_role_policy" "pull_through_cache" {
  count = var.enable_pull_through_cache && length(var.pull_through_cache_rules) > 0 ? 1 : 0
  name  = "ecr-pull-through-cache-${var.name}"
  role  = aws_iam_role.pull_through_cache[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:CreateRepository",
          "ecr:BatchImportLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [
          "arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/*"
        ]
      }
    ]
  })
}

# ----------------------------------------------------------
# Configuration Locals
# ----------------------------------------------------------

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

  # ----------------------------------------------------------
  # Lifecycle Policy Generation
  # ----------------------------------------------------------

  # Template configurations
  lifecycle_templates = {
    development = {
      keep_latest_n        = 50
      expire_untagged_days = 7
      expire_tagged_days   = null
      tag_prefixes         = ["dev", "feature"]
    }
    production = {
      keep_latest_n        = 100
      expire_untagged_days = 14
      expire_tagged_days   = 90
      tag_prefixes         = ["v", "release", "prod"]
    }
    cost_optimization = {
      keep_latest_n        = 10
      expire_untagged_days = 3
      expire_tagged_days   = 30
      tag_prefixes         = []
    }
    compliance = {
      keep_latest_n        = 200
      expire_untagged_days = 30
      expire_tagged_days   = 365
      tag_prefixes         = ["v", "release", "audit"]
    }
  }

  # Determine effective lifecycle configuration
  effective_lifecycle_config = (
    var.lifecycle_policy_template != null ? local.lifecycle_templates[var.lifecycle_policy_template] : {
      keep_latest_n        = var.lifecycle_keep_latest_n_images
      expire_untagged_days = var.lifecycle_expire_untagged_after_days
      expire_tagged_days   = var.lifecycle_expire_tagged_after_days
      tag_prefixes         = var.lifecycle_tag_prefixes_to_keep
    }
  )

  # Generate lifecycle policy rules
  lifecycle_rules = [
    for rule in [
      # Rule 1: Expire untagged images
      local.effective_lifecycle_config.expire_untagged_days != null ? {
        rulePriority = 1
        description  = "Expire untagged images after ${local.effective_lifecycle_config.expire_untagged_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = local.effective_lifecycle_config.expire_untagged_days
        }
        action = {
          type = "expire"
        }
      } : null,

      # Rule 2: Keep latest N images (with tag prefixes if specified)
      local.effective_lifecycle_config.keep_latest_n != null ? {
        rulePriority = 2
        description  = length(local.effective_lifecycle_config.tag_prefixes) > 0 ? "Keep only ${local.effective_lifecycle_config.keep_latest_n} images with prefixes: ${join(", ", local.effective_lifecycle_config.tag_prefixes)}" : "Keep only ${local.effective_lifecycle_config.keep_latest_n} latest images"
        selection = merge(
          {
            tagStatus   = length(local.effective_lifecycle_config.tag_prefixes) > 0 ? "tagged" : "any"
            countType   = "imageCountMoreThan"
            countNumber = local.effective_lifecycle_config.keep_latest_n
          },
          length(local.effective_lifecycle_config.tag_prefixes) > 0 ? {
            tagPrefixList = local.effective_lifecycle_config.tag_prefixes
          } : {}
        )
        action = {
          type = "expire"
        }
      } : null,

      # Rule 3: Expire tagged images after N days
      local.effective_lifecycle_config.expire_tagged_days != null ? {
        rulePriority = 3
        description  = "Expire tagged images after ${local.effective_lifecycle_config.expire_tagged_days} days"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = local.effective_lifecycle_config.expire_tagged_days
        }
        action = {
          type = "expire"
        }
      } : null
    ] : rule if rule != null
  ]

  # Generate final lifecycle policy JSON
  generated_lifecycle_policy = length(local.lifecycle_rules) > 0 ? jsonencode({
    rules = local.lifecycle_rules
  }) : null

  # Final lifecycle policy (manual takes precedence over generated)
  # Ensure we never pass an empty string or invalid JSON to AWS
  final_lifecycle_policy = (
    var.lifecycle_policy != null && var.lifecycle_policy != "" ? var.lifecycle_policy :
    local.generated_lifecycle_policy
  )
}

# ----------------------------------------------------------
# Configuration Validation
# ----------------------------------------------------------
#
# Note: Lifecycle policy configuration uses precedence-based selection:
# 1. Manual lifecycle_policy (highest precedence)
# 2. Template lifecycle_policy_template (medium precedence)
# 3. Helper variables (lowest precedence)
#
# Multiple options can be specified - higher precedence options automatically
# override lower precedence ones as documented in the README.
