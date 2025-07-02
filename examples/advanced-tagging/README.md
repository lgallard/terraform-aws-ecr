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