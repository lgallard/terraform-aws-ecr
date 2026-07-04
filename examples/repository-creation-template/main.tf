# ----------------------------------------------------------
# Repository Creation Template Example Configuration
# ----------------------------------------------------------

module "ecr_with_repository_creation_templates" {
  source = "../../"

  name = var.repository_name

  # Configure pull-through cache rules. Repository creation templates below
  # control settings for repositories ECR creates from these prefixes.
  enable_pull_through_cache = true
  pull_through_cache_rules = [
    {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
    },
    {
      ecr_repository_prefix = "public-ecr"
      upstream_registry_url = "public.ecr.aws"
    }
  ]

  enable_repository_creation_templates = true
  repository_creation_templates = [
    {
      prefix      = "docker-hub"
      description = "Template for repositories created by the Docker Hub pull-through cache rule"
      applied_for = ["PULL_THROUGH_CACHE"]

      # Keep cached tags mutable by default, except for release tags that
      # should not be overwritten once ECR creates the repository.
      image_tag_mutability = "MUTABLE_WITH_EXCLUSION"
      image_tag_mutability_exclusion_filters = [
        {
          filter = "release-*"
        }
      ]

      encryption_configuration = {
        encryption_type = "AES256"
      }

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
    },
    {
      prefix               = "ROOT"
      description          = "Default template for repositories ECR creates by replication or create-on-push"
      applied_for          = ["CREATE_ON_PUSH", "REPLICATION"]
      image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
      image_tag_mutability_exclusion_filters = [
        {
          filter = "latest"
        }
      ]
    }
  ]

  tags = {
    Name        = var.repository_name
    Environment = var.environment
    Example     = "repository-creation-template"
  }
}
