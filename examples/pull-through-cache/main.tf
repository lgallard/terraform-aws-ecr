# ----------------------------------------------------------
# Pull-Through Cache Example Configuration
# ----------------------------------------------------------

# ----------------------------------------------------------
# ECR Repository with Pull-Through Cache
# ----------------------------------------------------------

module "ecr_with_pull_through_cache" {
  source = "../../"

  # Basic repository configuration
  name = var.repository_name

  # Enable pull-through cache with multiple upstream registries
  enable_pull_through_cache = true
  pull_through_cache_rules = [
    {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
      credential_arn        = null # Public registry, no credentials needed
    },
    {
      ecr_repository_prefix = "quay"
      upstream_registry_url = "quay.io"
      credential_arn        = var.quay_credentials_arn # Optional: if you have private access
    },
    {
      ecr_repository_prefix = "ghcr"
      upstream_registry_url = "ghcr.io"
      credential_arn        = var.github_credentials_arn # Optional: for private repositories
    },
    {
      ecr_repository_prefix = "public-ecr"
      upstream_registry_url = "public.ecr.aws"
      credential_arn        = null # Public registry
    }
  ]

  # Repository configuration
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete
  encryption_type      = "AES256"

  # Image scanning
  scan_on_push             = true
  enable_registry_scanning = true
  registry_scan_type       = "ENHANCED"

  # Lifecycle policy to manage cached images
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images for cached repositories"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name        = var.repository_name
    Environment = var.environment
    Purpose     = "pull-through-cache"
    Example     = "terraform-aws-ecr"
  }
}
