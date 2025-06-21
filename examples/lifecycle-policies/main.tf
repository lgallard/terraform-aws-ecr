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
  region = var.aws_region
}

# Example 1: Using lifecycle policy template - Development
module "ecr_development" {
  source = "../../"

  name = "example-development"

  # Use development template
  lifecycle_policy_template = "development"

  tags = {
    Environment = "Development"
    Example     = "lifecycle-policies"
  }
}

# Example 2: Using lifecycle policy template - Production
module "ecr_production" {
  source = "../../"

  name = "example-production"

  # Use production template
  lifecycle_policy_template = "production"

  tags = {
    Environment = "Production"
    Example     = "lifecycle-policies"
  }
}

# Example 3: Using helper variables for custom configuration
module "ecr_custom" {
  source = "../../"

  name = "example-custom"

  # Custom lifecycle policy using helper variables
  lifecycle_keep_latest_n_images       = 30
  lifecycle_expire_untagged_after_days = 5
  lifecycle_expire_tagged_after_days   = 60
  lifecycle_tag_prefixes_to_keep       = ["v", "release", "hotfix"]

  tags = {
    Environment = "Staging"
    Example     = "lifecycle-policies"
  }
}

# Example 4: Cost optimization template
module "ecr_cost_optimized" {
  source = "../../"

  name = "example-cost-optimized"

  # Use cost optimization template
  lifecycle_policy_template = "cost_optimization"

  tags = {
    Environment = "Test"
    Example     = "lifecycle-policies"
  }
}

# Example 5: Compliance template
module "ecr_compliance" {
  source = "../../"

  name = "example-compliance"

  # Use compliance template
  lifecycle_policy_template = "compliance"

  tags = {
    Environment = "Compliance"
    Example     = "lifecycle-policies"
  }
}

# Example 6: Manual lifecycle policy (takes precedence)
module "ecr_manual" {
  source = "../../"

  name = "example-manual"

  # Manual lifecycle policy overrides templates and helper variables
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Custom manual rule"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["custom"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # These will be ignored since manual policy is provided
  lifecycle_policy_template      = "development"
  lifecycle_keep_latest_n_images = 100

  tags = {
    Environment = "Manual"
    Example     = "lifecycle-policies"
  }
}