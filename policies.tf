# ----------------------------------------------------------
# Repository Policy Management
# ----------------------------------------------------------

# ----------------------------------------------------------
# Pull Request Rules Configuration
# ----------------------------------------------------------

# Pull request rules configuration locals
locals {
  # Only create resources if pull request rules are enabled
  pull_request_rules_enabled = var.enable_pull_request_rules && length(var.pull_request_rules) > 0

  # Filter enabled rules
  enabled_pull_request_rules = [
    for rule in var.pull_request_rules : rule if rule.enabled
  ]

  # Helper function to build IAM policy conditions properly
  # This avoids the merge() issue by building conditions as a list and then converting to map
  build_policy_conditions = {
    for rule in local.enabled_pull_request_rules : rule.name => {
      # Tag pattern conditions
      tag_conditions = try(length(rule.conditions.tag_patterns), 0) > 0 ? {
        StringLike = {
          "ecr:ImageTag" = rule.conditions.tag_patterns
        }
      } : {}

      # Approval status condition for approval rules
      approval_conditions = rule.type == "approval" ? {
        StringEquals = {
          "ecr:ResourceTag/ApprovalStatus" = "approved"
        }
      } : {}

      # Security scan completion condition
      scan_completion_conditions = try(rule.conditions.require_scan_completion, false) ? {
        StringEquals = {
          "ecr:ResourceTag/ScanStatus" = "completed"
        }
      } : {}

      # Severity threshold condition
      severity_conditions = try(rule.conditions.severity_threshold, null) != null ? {
        StringLike = {
          "ecr:ResourceTag/MaxSeverity" = (
            rule.conditions.severity_threshold == "LOW" ? ["LOW", "MEDIUM", "HIGH", "CRITICAL"] :
            rule.conditions.severity_threshold == "MEDIUM" ? ["MEDIUM", "HIGH", "CRITICAL"] :
            rule.conditions.severity_threshold == "HIGH" ? ["HIGH", "CRITICAL"] :
            ["CRITICAL"]
          )
        }
      } : {}

      # CI validation status
      ci_conditions = rule.type == "ci_integration" ? {
        StringEquals = {
          "ecr:ResourceTag/CIStatus" = "passed"
        }
      } : {}
    }
  }

  # Merge multiple pull request rule policies into a single policy
  merged_pull_request_policy = local.pull_request_rules_enabled && length(local.enabled_pull_request_rules) > 0 ? jsonencode({
    Version = "2012-10-17"
    Statement = flatten([
      for rule in local.enabled_pull_request_rules : concat(
        # Allow read operations for all authenticated users
        [{
          Sid    = "AllowRead${replace(title(rule.name), "-", "")}"
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
            "ecr:DescribeImageScanFindings",
            "ecr:GetRepositoryPolicy",
            "ecr:ListImages"
          ]
        }],
        # Conditional write operations based on rule type and configuration
        rule.type == "approval" && try(rule.actions.block_on_failure, true) ? [
          {
            Sid    = "AllowPushWithApproval${replace(title(rule.name), "-", "")}"
            Effect = "Allow"
            Principal = {
              AWS = try(length(rule.conditions.allowed_principals), 0) > 0 ? rule.conditions.allowed_principals : [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
              ]
            }
            Action = [
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
              "ecr:TagResource"
            ]
            Condition = merge(
              local.build_policy_conditions[rule.name].tag_conditions,
              local.build_policy_conditions[rule.name].approval_conditions,
              local.build_policy_conditions[rule.name].scan_completion_conditions
            )
          }
        ] : [],
        # Security scan enforcement for security_scan type rules
        rule.type == "security_scan" && try(rule.actions.block_on_failure, true) ? [
          {
            Sid    = "AllowPushWithSecurityScan${replace(title(rule.name), "-", "")}"
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action = [
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload"
            ]
            Condition = merge(
              local.build_policy_conditions[rule.name].tag_conditions,
              local.build_policy_conditions[rule.name].scan_completion_conditions,
              local.build_policy_conditions[rule.name].severity_conditions
            )
          }
        ] : [],
        # CI integration rules - typically non-blocking but can be configured
        rule.type == "ci_integration" && try(rule.actions.block_on_failure, false) ? [
          {
            Sid    = "AllowPushWithCIValidation${replace(title(rule.name), "-", "")}"
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action = [
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload"
            ]
            Condition = merge(
              local.build_policy_conditions[rule.name].tag_conditions,
              local.build_policy_conditions[rule.name].ci_conditions
            )
          }
        ] : [],
        # Default allow for non-blocking rules or when no specific conditions apply
        !try(rule.actions.block_on_failure, true) ? [
          {
            Sid    = "AllowPushNonBlocking${replace(title(rule.name), "-", "")}"
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action = [
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload"
            ]
          }
        ] : []
      )
    ])
  }) : null

  # Final repository policy with proper precedence:
  # 1. Manual policy (var.policy) takes highest precedence
  # 2. Merged pull request rules policy takes second precedence
  # 3. No policy (null) if neither is provided
  final_repository_policy = (
    var.policy != null ? var.policy :
    local.merged_pull_request_policy != null ? local.merged_pull_request_policy :
    null
  )
}

# ----------------------------------------------------------
# Repository Policies
# ----------------------------------------------------------

# Repository policy - controls access to the repository
resource "aws_ecr_repository_policy" "policy" {
  count      = local.final_repository_policy != null ? 1 : 0
  repository = local.repository_name
  policy     = local.final_repository_policy

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
