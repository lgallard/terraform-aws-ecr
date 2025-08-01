# ----------------------------------------------------------
# KMS Module Integration
# ----------------------------------------------------------

# KMS key submodule
module "kms" {
  count  = local.should_create_kms_key ? 1 : 0
  source = "./modules/kms"

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
  count             = var.enable_logging ? 1 : 0
  name              = "/aws/ecr/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.final_tags,
    {
      Name = "${var.name}-logs"
    }
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
    local.final_tags,
    {
      Name = "${var.name}-logging-role"
    }
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
    local.final_tags,
    {
      Name = "${var.name}-pull-through-cache-role"
    }
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
