################################################################################
# ECR Repository with Replication Example
################################################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# Default provider
provider "aws" {
  region = var.primary_region
}

# Create ECR repository with built-in replication support
module "ecr_with_replication" {
  source = "../.."

  name                 = var.repository_name
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"

  # Enable replication to multiple regions
  enable_replication  = var.enable_replication
  replication_regions = var.replication_regions

  # Optional: Enable logging for monitoring
  enable_logging = var.enable_logging

  tags = {
    Environment = var.environment
    Example     = "replication"
    ManagedBy   = "Terraform"
  }
}