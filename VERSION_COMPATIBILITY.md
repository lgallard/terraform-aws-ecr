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

1. Review the prevent_destroy variable implementation changes
2. Be aware that the AWS provider requirement is now 5.0.0+ 
3. Update your Terraform code to match examples if using prevent_destroy functionality

### Upgrading to 0.8.x

When upgrading from versions prior to 0.8.x:

1. The module now supports ECR logging configuration with CloudWatch
2. Review the new logging configuration parameters if you want to implement this feature

### Upgrading to 0.7.x

When upgrading from versions prior to 0.7.x:

1. The module now uses separate resources based on prevent_destroy
2. State migrations are handled automatically
3. Ensure you're using Terraform 1.3.0+

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