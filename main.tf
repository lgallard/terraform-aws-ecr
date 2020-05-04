resource "aws_ecr_repository" "repo" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  # Image scanning configuration
  dynamic "image_scanning_configuration" {
    for_each = local.image_scanning_configuration
    content {
      scan_on_push = lookup(image_scanning_configuration.value, "scan_on_push")
    }
  }

  # Timeouts
  dynamic "timeouts" {
    for_each = local.timeouts
    content {
      delete = lookup(timeouts.value, "delete")
    }
  }

  # Tags
  tags = var.tags

}

# Policy
resource "aws_ecr_repository_policy" "policy" {
  count      = var.policy == null ? 0 : 1
  repository = aws_ecr_repository.repo.name
  policy     = var.policy
}

# Lifecycle policy
resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  count      = var.lifecycle_policy == null ? 0 : 1
  repository = aws_ecr_repository.repo.name
  policy     = var.lifecycle_policy
}

locals {

  # Image scanning configuration
  # If no image_scanning_configuration block is provided, build one using the default values
  image_scanning_configuration = [
    {
      scan_on_push = lookup(var.image_scanning_configuration, "scan_on_push", null) == null ? var.scan_on_push : lookup(var.image_scanning_configuration, "scan_on_push")
    }
  ]

  # Timeouts
  # If no timeouts block is provided, build one using the default values
  timeouts = var.timeouts_delete == null && length(var.timeouts) == 0 ? [] : [
    {
      delete = lookup(var.timeouts, "delete", null) == null ? var.timeouts_delete : lookup(var.timeouts, "delete")
    }
  ]
}
