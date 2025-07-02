module "ecr" {
  source = "../../.."

  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  encryption_type      = "KMS"
  scan_on_push         = true

  # Enhanced scanning configuration
  enable_registry_scanning = var.enable_registry_scanning
  registry_scan_type       = var.registry_scan_type
  enable_secret_scanning   = var.enable_secret_scanning
  scan_repository_filters  = var.scan_repository_filters

  # Registry scan filters
  registry_scan_filters = var.registry_scan_filters

  # Pull-through cache configuration
  enable_pull_through_cache = var.enable_pull_through_cache
  pull_through_cache_rules  = var.pull_through_cache_rules

  # Enable logging for testing
  enable_logging     = true
  log_retention_days = 7

  tags = var.tags
}
