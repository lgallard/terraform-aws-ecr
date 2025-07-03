# ----------------------------------------------------------
# ECR Repository with Monitoring Example
# ----------------------------------------------------------

# This example demonstrates how to create an ECR repository with
# comprehensive CloudWatch monitoring and SNS alerting.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# ECR Repository with comprehensive monitoring
module "ecr_with_monitoring" {
  source = "../../"

  # Basic configuration
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  # Enable enhanced scanning for security monitoring
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true

  # Enable monitoring configuration
  enable_monitoring                    = true
  monitoring_threshold_storage         = var.storage_threshold_gb
  monitoring_threshold_api_calls       = var.api_calls_threshold
  monitoring_threshold_security_findings = var.security_findings_threshold

  # SNS topic configuration
  create_sns_topic      = true
  sns_topic_name        = "${var.repository_name}-ecr-alerts"
  sns_topic_subscribers = var.notification_emails

  # Enable logging for comprehensive monitoring
  enable_logging     = true
  log_retention_days = 30

  # Lifecycle policy for cost optimization
  lifecycle_policy_template = "production"

  # Tags
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ECR Repository with Monitoring"
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Example: Additional custom CloudWatch dashboard for ECR metrics
resource "aws_cloudwatch_dashboard" "ecr_dashboard" {
  dashboard_name = "${var.repository_name}-ecr-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECR", "RepositorySizeInBytes", "RepositoryName", module.ecr_with_monitoring.repository_name],
            [".", "ImagePushCount", ".", "."],
            [".", "ImagePullCount", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECR Repository Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECR", "ApiCallCount", "RepositoryName", module.ecr_with_monitoring.repository_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "ECR API Calls"
        }
      }
    ]
  })
}

# Example: Custom CloudWatch alarm for repository inactivity
resource "aws_cloudwatch_metric_alarm" "repository_inactivity" {
  alarm_name          = "${var.repository_name}-ecr-inactivity"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ImagePushCount"
  namespace           = "AWS/ECR"
  period              = "86400"  # 24 hours
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This metric monitors ECR repository inactivity"
  alarm_actions       = [module.ecr_with_monitoring.sns_topic_arn]

  dimensions = {
    RepositoryName = module.ecr_with_monitoring.repository_name
  }

  tags = {
    Name        = "${var.repository_name}-ecr-inactivity-alarm"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}