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
  region = "us-west-2"
}

variable "template_name" {
  description = "The template name to test"
  type        = string
}

module "ecr_template_test" {
  source = "../../../"

  name = "${var.template_name}-test-${random_string.suffix.result}"

  # Use template for lifecycle policy
  lifecycle_policy_template = var.template_name

  force_delete = true

  tags = {
    Test        = "true"
    Environment = "testing"
    Template    = var.template_name
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}