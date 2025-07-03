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
    local.final_tags,
    {
      Name = "${var.name}-kms-key"
    }
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

# ----------------------------------------------------------
# Advanced Tagging Configuration
# ----------------------------------------------------------

locals {
  # ----------------------------------------------------------
  # Tag Normalization Functions
  # ----------------------------------------------------------

  # Default Tag Templates
  default_tag_templates = {
    basic = {
      CreatedBy   = "Terraform"
      ManagedBy   = "Terraform"
      Environment = var.default_tags_environment
      Owner       = var.default_tags_owner
      Project     = var.default_tags_project
    }
    cost_allocation = {
      CreatedBy      = "Terraform"
      ManagedBy      = "Terraform"
      Environment    = var.default_tags_environment
      Owner          = var.default_tags_owner
      Project        = var.default_tags_project
      CostCenter     = var.default_tags_cost_center
      BillingProject = var.default_tags_project
      ResourceType   = "ECR"
      Service        = "ECR"
      Billable       = "true"
    }
    compliance = {
      CreatedBy       = "Terraform"
      ManagedBy       = "Terraform"
      Environment     = var.default_tags_environment
      Owner           = var.default_tags_owner
      Project         = var.default_tags_project
      CostCenter      = var.default_tags_cost_center
      DataClass       = "Internal"
      Compliance      = "Required"
      BackupRequired  = "true"
      MonitoringLevel = "Standard"
      SecurityReview  = "Required"
    }
    sdlc = {
      CreatedBy         = "Terraform"
      ManagedBy         = "Terraform"
      Environment       = var.default_tags_environment
      Owner             = var.default_tags_owner
      Project           = var.default_tags_project
      Application       = var.default_tags_project
      Version           = "latest"
      DeploymentStage   = var.default_tags_environment
      LifecycleStage    = var.default_tags_environment
      MaintenanceWindow = "weekend"
    }
  }

  # Compute default tags based on template or individual settings first
  computed_default_tags = var.enable_default_tags ? (
    var.default_tags_template != null ?
    { for k, v in local.default_tag_templates[var.default_tags_template] : k => v if v != null } :
    { for k, v in {
      CreatedBy   = "Terraform"
      ManagedBy   = "Terraform"
      Environment = var.default_tags_environment
      Owner       = var.default_tags_owner
      Project     = var.default_tags_project
      CostCenter  = var.default_tags_cost_center
    } : k => v if v != null }
  ) : {}

  # Raw tags before normalization
  final_tags_raw = merge(local.computed_default_tags, var.tags)

  # A set of all tag keys that need normalization logic applied,
  # combining input tags and required tags to ensure all are processed.
  all_tag_keys_to_normalize = toset(concat(keys(local.final_tags_raw), var.required_tags))

  # Helper local to split a string into words based on delimiters and case.
  # Handles "kebab-case", "snake_case", "PascalCase", "camelCase", and "spaced strings".
  words = {
    for key in local.all_tag_keys_to_normalize :
    key => [
      for word in split(" ",
        # Add a space before each uppercase letter that is preceded by a lowercase letter or a digit,
        # and before an uppercase letter that is followed by a lowercase letter.
        # This handles camelCase ("myKey" -> "my Key") and acronyms in PascalCase ("APIKey" -> "API Key").
        replace(
          replace(
            # First, normalize all common separators to spaces.
            replace(replace(key, "_", " "), "-", " "),
            "([A-Z]+)([A-Z][a-z])", "$1 $2"
          ),
          "([a-z0-9])([A-Z])", "$1 $2"
        )
      ) : word if word != ""
    ]
  }

  # Simple tag key normalization
  normalized_tag_keys = var.enable_tag_normalization && var.tag_key_case != null ? {
    for key, word_list in local.words :
    key => (
      var.tag_key_case == "PascalCase" ? join("", [for word in word_list : title(lower(word))]) :
      var.tag_key_case == "camelCase" ? join("", [for i, word in word_list : i == 0 ? lower(word) : title(lower(word))]) :
      var.tag_key_case == "snake_case" ? join("_", [for word in word_list : lower(word)]) :
      var.tag_key_case == "kebab-case" ? join("-", [for word in word_list : lower(word)]) :
      key
    )
    } : {
    for key in keys(local.final_tags_raw) : key => key
  }

  # Apply normalization to create final tags
  final_tags_normalized = var.enable_tag_normalization ? {
    for original_key, value in local.final_tags_raw :
    local.normalized_tag_keys[original_key] => var.normalize_tag_values ? trimspace(tostring(value)) : tostring(value)
    } : {
    for key, value in local.final_tags_raw : key => tostring(value)
  }

  # Add repository-specific tags
  final_tags = merge(
    local.final_tags_normalized,
    {
      Name = var.name
    }
  )

  # ----------------------------------------------------------
  # Tag Validation
  # ----------------------------------------------------------

  # Helper map to normalize required tags for validation while preserving original names for error messages.
  # It maps each original required tag to its potentially normalized version.
  normalized_required_tags_map = var.enable_tag_validation && var.enable_tag_normalization && var.tag_key_case != null ? {
    for required_tag in var.required_tags :
    required_tag => local.normalized_tag_keys[required_tag]
    } : {
    # When normalization is disabled, the map maps each required tag to itself.
    for tag in var.required_tags : tag => tag
  }

  # Validation checks
  missing_required_tags = var.enable_tag_validation ? [
    for original_tag, normalized_tag in local.normalized_required_tags_map :
    original_tag if !contains(keys(local.final_tags), normalized_tag)
  ] : []

  # Validation error message
  tag_validation_error = length(local.missing_required_tags) > 0 ? "Missing required tags: ${join(", ", local.missing_required_tags)}" : ""
}

# Tag validation check using a local with validation
locals {
  # This will cause plan to fail if validation fails
  tag_validation_check = var.enable_tag_validation ? (
    length(local.missing_required_tags) == 0 ? true :
    tobool("Tag validation failed: ${local.tag_validation_error}")
  ) : true
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
