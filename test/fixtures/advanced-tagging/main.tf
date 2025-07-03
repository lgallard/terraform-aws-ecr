module "ecr_advanced_tagging" {
  source = "../../.."

  name                 = "test-advanced-tagging-${random_pet.suffix.id}"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  # Test cost allocation template
  enable_default_tags      = true
  default_tags_template    = "cost_allocation"
  default_tags_environment = "test"
  default_tags_owner       = "terraform-test"
  default_tags_project     = "ecr-module-test"
  default_tags_cost_center = "test-cc-001"

  # Test tag validation
  enable_tag_validation = true
  required_tags         = ["Environment", "Owner", "Project"]

  # Test tag normalization
  enable_tag_normalization = true
  tag_key_case             = "PascalCase"
  normalize_tag_values     = true

  # Test custom tags with normalization
  tags = {
    "test-case"    = "advanced-tagging"
    "team_name"    = "  platform-team  "
    "billing-code" = "test-billing-001"
  }
}

# Test basic template
module "ecr_basic_tagging" {
  source = "../../.."

  name         = "test-basic-tagging-${random_pet.suffix.id}"
  force_delete = true

  # Test basic template
  enable_default_tags      = true
  default_tags_template    = "basic"
  default_tags_environment = "test"
  default_tags_owner       = "terraform-test"
  default_tags_project     = "ecr-module-test"

  # Test different normalization
  enable_tag_normalization = true
  tag_key_case             = "snake_case"

  tags = {
    "TestCase" = "basic-tagging"
  }
}

# Test legacy compatibility
module "ecr_legacy_tagging" {
  source = "../../.."

  name         = "test-legacy-tagging-${random_pet.suffix.id}"
  force_delete = true

  # Disable all advanced features
  enable_default_tags      = false
  enable_tag_validation    = false
  enable_tag_normalization = false

  tags = {
    Environment = "test"
    Owner       = "terraform-test"
    TestCase    = "legacy-compatibility"
  }
}

resource "random_pet" "suffix" {
  length = 2
}