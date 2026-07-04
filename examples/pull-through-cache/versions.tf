# ----------------------------------------------------------
# Terraform and Provider Version Requirements
# ----------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.50.0"
    }
  }
}
