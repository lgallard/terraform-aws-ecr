# ----------------------------------------------------------
# Example: ECR with Pull Request Rules
# ----------------------------------------------------------

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Example ECR repository with comprehensive pull request rules
module "ecr_with_pr_rules" {
  source = "../../"

  name = var.repository_name

  # Basic configuration
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  prevent_destroy      = false

  # Enable pull request rules
  enable_pull_request_rules = true

  # Configure multiple pull request rules
  pull_request_rules = [
    {
      name    = "security-approval-required"
      type    = "approval"
      enabled = true
      conditions = {
        tag_patterns            = ["prod-*", "release-*"]
        severity_threshold      = "HIGH"
        require_scan_completion = true
        allowed_principals = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ECRApprovalRole"
        ]
      }
      actions = {
        require_approval_count = 2
        notification_topic_arn = var.notification_topic_arn
        block_on_failure       = true
        approval_timeout_hours = 24
      }
    },
    {
      name    = "security-scan-validation"
      type    = "security_scan"
      enabled = true
      conditions = {
        tag_patterns            = ["*"]
        severity_threshold      = "MEDIUM"
        require_scan_completion = true
      }
      actions = {
        require_approval_count = 1
        notification_topic_arn = var.notification_topic_arn
        block_on_failure       = true
        approval_timeout_hours = 12
      }
    },
    {
      name    = "ci-integration-check"
      type    = "ci_integration"
      enabled = var.enable_ci_integration
      conditions = {
        tag_patterns       = ["feature-*", "dev-*"]
        severity_threshold = "LOW"
      }
      actions = {
        webhook_url            = var.ci_webhook_url
        block_on_failure       = false
        approval_timeout_hours = 6
      }
    }
  ]

  # Enhanced security configuration
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true

  # Lifecycle policy for compliance
  lifecycle_policy_template = "compliance"

  # Monitoring and logging
  enable_monitoring      = true
  enable_logging        = true
  log_retention_days    = 90

  tags = {
    Environment         = var.environment
    Project            = "ECR-PR-Rules-Example"
    SecurityLevel      = "High"
    ComplianceRequired = "true"
    ManagedBy          = "Terraform"
  }
}

# Example SNS topic for notifications (if not provided)
resource "aws_sns_topic" "ecr_notifications" {
  count = var.notification_topic_arn == null ? 1 : 0
  name  = "${var.repository_name}-ecr-notifications"

  tags = {
    Environment = var.environment
    Project     = "ECR-PR-Rules-Example"
    ManagedBy   = "Terraform"
  }
}

# SNS topic subscription for notifications
resource "aws_sns_topic_subscription" "email_notifications" {
  count = var.notification_topic_arn == null && length(var.notification_emails) > 0 ? length(var.notification_emails) : 0

  topic_arn = aws_sns_topic.ecr_notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails[count.index]
}

# IAM role for ECR approval process
resource "aws_iam_role" "ecr_approval_role" {
  name = "ECRApprovalRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "ecr-approval-process"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "ECR-PR-Rules-Example"
    ManagedBy   = "Terraform"
  }
}

# IAM policy for ECR approval role
resource "aws_iam_role_policy" "ecr_approval_policy" {
  name = "ECRApprovalPolicy"
  role = aws_iam_role.ecr_approval_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:TagResource"
        ]
        Resource = module.ecr_with_pr_rules.repository_arn
        Condition = {
          StringEquals = {
            "ecr:ResourceTag/ApprovalStatus" = "approved"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:DescribeImageScanFindings",
          "ecr:GetRepositoryPolicy"
        ]
        Resource = module.ecr_with_pr_rules.repository_arn
      }
    ]
  })
}