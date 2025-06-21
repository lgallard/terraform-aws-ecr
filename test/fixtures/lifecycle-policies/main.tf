terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "lifecycle_template_test" {
  source = "../../../"

  name = "lifecycle-template-test"

  # Test development template
  lifecycle_policy_template = "development"

  tags = {
    Environment = "Test"
    Purpose     = "LifecyclePolicyTemplate"
  }
}

module "lifecycle_helper_vars_test" {
  source = "../../../"

  name = "lifecycle-helper-vars-test"

  # Test helper variables
  lifecycle_keep_latest_n_images       = 25
  lifecycle_expire_untagged_after_days = 5
  lifecycle_expire_tagged_after_days   = 45
  lifecycle_tag_prefixes_to_keep       = ["test", "qa"]

  tags = {
    Environment = "Test"
    Purpose     = "LifecycleHelperVars"
  }
}

module "lifecycle_manual_override_test" {
  source = "../../../"

  name = "lifecycle-manual-override-test"

  # Manual policy should override template and helper vars
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manual test rule"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["manual"]
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # These should be ignored
  lifecycle_policy_template      = "production"
  lifecycle_keep_latest_n_images = 100

  tags = {
    Environment = "Test"
    Purpose     = "LifecycleManualOverride"
  }
}