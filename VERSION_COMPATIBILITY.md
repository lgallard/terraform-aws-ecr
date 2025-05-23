# Version Compatibility

This document tracks the compatibility of this module with different versions of Terraform and the AWS provider.

## Terraform Compatibility Matrix

| Module Version | Minimum Terraform Version | Maximum Terraform Version | Notes |
|----------------|---------------------------|---------------------------|-------|
| >= 0.9.x       | 1.3.0                     | ~1.7.x                   | Uses Terraform features introduced in 1.3.0 |
| >= 0.7.x, < 0.9.x | 1.3.0                  | ~1.7.x                   | Uses moved blocks and lifecycle configurations |
| >= 0.5.x, < 0.7.x | 1.0.0                  | ~1.7.x                   | Works with Terraform 1.0.0+ |
| < 0.5.x        | 0.13.0                    | ~1.5.x                   | Legacy versions |

## AWS Provider Compatibility Matrix

| Module Version | Minimum AWS Provider Version | Maximum AWS Provider Version | Notes |
|----------------|------------------------------|------------------------------|-------|
| >= 0.9.x       | 5.0.0                        | < 6.0.0                      | Uses AWS provider features and API updates from v5.0.0+ |
| >= 0.7.x, < 0.9.x | 4.0.0                     | < 6.0.0                      | Compatible with AWS provider v4.0.0+ and v5.0.0+ |
| >= 0.5.x, < 0.7.x | 3.0.0                     | < 6.0.0                      | Compatible with most AWS provider versions |
| < 0.5.x        | 2.0.0                        | < 5.0.0                      | Legacy versions |

## Upgrade Guides

### Upgrading to 1.0.0 (Future)

Version 1.0.0 will mark the first stable release with a compatibility guarantee. Check back for specific upgrade steps when this version is released.

### Upgrading to 0.9.x

When upgrading from versions prior to 0.9.x:

1. Update your Terraform code to use AWS provider version 5.0.0+:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
```

2. Review the `prevent_destroy` variable implementation changes:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name = "your-repo-name"
  
  # In 0.9.x, prevent_destroy works with a different implementation
  prevent_destroy = true  # Repository protected from deletion
}
```

3. If you were using custom encryption settings, check that your KMS configuration is compatible with the updated module.

### Upgrading to 0.8.x

When upgrading from versions prior to 0.8.x:

1. The module now supports ECR logging configuration with CloudWatch. To enable this feature:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name = "your-repo-name"
  
  # New logging feature in 0.8.x
  enable_logging = true
  log_retention_days = 30  # Optional, defaults to 30
}
```

2. Review the outputs as new logging-related outputs have been added:
   - `cloudwatch_log_group_arn`
   - `logging_role_arn`

3. If you don't want to use logging, you don't need any changes - logging is disabled by default.

### Upgrading to 0.7.x

When upgrading from versions prior to 0.7.x:

1. The module now uses separate resources based on `prevent_destroy` value. Update your code to explicitly set this value:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name = "your-repo-name"
  
  # Explicitly set prevent_destroy
  prevent_destroy = true  # Or false, based on your needs
}
```

2. State migrations are handled automatically via Terraform's `moved` blocks, but you should verify that your repository has the correct protection status after upgrade.

3. Ensure you're using Terraform 1.3.0+ as this version is required for the new implementation.

## Testing Methodology

Each release is tested against the following environments:

- Latest stable Terraform version
- Minimum supported Terraform version (per compatibility matrix)
- AWS provider versions as specified in the compatibility matrix

Tests focus on:

- Successful resource creation
- Proper application of configuration options
- Handling of variable changes and updates
- Successful state migrations during upgrades

## Reporting Compatibility Issues

If you encounter compatibility problems:

1. Check if your Terraform and AWS provider versions match the supported ranges
2. Review the CHANGELOG.md for any breaking changes
3. Open an issue with details about your environment and the specific error