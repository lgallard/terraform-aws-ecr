# Enhanced KMS Configuration Example

This example demonstrates the enhanced KMS key configuration capabilities introduced by the KMS submodule refactoring.

## Features Demonstrated

- **Enhanced Key Configuration**: Custom rotation periods, multi-region keys, and deletion windows
- **Advanced Access Control**: Key administrators, users, and additional principals
- **Custom Policy Support**: Both custom policy statements and complete custom policies
- **Flexible Aliasing**: Custom alias names and patterns
- **Comprehensive Tagging**: KMS-specific tags in addition to general resource tags

## Examples Included

### 1. Basic Enhanced KMS
- Custom deletion window (14 days)
- Key rotation with custom period (90 days)
- Enhanced tagging for KMS resources

### 2. Advanced Enhanced KMS
- Multi-region key configuration
- Role-based access control with administrators and users
- Custom alias naming pattern
- Extended rotation period (180 days)
- Production-level tagging strategy

### 3. Custom Policy Statements
- Additional services (CloudTrail) permissions
- Cross-account access with conditions
- Service-specific restrictions
- Conditional access policies

### 4. Complete Custom Policy
- Fully custom policy JSON
- Restricted access patterns
- Time-based conditions
- Service-specific constraints

## Usage

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** installed
3. **AWS Provider >= 5.0** configured

### Required IAM Permissions

The executing role/user needs permissions for:
- ECR repository management
- KMS key creation and management
- IAM policy management
- Resource tagging

### Deployment

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd terraform-aws-ecr/examples/enhanced-kms
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Clean up resources**:
   ```bash
   terraform destroy
   ```

### Custom Configuration

To use with your own settings, modify the variables:

```hcl
# terraform.tfvars
aws_region = "us-west-2"
trusted_account_id = "123456789012"
```

## Key Configuration Options

### Basic Configuration
- `kms_deletion_window_in_days`: 7-30 days
- `kms_enable_key_rotation`: true/false
- `kms_key_rotation_period`: 90-2555 days

### Access Control
- `kms_key_administrators`: Full key management access
- `kms_key_users`: Cryptographic operations access
- `kms_additional_principals`: Basic encrypt/decrypt access

### Policy Customization
- `kms_custom_policy_statements`: Add statements to generated policy
- `kms_custom_policy`: Complete custom policy (overrides all)

### Advanced Options
- `kms_multi_region`: Multi-region key creation
- `kms_alias_name`: Custom alias naming
- `kms_tags`: KMS-specific resource tags

## Security Best Practices

1. **Least Privilege**: Use specific roles instead of root account access
2. **Key Rotation**: Enable automatic rotation for enhanced security
3. **Multi-Region**: Consider for cross-region operations
4. **Monitoring**: Use CloudTrail to monitor key usage
5. **Backup**: Use appropriate deletion windows for recovery

## Cost Considerations

- **Multi-region keys**: Higher cost than single-region keys
- **Key rotation**: Minimal additional cost for AWS-managed keys
- **API calls**: Monitor KMS API usage for cost optimization

## Outputs

Each example provides:
- Repository details (name, URL)
- KMS key information (ARN, ID, alias)
- Configuration summary
- Applied tags and policies

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure IAM role has KMS permissions
2. **Alias Conflicts**: KMS aliases must be unique within region
3. **Policy Validation**: Custom policies must be valid JSON
4. **Resource Limits**: AWS has limits on KMS keys per region

### Validation Commands

```bash
# Verify KMS key creation
aws kms describe-key --key-id <key-id>

# Check key policy
aws kms get-key-policy --key-id <key-id> --policy-name default

# List key aliases
aws kms list-aliases --key-id <key-id>

# Verify ECR repository encryption
aws ecr describe-repositories --repository-names <repo-name>
```

## Integration Examples

### With CI/CD Pipelines

```hcl
# Grant CI/CD role access to KMS key
kms_key_users = [
  "arn:aws:iam::123456789012:role/GitHubActions-ECR-Role",
  "arn:aws:iam::123456789012:role/Jenkins-ECR-Role"
]
```

### With Cross-Account Access

```hcl
# Allow trusted account access
kms_custom_policy_statements = [
  {
    sid    = "CrossAccountAccess"
    effect = "Allow"
    principals = {
      type        = "AWS"
      identifiers = ["arn:aws:iam::TRUSTED-ACCOUNT:root"]
    }
    actions = ["kms:Decrypt", "kms:DescribeKey"]
    conditions = [
      {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["ecr.region.amazonaws.com"]
      }
    ]
  }
]
```

### With Monitoring and Alerting

```hcl
# KMS-specific tags for monitoring
kms_tags = {
  MonitoringLevel = "high"
  AlertOnUsage   = "true"
  CostCenter     = "engineering"
}
```

## Related Documentation

- [AWS KMS Developer Guide](https://docs.aws.amazon.com/kms/latest/developerguide/)
- [ECR Encryption Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/encryption-at-rest.html)
- [KMS Key Policies](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)
- [KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
