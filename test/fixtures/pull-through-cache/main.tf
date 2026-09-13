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
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

module "pull_through_cache" {
  source = "../../../"

  name                      = "fixture-pull-through-cache"
  enable_pull_through_cache = true

  pull_through_cache_rules = [
    {
      ecr_repository_prefix = "ROOT"
      upstream_registry_url = "public.ecr.aws"
    },
    {
      ecr_repository_prefix      = "team-cache"
      upstream_registry_url      = "123456789012.dkr.ecr.us-east-1.amazonaws.com"
      upstream_repository_prefix = "team-upstream"
      custom_role_arn            = "arn:aws:iam::123456789012:role/ecr-pull-through-cache"
    }
  ]
}

output "pull_through_cache_rules" {
  description = "Pull-through cache rules created by the fixture"
  value       = module.pull_through_cache.pull_through_cache_rules
}
