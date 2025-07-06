# ----------------------------------------------------------
# Enhanced KMS Configuration Example
# ----------------------------------------------------------
#
# This example demonstrates the enhanced KMS key configuration
# options available with the refactored KMS submodule.

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# ----------------------------------------------------------
# Basic Enhanced KMS Example
# ----------------------------------------------------------

module "ecr_basic_enhanced_kms" {
  source = "../../"

  name = "basic-enhanced-kms-example"

  # KMS encryption with enhanced options
  encryption_type = "KMS"

  # Enhanced KMS configuration
  kms_deletion_window_in_days = 14
  kms_enable_key_rotation     = true
  kms_key_rotation_period     = 90
  kms_multi_region            = false

  # Basic tagging
  tags = {
    Environment = "development"
    Project     = "enhanced-kms-example"
    Owner       = "platform-team"
  }

  kms_tags = {
    KeyType  = "ECR-Basic"
    Rotation = "90-days"
  }
}

# ----------------------------------------------------------
# Advanced KMS Configuration Example
# ----------------------------------------------------------

module "ecr_advanced_enhanced_kms" {
  source = "../../"

  name = "advanced-enhanced-kms-example"

  # KMS encryption with advanced configuration
  encryption_type = "KMS"

  # Advanced KMS configuration
  kms_deletion_window_in_days = 30
  kms_enable_key_rotation     = true
  kms_key_rotation_period     = 180
  kms_multi_region            = true

  # Access control configuration
  kms_key_administrators = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KMSAdminRole"
  ]

  kms_key_users = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ECRAccessRole",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CI-CD-Role"
  ]

  kms_additional_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  # Custom alias
  kms_alias_name = "production/ecr/advanced-example"

  # Enhanced tagging
  tags = {
    Environment = "production"
    Project     = "advanced-kms-example"
    Owner       = "security-team"
    CostCenter  = "engineering"
    Compliance  = "SOC2"
  }

  kms_tags = {
    KeyType       = "ECR-Advanced"
    Rotation      = "180-days"
    MultiRegion   = "true"
    SecurityLevel = "high"
  }
}

# ----------------------------------------------------------
# Custom Policy Example
# ----------------------------------------------------------

module "ecr_custom_policy_kms" {
  source = "../../"

  name = "custom-policy-kms-example"

  # KMS encryption with custom policy statements
  encryption_type = "KMS"

  # Basic KMS configuration
  kms_enable_key_rotation = true
  kms_multi_region        = false

  # Custom policy statements
  kms_custom_policy_statements = [
    {
      sid    = "AllowCloudTrailEncryption"
      effect = "Allow"
      principals = {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowCrossAccountAccess"
      effect = "Allow"
      principals = {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${var.trusted_account_id}:root"
        ]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "kms:ViaService"
          values   = ["ecr.${var.aws_region}.amazonaws.com"]
        }
      ]
    }
  ]

  # Tagging
  tags = {
    Environment = "staging"
    Project     = "custom-policy-example"
    Owner       = "devops-team"
  }

  kms_tags = {
    KeyType      = "ECR-Custom"
    PolicyType   = "custom-statements"
    CrossAccount = "enabled"
  }
}

# ----------------------------------------------------------
# Complete Custom Policy Example
# ----------------------------------------------------------

module "ecr_complete_custom_policy" {
  source = "../../"

  name = "complete-custom-policy-example"

  # KMS encryption with completely custom policy
  encryption_type = "KMS"

  # Complete custom policy (overrides all other policy settings)
  kms_custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowECRService"
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
        Sid    = "RestrictedAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RestrictedECRRole"
        }
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ecr.${var.aws_region}.amazonaws.com"
          }
          DateGreaterThan = {
            "aws:CurrentTime" = "2024-01-01T00:00:00Z"
          }
        }
      }
    ]
  })

  # Custom alias
  kms_alias_name = "custom/complete-policy"

  # Tagging
  tags = {
    Environment = "test"
    Project     = "complete-custom-policy-example"
    Owner       = "security-team"
  }

  kms_tags = {
    KeyType    = "ECR-CompleteCustom"
    PolicyType = "fully-custom"
    Access     = "restricted"
  }
}
