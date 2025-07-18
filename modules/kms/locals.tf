# ----------------------------------------------------------
# Local Values for KMS Module
# ----------------------------------------------------------

locals {
  # Final tags combining all sources
  final_tags = merge(
    var.tags,
    var.kms_tags,
    {
      Name = "${var.name}-kms-key"
    }
  )

  # KMS alias name
  alias_name = var.alias_name != null ? var.alias_name : "ecr/${var.name}"

  # Description with fallback
  key_description = var.description != null ? var.description : "KMS key for ECR repository ${var.name} encryption"

  # Default policy statements
  default_policy_statements = var.enable_default_policy ? [
    # Root account permissions
    {
      sid    = "EnableIAMRootUserPermissions"
      effect = "Allow"
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
      }
      actions = [
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
      resources = ["*"]
    }
  ] : []

  # ECR service permissions
  ecr_service_statements = var.allow_ecr_service ? [
    {
      sid    = "AllowECRServiceToUseTheKey"
      effect = "Allow"
      principals = {
        type        = "Service"
        identifiers = ["ecr.amazonaws.com"]
      }
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:Encrypt"
      ]
      resources = ["*"]
    }
  ] : []

  # Key administrators statements
  key_admin_statements = length(var.key_administrators) > 0 ? [
    {
      sid    = "AllowKeyAdministrators"
      effect = "Allow"
      principals = {
        type        = "AWS"
        identifiers = var.key_administrators
      }
      actions = [
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
        "kms:CancelKeyDeletion",
        "kms:TagResource",
        "kms:UntagResource"
      ]
      resources = ["*"]
    }
  ] : []

  # Key users statements
  key_users_statements = length(var.key_users) > 0 ? [
    {
      sid    = "AllowKeyUsers"
      effect = "Allow"
      principals = {
        type        = "AWS"
        identifiers = var.key_users
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  ] : []

  # Additional principals statements
  additional_principals_statements = length(var.additional_principals) > 0 ? [
    {
      sid    = "AllowAdditionalPrincipals"
      effect = "Allow"
      principals = {
        type        = "AWS"
        identifiers = var.additional_principals
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  ] : []

  # Combine all policy statements
  all_policy_statements = concat(
    local.default_policy_statements,
    local.ecr_service_statements,
    local.key_admin_statements,
    local.key_users_statements,
    local.additional_principals_statements,
    var.custom_policy_statements
  )

  # Generate policy document with proper condition handling
  generated_policy = {
    Version = "2012-10-17"
    Statement = [
      for i, stmt in local.all_policy_statements : {
        Sid    = try(stmt.sid, null)
        Effect = stmt.effect
        Principal = try(stmt.principals, null) != null ? {
          (stmt.principals.type) = stmt.principals.identifiers
        } : null
        Action   = stmt.actions
        Resource = try(stmt.resources, ["*"])
        Condition = length(try(stmt.conditions, [])) > 0 ? {
          for test_type in distinct([for condition in stmt.conditions : condition.test]) :
          test_type => merge([
            for condition in stmt.conditions :
            condition.test == test_type ? {
              (condition.variable) = condition.values
            } : {}
          ]...)
        } : null
      }
    ]
  }

  # Final policy (custom overrides generated)
  final_policy = var.custom_policy != null ? var.custom_policy : jsonencode(local.generated_policy)
}
