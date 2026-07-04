terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "repository_creation_template" {
  source = "../../../"

  name = "fixture-repository-creation-template"

  enable_repository_creation_templates = true
  repository_creation_templates = [
    {
      prefix               = "ROOT"
      description          = "Default template for ECR-created repositories"
      applied_for          = ["CREATE_ON_PUSH", "REPLICATION"]
      image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
      image_tag_mutability_exclusion_filters = [
        {
          filter = "latest"
        }
      ]
      encryption_configuration = {
        encryption_type = "AES256"
      }
    },
    {
      prefix               = "docker-hub"
      description          = "Template for pull-through cache repositories"
      applied_for          = ["PULL_THROUGH_CACHE"]
      image_tag_mutability = "MUTABLE_WITH_EXCLUSION"
      image_tag_mutability_exclusion_filters = [
        {
          filter = "release-*"
        }
      ]
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Expire untagged cached images after 7 days"
            selection = {
              tagStatus   = "untagged"
              countType   = "sinceImagePushed"
              countUnit   = "days"
              countNumber = 7
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    }
  ]
}
