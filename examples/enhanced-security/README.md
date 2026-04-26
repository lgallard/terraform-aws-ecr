# Enhanced Security ECR Example

This example demonstrates how to configure an ECR repository with advanced security features, including:

- **Enhanced Scanning**: AWS Inspector integration for comprehensive vulnerability assessment
- **Secret Scanning**: Automatic detection of secrets, API keys, and credentials in container images
- **Pull-Through Cache**: Configuration for caching images from upstream registries
- **KMS Encryption**: Customer-managed encryption for enhanced security
- **Strict Access Controls**: Repository policies with conditional access
- **Security Monitoring**: CloudWatch logging for audit trails

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│  Container      │───▶│  ECR Repository  │───▶│  AWS Inspector  │
│  Images         │    │  (Enhanced)      │    │  (Scanning)     │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                          │
                              ▼                          ▼
                       ┌──────────────┐          ┌───────────────┐
                       │              │          │               │
                       │ Pull-Through │          │ Secret        │
                       │ Cache        │          │ Detection     │
                       │              │          │               │
                       └──────────────┘          └───────────────┘
```

## Features Enabled

### Enhanced Scanning
- **Registry-level configuration**: Applies to all repositories in the account
- **AWS Inspector integration**: Provides detailed vulnerability assessments
- **Severity filtering**: Configured to monitor HIGH and CRITICAL vulnerabilities
- **Secret detection**: Automatically scans for exposed credentials and API keys

### Pull-Through Cache
- **Docker Hub caching**: Reduces external dependencies and improves performance
- **Quay.io support**: Support for additional upstream registries
- **IAM integration**: Proper permissions for cache operations

### Security Controls
- **Immutable tags**: Prevents tag overwrites for better security
- **KMS encryption**: Customer-managed encryption keys
- **Conditional access**: Repository policies with resource-based conditions
- **Audit logging**: CloudWatch integration for security monitoring

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# View security status
terraform output security_status
```

## Security Best Practices Implemented

1. **Defense in Depth**: Multiple layers of security controls
2. **Least Privilege**: Restricted IAM permissions and repository policies
3. **Continuous Monitoring**: Enhanced scanning and logging enabled
4. **Encryption at Rest**: KMS encryption for sensitive images
5. **Image Integrity**: Immutable tags prevent tampering
6. **Automated Cleanup**: Lifecycle policies for security compliance

## Example Commands

### Check Scan Results
```bash
# Get scan findings for an image
aws ecr describe-image-scan-findings \
  --repository-name enhanced-security-repo \
  --image-id imageTag=latest

# List repositories with enhanced scanning
aws ecr describe-registry \
  --query 'scanningConfiguration'
```

### Pull Through Cache Usage
```bash
# Pull from cached Docker Hub image
docker pull <account-id>.dkr.ecr.<region>.amazonaws.com/docker-hub/library/nginx:latest

# Pull from cached Quay image
docker pull <account-id>.dkr.ecr.<region>.amazonaws.com/quay/prometheus/prometheus:latest
```

## Cost Considerations

- Enhanced scanning may incur additional costs based on image size and scan frequency
- Pull-through cache reduces egress costs but may increase storage costs
- CloudWatch logging costs depend on log volume and retention period

## Cleanup

```bash
terraform destroy
```

**Note**: Ensure no critical images are stored in the repository before destroying, as `force_delete` is set to handle cleanup automatically.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_enhanced_security"></a> [ecr\_enhanced\_security](#module\_ecr\_enhanced\_security) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_pull_through_cache"></a> [enable\_pull\_through\_cache](#input\_enable\_pull\_through\_cache) | Whether to enable pull-through cache rules | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, staging, dev) | `string` | `"dev"` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to delete the repository even if it contains images | `bool` | `false` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the ECR repository | `string` | `"enhanced-security-repo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used for encryption |
| <a name="output_pull_through_cache_role_arn"></a> [pull\_through\_cache\_role\_arn](#output\_pull\_through\_cache\_role\_arn) | ARN of the pull-through cache IAM role |
| <a name="output_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#output\_pull\_through\_cache\_rules) | List of configured pull-through cache rules |
| <a name="output_registry_scanning_status"></a> [registry\_scanning\_status](#output\_registry\_scanning\_status) | Registry scanning configuration status |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Security configuration status |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
