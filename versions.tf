terraform {
  # Require at least Terraform 1.3, which introduced important features
  # such as moved blocks improvements and preconditions/validations enhancements
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Require AWS provider 6.50.0+ for ECR image tag mutability
      # exclusion filters on repositories and repository creation templates.
      # 6.50.0 also retains the AWS provider v6 aws_region.region schema.
      version = ">= 6.50.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }
}
