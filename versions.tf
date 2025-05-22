terraform {
  # Require at least Terraform 1.3, which introduced important features
  # such as moved blocks improvements and preconditions/validations enhancements
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Require AWS provider 5.x to ensure compatibility with the latest
      # ECR features and future improvements.
      version = ">= 5.0.0"
    }
  }
}
