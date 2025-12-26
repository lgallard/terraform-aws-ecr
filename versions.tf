terraform {
  # Require at least Terraform 1.3, which introduced important features
  # such as moved blocks improvements and preconditions/validations enhancements
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Require AWS provider 5.81.0+ for ECR account settings support
      # (aws_ecr_account_setting resource introduced in 5.81.0)
      version = ">= 5.81.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }
}
