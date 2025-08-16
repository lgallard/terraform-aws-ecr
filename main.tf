# ----------------------------------------------------------
# KMS Module Integration
# ----------------------------------------------------------

# Local configuration for modules
locals {
  kms_modules = local.should_create_kms_key ? {
    kms = {}
  } : {}

  logging_resources = var.enable_logging ? {
    log_group = {
      name              = "/aws/ecr/${var.name}"
      retention_in_days = var.log_retention_days
      tag_name         = "${var.name}-logs"
    }
    iam_role = {
      name     = "ecr-logging-${var.name}"
      tag_name = "${var.name}-logging-role"
    }
  } : {}

  replication_configs = var.enable_replication && length(var.replication_regions) > 0 ? {
    replication = {
      regions = var.replication_regions
    }
  } : {}

  scanning_configs = var.enable_registry_scanning ? {
    scanning = {
      scan_type = var.enable_secret_scanning ? "ENHANCED" : var.registry_scan_type
      filters   = var.scan_repository_filters
    }
  } : {}

  pull_through_cache_modules = var.enable_pull_through_cache && length(var.pull_through_cache_rules) > 0 ? {
    cache = {}
  } : {}
}

# KMS key submodule
module "kms" {
  for_each = local.kms_modules
  source   = "./modules/kms"

  name           = var.name
  aws_account_id = data.aws_caller_identity.current.account_id

  # Enhanced configuration options
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  key_rotation_period     = var.kms_key_rotation_period
  multi_region            = var.kms_multi_region

  # Policy configuration
  additional_principals    = var.kms_additional_principals
  key_administrators       = var.kms_key_administrators
  key_users                = var.kms_key_users
  custom_policy_statements = var.kms_custom_policy_statements
  custom_policy            = var.kms_custom_policy

  # Alias configuration
  alias_name = var.kms_alias_name

  # Tagging
  tags     = local.final_tags
  kms_tags = var.kms_tags
}

# ----------------------------------------------------------
# Logging Resources
# ----------------------------------------------------------

# CloudWatch Log Group for ECR logs
resource "aws_cloudwatch_log_group" "ecr_logs" {
  for_each = { for k, v in local.logging_resources : k => v if k == "log_group" }

  name              = each.value.name
  retention_in_days = each.value.retention_in_days

  tags = merge(
    local.final_tags,
    {
      Name = each.value.tag_name
    }
  )
}

# IAM Role for ECR logging
resource "aws_iam_role" "ecr_logging" {
  for_each = { for k, v in local.logging_resources : k => v if k == "iam_role" }

  name = each.value.name

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
    local.final_tags,
    {
      Name = each.value.tag_name
    }
  )
}

# IAM Policy for ECR logging
resource "aws_iam_role_policy" "ecr_logging" {
  for_each = { for k, v in local.logging_resources : k => v if k == "iam_role" }

  name = "ecr-logging-${var.name}"
  role = aws_iam_role.ecr_logging[each.key].id

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
          for log_group in aws_cloudwatch_log_group.ecr_logs : "${log_group.arn}:*"
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
  for_each = local.replication_configs

  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = each.value.regions
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
  for_each = local.scanning_configs

  # Use ENHANCED scan type when secret scanning is enabled, otherwise use the configured type
  scan_type = each.value.scan_type

  # Create rules for each repository filter pattern
  dynamic "rule" {
    for_each = each.value.filters
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

# Pull-through cache submodule
module "pull_through_cache" {
  for_each = local.pull_through_cache_modules
  source   = "./modules/pull-through-cache"

  name                     = var.name
  aws_account_id           = data.aws_caller_identity.current.account_id
  pull_through_cache_rules = var.pull_through_cache_rules

  tags = merge(
    local.final_tags,
    {
      Name = "${var.name}-pull-through-cache-role"
    }
  )

  # Ensure cache rules are created after repository is created
  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
}
