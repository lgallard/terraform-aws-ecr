resource "aws_ecr_repository" "repo" {
  name                 = var.name
  force_delete         = var.force_delete
  image_tag_mutability = var.image_tag_mutability

  dynamic "encryption_configuration" {
    for_each = local.encryption_configuration
    content {
      encryption_type = encryption_configuration.value["encryption_type"]
      kms_key         = encryption_configuration.value["kms_key"]
    }
  }

  dynamic "image_scanning_configuration" {
    for_each = local.image_scanning_configuration
    content {
      scan_on_push = image_scanning_configuration.value["scan_on_push"]
    }
  }

  dynamic "timeouts" {
    for_each = local.timeouts
    content {
      delete = timeouts.value["delete"]
    }
  }

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

# KMS key
resource "aws_kms_key" "kms_key" {
  count       = local.should_create_kms_key ? 1 : 0
  description = "${var.name} KMS key"
}

resource "aws_kms_alias" "kms_key_alias" {
  count         = local.should_create_kms_key ? 1 : 0
  name          = "alias/${var.name}Key"
  target_key_id = aws_kms_key.kms_key[0].key_id
}

locals {
  should_create_kms_key = var.encryption_type == "KMS" && var.kms_key == null

  # If encryption type is KMS, use assigned KMS key otherwise build a new key
  encryption_configuration = local.should_create_kms_key ? [{
    encryption_type = "KMS"
    kms_key         = aws_kms_key.kms_key[0].arn
    }] : (var.encryption_type == "KMS" ? [{
      encryption_type = "KMS"
      kms_key         = var.kms_key
  }] : [])

  # Image scanning configuration
  # If no image_scanning_configuration block is provided, build one using the default values
  image_scanning_configuration = [{
    scan_on_push = var.image_scanning_configuration != null ? var.image_scanning_configuration.scan_on_push : var.default_scan_on_push
  }]

  # Timeouts
  # If no timeouts block is provided, build one using the default values
  timeouts = var.timeouts != null ? [var.timeouts] : (var.timeouts_delete != null ? [{
    delete = var.timeouts_delete
  }] : [])
}
