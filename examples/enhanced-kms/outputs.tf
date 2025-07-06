# ----------------------------------------------------------
# Basic Enhanced KMS Outputs
# ----------------------------------------------------------

output "basic_enhanced_kms" {
  description = "Basic enhanced KMS configuration outputs"
  value = {
    repository_name   = module.ecr_basic_enhanced_kms.repository_name
    repository_url    = module.ecr_basic_enhanced_kms.repository_url
    kms_key_arn       = module.ecr_basic_enhanced_kms.kms_key_arn
    kms_configuration = module.ecr_basic_enhanced_kms.kms_configuration
  }
}

# ----------------------------------------------------------
# Advanced Enhanced KMS Outputs
# ----------------------------------------------------------

output "advanced_enhanced_kms" {
  description = "Advanced enhanced KMS configuration outputs"
  value = {
    repository_name   = module.ecr_advanced_enhanced_kms.repository_name
    repository_url    = module.ecr_advanced_enhanced_kms.repository_url
    kms_key_arn       = module.ecr_advanced_enhanced_kms.kms_key_arn
    kms_key_id        = module.ecr_advanced_enhanced_kms.kms_key_id
    kms_alias_arn     = module.ecr_advanced_enhanced_kms.kms_alias_arn
    kms_configuration = module.ecr_advanced_enhanced_kms.kms_configuration
  }
}

# ----------------------------------------------------------
# Custom Policy KMS Outputs
# ----------------------------------------------------------

output "custom_policy_kms" {
  description = "Custom policy KMS configuration outputs"
  value = {
    repository_name   = module.ecr_custom_policy_kms.repository_name
    repository_url    = module.ecr_custom_policy_kms.repository_url
    kms_key_arn       = module.ecr_custom_policy_kms.kms_key_arn
    kms_configuration = module.ecr_custom_policy_kms.kms_configuration
  }
}

# ----------------------------------------------------------
# Complete Custom Policy Outputs
# ----------------------------------------------------------

output "complete_custom_policy" {
  description = "Complete custom policy KMS configuration outputs"
  value = {
    repository_name   = module.ecr_complete_custom_policy.repository_name
    repository_url    = module.ecr_complete_custom_policy.repository_url
    kms_key_arn       = module.ecr_complete_custom_policy.kms_key_arn
    kms_configuration = module.ecr_complete_custom_policy.kms_configuration
  }
}

# ----------------------------------------------------------
# Summary Outputs
# ----------------------------------------------------------

output "kms_examples_summary" {
  description = "Summary of all KMS configuration examples"
  value = {
    basic_enhanced = {
      encryption_enabled = true
      multi_region       = false
      rotation_period    = 90
      custom_policy      = false
    }
    advanced_enhanced = {
      encryption_enabled = true
      multi_region       = true
      rotation_period    = 180
      custom_policy      = false
      access_control     = "role-based"
    }
    custom_policy = {
      encryption_enabled = true
      multi_region       = false
      rotation_period    = null
      custom_policy      = "statements"
      cross_account      = true
    }
    complete_custom = {
      encryption_enabled = true
      multi_region       = false
      rotation_period    = null
      custom_policy      = "complete"
      access_control     = "restricted"
    }
  }
}
