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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_principals"></a> [additional\_principals](#input\_additional\_principals) | List of additional IAM principals (ARNs) to grant access to the KMS key | `list(string)` | `[]` | no |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | Custom alias name for the KMS key (without 'alias/' prefix). If not provided, uses 'ecr/{name}' | `string` | `null` | no |
| <a name="input_allow_ecr_service"></a> [allow\_ecr\_service](#input\_allow\_ecr\_service) | Whether to allow the ECR service to use the KMS key | `bool` | `true` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID (used for policy generation) | `string` | n/a | yes |
| <a name="input_create_alias"></a> [create\_alias](#input\_create\_alias) | Whether to create a KMS alias for the key | `bool` | `true` | no |
| <a name="input_custom_policy"></a> [custom\_policy](#input\_custom\_policy) | Complete custom policy JSON for the KMS key (overrides all other policy settings) | `string` | `null` | no |
| <a name="input_custom_policy_statements"></a> [custom\_policy\_statements](#input\_custom\_policy\_statements) | List of custom policy statements to add to the KMS key policy | <pre>list(object({<br/>    sid    = optional(string)<br/>    effect = string<br/>    principals = optional(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    }))<br/>    actions   = list(string)<br/>    resources = optional(list(string), ["*"])<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Number of days to wait before actually deleting the key (7-30 days) | `number` | `7` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the KMS key | `string` | `null` | no |
| <a name="input_enable_default_policy"></a> [enable\_default\_policy](#input\_enable\_default\_policy) | Whether to enable the default KMS key policy | `bool` | `true` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Whether to enable automatic key rotation | `bool` | `true` | no |
| <a name="input_key_administrators"></a> [key\_administrators](#input\_key\_administrators) | List of IAM principals (ARNs) who can administer the KMS key | `list(string)` | `[]` | no |
| <a name="input_key_rotation_period"></a> [key\_rotation\_period](#input\_key\_rotation\_period) | Number of days between automatic key rotations (90-2555 days, AWS managed keys only) | `number` | `null` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Key usage (ENCRYPT\_DECRYPT, SIGN\_VERIFY, GENERATE\_VERIFY\_MAC) | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_key_users"></a> [key\_users](#input\_key\_users) | List of IAM principals (ARNs) who can use the KMS key for cryptographic operations | `list(string)` | `[]` | no |
| <a name="input_kms_tags"></a> [kms\_tags](#input\_kms\_tags) | Additional tags specific to KMS resources | `map(string)` | `{}` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Whether to create a multi-region key | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for KMS resources (typically the ECR repository name) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the KMS key and alias | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | The Amazon Resource Name (ARN) of the KMS alias |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | The display name of the KMS alias |
| <a name="output_configuration_summary"></a> [configuration\_summary](#output\_configuration\_summary) | Summary of KMS configuration |
| <a name="output_deletion_window_in_days"></a> [deletion\_window\_in\_days](#output\_deletion\_window\_in\_days) | The deletion window for the KMS key in days |
| <a name="output_enable_key_rotation"></a> [enable\_key\_rotation](#output\_enable\_key\_rotation) | Whether key rotation is enabled |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The Amazon Resource Name (ARN) of the KMS key |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique identifier for the KMS key |
| <a name="output_key_usage"></a> [key\_usage](#output\_key\_usage) | The key usage of the KMS key |
| <a name="output_kms_alias"></a> [kms\_alias](#output\_kms\_alias) | Complete KMS alias information |
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | Complete KMS key information |
| <a name="output_multi_region"></a> [multi\_region](#output\_multi\_region) | Whether the KMS key is a multi-region key |
| <a name="output_rotation_period_in_days"></a> [rotation\_period\_in\_days](#output\_rotation\_period\_in\_days) | The rotation period for the KMS key in days |
| <a name="output_target_key_id"></a> [target\_key\_id](#output\_target\_key\_id) | The key identifier that the alias refers to |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
