# Advanced Tagging Strategies Example

This example demonstrates the advanced tagging features available in the ECR Terraform module, including default tag templates, tag validation, and tag normalization.

## Features Demonstrated

### 1. Default Tag Templates

The module provides several predefined tag templates for common organizational needs:

- **`cost_allocation`**: Optimized for cost tracking and financial reporting
- **`compliance`**: Includes tags required for security and compliance frameworks
- **`sdlc`**: Tags for software development lifecycle management
- **`basic`**: Minimal set of organizational tags

### 2. Tag Validation

Ensures that required tags are present and validates tag compliance:

```hcl
enable_tag_validation = true
required_tags = ["Environment", "Owner", "Project", "CostCenter"]
```

### 3. Tag Normalization

Automatically normalizes tag keys to consistent casing and handles special characters:

```hcl
enable_tag_normalization = true
tag_key_case = "PascalCase"  # Options: PascalCase, camelCase, snake_case, kebab-case
normalize_tag_values = true
```

## Examples Included

### Cost Allocation Repository

```hcl
module "ecr_cost_allocation" {
  source = "../.."

  name = "cost-allocation-repo"

  # Use cost allocation template
  enable_default_tags = true
  default_tags_template = "cost_allocation"
  default_tags_environment = "production"
  default_tags_owner = "platform-team"
  default_tags_project = "user-service"
  default_tags_cost_center = "engineering-cc-001"
}
```

**Result**: Repository automatically tagged with cost allocation tags including billing information, resource type, and cost center details.

### Compliance Repository

```hcl
module "ecr_compliance" {
  source = "../.."

  name = "compliance-repo"

  # Use compliance template with strict validation
  enable_default_tags = true
  default_tags_template = "compliance"
  enable_tag_validation = true
  required_tags = [
    "Environment", "Owner", "Project", "CostCenter",
    "DataClass", "Compliance", "SecurityReview"
  ]
}
```

**Result**: Repository tagged for compliance with data classification, audit requirements, and security review status.

### SDLC Repository

```hcl
module "ecr_sdlc" {
  source = "../.."

  name = "sdlc-repo"

  # Use SDLC template with camelCase normalization
  enable_default_tags = true
  default_tags_template = "sdlc"
  tag_key_case = "camelCase"
}
```

**Result**: Repository tagged for development lifecycle management with deployment and versioning information.

### Custom Default Tags

```hcl
module "ecr_custom_defaults" {
  source = "../.."

  name = "custom-defaults-repo"

  # Custom default tags without template
  enable_default_tags = true
  default_tags_template = null
  default_tags_environment = "staging"
  default_tags_owner = "full-stack-team"
  tag_key_case = "snake_case"
}
```

**Result**: Repository with custom default tags and snake_case normalization for internal tooling compatibility.

### Legacy Compatibility

```hcl
module "ecr_legacy_compatible" {
  source = "../.."

  name = "legacy-repo"

  # Disable advanced tagging for legacy compatibility
  enable_default_tags = false
  enable_tag_validation = false
  enable_tag_normalization = false
}
```

**Result**: Repository with traditional manual tagging, maintaining full backward compatibility.

## Tag Templates Details

### Cost Allocation Template

Automatically applies these tags:
- `CreatedBy`: "Terraform"
- `ManagedBy`: "Terraform"
- `Environment`: From variable
- `Owner`: From variable
- `Project`: From variable
- `CostCenter`: From variable
- `BillingProject`: From project variable
- `ResourceType`: "ECR"
- `Service`: "ECR"
- `Billable`: "true"

### Compliance Template

Automatically applies these tags:
- All cost allocation tags plus:
- `DataClass`: "Internal"
- `Compliance`: "Required"
- `BackupRequired`: "true"
- `MonitoringLevel`: "Standard"
- `SecurityReview`: "Required"

### SDLC Template

Automatically applies these tags:
- Basic organizational tags plus:
- `Application`: From project variable
- `Version`: "latest"
- `DeploymentStage`: From environment variable
- `LifecycleStage`: From environment variable
- `MaintenanceWindow`: "weekend"

## Usage

1. **Deploy all examples:**
```bash
terraform init
terraform plan
terraform apply
```

2. **Deploy specific example:**
```bash
terraform apply -target=module.ecr_cost_allocation
```

3. **View applied tags:**
```bash
terraform output cost_allocation_applied_tags
```

## Validation and Compliance

The examples demonstrate different levels of tag validation:

- **Strict validation**: Compliance example requires all organizational tags
- **Basic validation**: Custom defaults example requires only essential tags
- **No validation**: Legacy example for backward compatibility

## Tag Normalization Examples

The examples show different normalization strategies:

- **PascalCase**: `CostCenter`, `ProjectName`
- **camelCase**: `costCenter`, `projectName`
- **snake_case**: `cost_center`, `project_name`
- **kebab-case**: `cost-center`, `project-name`

## Best Practices Demonstrated

1. **Consistent Organization**: Use templates for standardized tagging across teams
2. **Cost Management**: Leverage cost allocation tags for accurate billing
3. **Compliance**: Implement required tags for regulatory compliance
4. **Flexibility**: Support custom tagging strategies for specific needs
5. **Backward Compatibility**: Maintain legacy system compatibility when needed

## Outputs

Each example provides detailed outputs showing:
- Applied tags after normalization
- Tagging strategy configuration
- Tag compliance status
- Repository URLs and metadata

Run `terraform output` to see all available outputs and their current values.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_compliance"></a> [ecr\_compliance](#module\_ecr\_compliance) | ../.. | n/a |
| <a name="module_ecr_cost_allocation"></a> [ecr\_cost\_allocation](#module\_ecr\_cost\_allocation) | ../.. | n/a |
| <a name="module_ecr_custom_defaults"></a> [ecr\_custom\_defaults](#module\_ecr\_custom\_defaults) | ../.. | n/a |
| <a name="module_ecr_legacy_compatible"></a> [ecr\_legacy\_compatible](#module\_ecr\_legacy\_compatible) | ../.. | n/a |
| <a name="module_ecr_sdlc"></a> [ecr\_sdlc](#module\_ecr\_sdlc) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center for billing allocation | `string` | `"engineering-demo"` | no |
| <a name="input_enable_strict_validation"></a> [enable\_strict\_validation](#input\_enable\_strict\_validation) | Whether to enable strict tag validation | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name for tagging | `string` | `"development"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for repository names to avoid conflicts during testing or parallel deployments | `string` | `""` | no |
| <a name="input_owner_team"></a> [owner\_team](#input\_owner\_team) | Team that owns these resources | `string` | `"platform-team"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for tagging | `string` | `"advanced-tagging-demo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compliance_applied_tags"></a> [compliance\_applied\_tags](#output\_compliance\_applied\_tags) | Final tags applied to compliance repository |
| <a name="output_compliance_repo_url"></a> [compliance\_repo\_url](#output\_compliance\_repo\_url) | URL of the compliance repository |
| <a name="output_compliance_tag_compliance_status"></a> [compliance\_tag\_compliance\_status](#output\_compliance\_tag\_compliance\_status) | Tag compliance status for compliance repository |
| <a name="output_cost_allocation_applied_tags"></a> [cost\_allocation\_applied\_tags](#output\_cost\_allocation\_applied\_tags) | Final tags applied to cost allocation repository |
| <a name="output_cost_allocation_repo_url"></a> [cost\_allocation\_repo\_url](#output\_cost\_allocation\_repo\_url) | URL of the cost allocation repository |
| <a name="output_cost_allocation_tagging_strategy"></a> [cost\_allocation\_tagging\_strategy](#output\_cost\_allocation\_tagging\_strategy) | Tagging strategy used for cost allocation repository |
| <a name="output_custom_defaults_applied_tags"></a> [custom\_defaults\_applied\_tags](#output\_custom\_defaults\_applied\_tags) | Final tags applied to custom defaults repository |
| <a name="output_custom_defaults_repo_url"></a> [custom\_defaults\_repo\_url](#output\_custom\_defaults\_repo\_url) | URL of the custom defaults repository |
| <a name="output_legacy_applied_tags"></a> [legacy\_applied\_tags](#output\_legacy\_applied\_tags) | Final tags applied to legacy repository |
| <a name="output_legacy_repo_url"></a> [legacy\_repo\_url](#output\_legacy\_repo\_url) | URL of the legacy compatible repository |
| <a name="output_sdlc_applied_tags"></a> [sdlc\_applied\_tags](#output\_sdlc\_applied\_tags) | Final tags applied to SDLC repository |
| <a name="output_sdlc_repo_url"></a> [sdlc\_repo\_url](#output\_sdlc\_repo\_url) | URL of the SDLC repository |
| <a name="output_tagging_examples_summary"></a> [tagging\_examples\_summary](#output\_tagging\_examples\_summary) | Summary of all tagging examples and their strategies |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
