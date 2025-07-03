# Advanced Tagging Strategies Example
# This example demonstrates the new advanced tagging features including:
# - Default tag templates for different organizational needs
# - Tag validation and compliance
# - Tag normalization for consistency
# - Cost allocation and compliance tagging

# Basic example with default tagging template
module "ecr_cost_allocation" {
  source = "../.."

  name                 = "cost-allocation-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  encryption_type      = "KMS"

  # Advanced tagging configuration
  enable_default_tags        = true
  default_tags_template      = "cost_allocation"
  default_tags_environment   = "production"
  default_tags_owner         = "platform-team"
  default_tags_project       = "user-service"
  default_tags_cost_center   = "engineering-cc-001"

  # Enable tag validation for compliance
  enable_tag_validation = true
  required_tags        = ["Environment", "Owner", "Project", "CostCenter"]

  # Tag normalization for consistency
  enable_tag_normalization = true
  tag_key_case            = "PascalCase"
  normalize_tag_values    = true

  # Lifecycle policy optimized for cost
  lifecycle_policy_template = "cost_optimization"

  # Additional custom tags
  tags = {
    "billing-project" = "user-service-prod"
    "data-class"     = "internal"
    "backup-policy"  = "daily"
  }
}

# Compliance-focused example
module "ecr_compliance" {
  source = "../.."

  name                 = "compliance-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false
  encryption_type      = "KMS"

  # Enhanced security scanning
  enable_registry_scanning = true
  enable_secret_scanning   = true

  # Compliance tagging configuration
  enable_default_tags        = true
  default_tags_template      = "compliance"
  default_tags_environment   = "production"
  default_tags_owner         = "security-team"
  default_tags_project       = "payment-service"
  default_tags_cost_center   = "security-cc-002"

  # Strict tag validation for compliance
  enable_tag_validation = true
  required_tags = [
    "Environment", "Owner", "Project", "CostCenter",
    "DataClass", "Compliance", "SecurityReview"
  ]

  # Normalized tagging
  enable_tag_normalization = true
  tag_key_case            = "PascalCase"

  # Compliance lifecycle policy
  lifecycle_policy_template = "compliance"

  # Compliance-specific tags
  tags = {
    "pci-compliant"         = "true"
    "audit-required"        = "true"
    "retention-period"      = "7-years"
    "encryption-required"   = "true"
  }
}

# SDLC-focused example  
module "ecr_sdlc" {
  source = "../.."

  name                 = "sdlc-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  encryption_type      = "AES256"

  # SDLC tagging configuration
  enable_default_tags        = true
  default_tags_template      = "sdlc"
  default_tags_environment   = "development"
  default_tags_owner         = "dev-team"
  default_tags_project       = "mobile-app"

  # Development-friendly validation
  enable_tag_validation = true
  required_tags        = ["Environment", "Owner", "Project"]

  # Consistent naming
  enable_tag_normalization = true
  tag_key_case            = "camelCase"

  # Development lifecycle policy
  lifecycle_policy_template = "development"

  # SDLC-specific tags
  tags = {
    "ci-cd-pipeline"     = "github-actions"
    "deployment-method"  = "kubernetes"
    "test-coverage"      = "80-percent"
  }
}

# Custom default tags example (without template)
module "ecr_custom_defaults" {
  source = "../.."

  name                 = "custom-defaults-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  # Custom default tags configuration
  enable_default_tags        = true
  default_tags_template      = null  # Use custom configuration
  default_tags_environment   = "staging"
  default_tags_owner         = "full-stack-team"
  default_tags_project       = "analytics-service"
  default_tags_cost_center   = "data-cc-003"

  # Basic validation
  enable_tag_validation = true
  required_tags        = ["Environment", "Owner"]

  # Snake case for internal tooling compatibility
  enable_tag_normalization = true
  tag_key_case            = "snake_case"

  # Custom lifecycle configuration
  lifecycle_keep_latest_n_images      = 25
  lifecycle_expire_untagged_after_days = 5
  lifecycle_expire_tagged_after_days   = 60

  # Additional custom tags
  tags = {
    "team-slack"        = "analytics-team"
    "oncall-rotation"   = "analytics-oncall"
    "monitoring-level"  = "enhanced"
  }
}

# Legacy compatibility example (advanced features disabled)
module "ecr_legacy_compatible" {
  source = "../.."

  name                 = "legacy-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  # Disable advanced tagging for legacy compatibility
  enable_default_tags       = false
  enable_tag_validation     = false
  enable_tag_normalization  = false

  # Traditional manual tagging
  tags = {
    Environment = "production"
    Owner       = "legacy-team"
    ManagedBy   = "Terraform"
    Application = "legacy-service"
  }
}