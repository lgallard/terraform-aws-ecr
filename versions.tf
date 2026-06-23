terraform {
  # Require at least Terraform 1.3, which introduced important features
  # such as moved blocks improvements and preconditions/validations enhancements
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Require AWS provider 6.0.0+ for the `region` attribute on the
      # aws_region data source (which replaced the now-deprecated `id`/`name`).
      # 6.0.0 also retains ECR account settings support added in 5.81.0.
      version = ">= 6.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0.0"
    }
  }
}
