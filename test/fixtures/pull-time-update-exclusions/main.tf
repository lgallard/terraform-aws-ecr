terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.50.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  scanner_role_arn    = "arn:aws:iam::123456789012:role/security/ecr-scanner"
  automation_role_arn = "arn:aws:iam::123456789012:role/ci/ecr-automation"
}

module "ecr" {
  source = "../../../"

  name                 = var.name
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"

  pull_time_update_exclusion_principal_arns = [
    local.scanner_role_arn,
    local.automation_role_arn,
  ]

  tags = {
    Environment = "test"
    Terraform   = "true"
    Test        = "true"
  }
}
