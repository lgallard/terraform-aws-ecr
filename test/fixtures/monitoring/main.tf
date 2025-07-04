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
  region = "us-east-1"
}

module "ecr_monitoring" {
  source = "../../../"

  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  # Enable monitoring
  enable_monitoring                      = true
  monitoring_threshold_storage           = 5
  monitoring_threshold_api_calls         = 500
  monitoring_threshold_security_findings = 3

  # Enable enhanced scanning for security monitoring
  enable_registry_scanning = true
  registry_scan_type       = "ENHANCED"

  # Create SNS topic for testing
  create_sns_topic      = true
  sns_topic_name        = "${var.name}-test-alerts"
  sns_topic_subscribers = ["test@example.com"]

  tags = {
    Environment = "test"
    Purpose     = "terratest"
  }
}
