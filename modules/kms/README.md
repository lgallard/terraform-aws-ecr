# KMS Submodule

This submodule creates and manages KMS keys for ECR repository encryption with enhanced configuration options.

## Features

- **Flexible Key Configuration**: Support for different key specs, origins, and usage patterns
- **Advanced Policy Management**: Built-in policies with support for custom statements
- **Key Rotation**: Configurable automatic key rotation periods
- **Multi-Region Support**: Optional multi-region key creation
- **Comprehensive Aliasing**: Automatic alias creation with customizable names
- **Enhanced Security**: Support for key administrators, users, and additional principals

## Usage

### Basic Usage

```hcl
module "kms" {
  source = "./modules/kms"

  name           = "my-ecr-repo"
  aws_account_id = "123456789012"
}
```

### Advanced Configuration

```hcl
module "kms" {
  source = "./modules/kms"

  name                    = "production-app"
  description             = "KMS key for production ECR repository encryption"
  aws_account_id         = "123456789012"

  # Key configuration
  deletion_window_in_days = 14
  enable_key_rotation    = true
  key_rotation_period    = 90
  multi_region          = true

  # Access control
  key_administrators = [
    "arn:aws:iam::123456789012:role/KMSAdminRole"
  ]

  key_users = [
    "arn:aws:iam::123456789012:role/ECRAccessRole",
    "arn:aws:iam::123456789012:role/CI-CD-Role"
  ]

  additional_principals = [
    "arn:aws:iam::123456789012:role/CrossAccountRole"
  ]

  # Custom policy statements
  custom_policy_statements = [
    {
      sid    = "AllowCloudTrailEncryption"
      effect = "Allow"
      principals = {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  ]

  # Tagging
  tags = {
    Environment = "production"
    Application = "container-registry"
  }

  kms_tags = {
    KeyType = "ECR-Encryption"
    Rotation = "Enabled"
  }
}
```

### Custom Policy

```hcl
module "kms" {
  source = "./modules/kms"

  name           = "custom-policy-key"
  aws_account_id = "123456789012"

  # Override all policy generation with custom policy
  custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CustomRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for KMS resources | `string` | n/a | yes |
| aws_account_id | AWS Account ID | `string` | n/a | yes |
| description | Description for the KMS key | `string` | `null` | no |
| deletion_window_in_days | Number of days to wait before deleting the key | `number` | `7` | no |
| enable_key_rotation | Whether to enable automatic key rotation | `bool` | `true` | no |
| key_rotation_period | Number of days between automatic key rotations | `number` | `null` | no |
| multi_region | Whether to create a multi-region key | `bool` | `false` | no |
| key_spec | Key specification | `string` | `"SYMMETRIC_DEFAULT"` | no |
| key_origin | Key origin | `string` | `"AWS_KMS"` | no |
| key_usage | Key usage | `string` | `"ENCRYPT_DECRYPT"` | no |
| enable_default_policy | Whether to enable the default KMS key policy | `bool` | `true` | no |
| additional_principals | List of additional IAM principals to grant access | `list(string)` | `[]` | no |
| key_administrators | List of IAM principals who can administer the key | `list(string)` | `[]` | no |
| key_users | List of IAM principals who can use the key | `list(string)` | `[]` | no |
| allow_ecr_service | Whether to allow the ECR service to use the key | `bool` | `true` | no |
| custom_policy_statements | List of custom policy statements | `list(object)` | `[]` | no |
| custom_policy | Complete custom policy JSON | `string` | `null` | no |
| create_alias | Whether to create a KMS alias | `bool` | `true` | no |
| alias_name | Custom alias name for the KMS key | `string` | `null` | no |
| tags | Map of tags to assign to resources | `map(string)` | `{}` | no |
| kms_tags | Additional tags specific to KMS resources | `map(string)` | `{}` | no |

## Output Values

| Name | Description |
|------|-------------|
| key_arn | The ARN of the KMS key |
| key_id | The globally unique identifier for the KMS key |
| alias_arn | The ARN of the KMS alias |
| alias_name | The display name of the KMS alias |
| kms_key | Complete KMS key information |
| kms_alias | Complete KMS alias information |
| configuration_summary | Summary of KMS configuration |

## Policy Generation

The module generates KMS key policies based on the following precedence:

1. **Custom Policy** (highest precedence): If `custom_policy` is provided, it overrides all other policy settings
2. **Generated Policy**: Combines multiple policy sources:
   - Default root account permissions (if `enable_default_policy = true`)
   - ECR service permissions (if `allow_ecr_service = true`)
   - Key administrator permissions
   - Key user permissions
   - Additional principal permissions
   - Custom policy statements

### Default Policy Components

- **Root Account**: Full administrative access to the account root
- **ECR Service**: Encrypt/decrypt permissions for ECR service
- **Key Administrators**: Full key management permissions
- **Key Users**: Cryptographic operation permissions
- **Additional Principals**: Basic encrypt/decrypt permissions

## Best Practices

1. **Key Rotation**: Enable automatic key rotation for enhanced security
2. **Least Privilege**: Use specific roles instead of broad account access
3. **Multi-Region**: Consider multi-region keys for cross-region operations
4. **Monitoring**: Tag keys appropriately for cost and compliance tracking
5. **Backup**: Use appropriate deletion windows for recovery scenarios

## Examples

See the `examples/` directory for complete usage examples.
