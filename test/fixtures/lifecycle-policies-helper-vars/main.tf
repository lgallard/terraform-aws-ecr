terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "lifecycle_expire_untagged_after_days" {
  description = "Number of days after which untagged images expire"
  type        = number
  default     = 14
}

variable "lifecycle_keep_latest_n_images" {
  description = "Number of latest images to keep"
  type        = number
  default     = 25
}

variable "lifecycle_expire_tagged_after_days" {
  description = "Number of days after which tagged images expire"
  type        = number
  default     = 60
}

variable "lifecycle_tag_prefixes_to_keep" {
  description = "Tag prefixes to apply keep rule to"
  type        = list(string)
  default     = ["v", "release"]
}

module "ecr_helper_vars_test" {
  source = "../../../"

  name = "helper-vars-test-${random_string.suffix.result}"

  # Use helper variables for lifecycle policy
  lifecycle_expire_untagged_after_days = var.lifecycle_expire_untagged_after_days
  lifecycle_keep_latest_n_images       = var.lifecycle_keep_latest_n_images
  lifecycle_expire_tagged_after_days   = var.lifecycle_expire_tagged_after_days
  lifecycle_tag_prefixes_to_keep       = var.lifecycle_tag_prefixes_to_keep

  force_delete = true

  tags = {
    Test        = "true"
    Environment = "testing"
    Purpose     = "helper-variables-test"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
