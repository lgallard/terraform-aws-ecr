![Terraform](https://lgallardo.com/images/terraform.jpg)
# terraform-aws-ecr
Terraform module to create [AWS ECR](https://aws.amazon.com/ecr/) (Elastic Container Registry) which is a fully-managed Docker container registry.

## Architecture

The terraform-aws-ecr module enables several common architectures for container image management.

### Basic ECR Architecture

```
┌──────────────┐     ┌───────────────────────┐     ┌─────────────────┐
│              │     │                       │     │                 │
│  Developer   │────▶│    AWS ECR Registry   │◀────│  CI/CD Pipeline │
│  Workstation │     │                       │     │                 │
│              │     └───────────────────────┘     └─────────────────┘
└──────────────┘               │  ▲
                               │  │
                               ▼  │
                        ┌─────────────────┐
                        │                 │
                        │   ECS / EKS     │
                        │   Services      │
                        │                 │
                        └─────────────────┘
```

For more detailed architecture diagrams including CI/CD integration, multi-region deployments, and security controls, see [docs/diagrams.md](docs/diagrams.md).

## Versioning

This module follows [Semantic Versioning](https://semver.org/) principles. For full details on the versioning scheme, release process, and compatibility guarantees, see the following documentation:

- [VERSIONING.md](VERSIONING.md) - Details on the semantic versioning scheme and release process
- [VERSION_COMPATIBILITY.md](VERSION_COMPATIBILITY.md) - Terraform and AWS provider compatibility matrix

## Usage
You can use this module to create an ECR registry using few parameters (simple example) or define in detail every aspect of the registry (complete example).

Check the [examples](examples/) directory for examples including:
- **Simple** - Basic ECR repository with minimal configuration 
- **Complete** - Full-featured ECR repository with all options
- **Protected** - Repository with deletion protection
- **With ECS Integration** - ECR configured for use with ECS
- **Multi-Region** - Repository configured for cross-region replication

### Simple example
This example creates an ECR registry using few parameters

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name         = "ecr-repo-dev"

  # Tags
  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
  }
}
```

### Complete example with logging
In this example, the registry is defined in detail including CloudWatch logging:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name                 = "ecr-repo-dev"
  scan_on_push        = true
  timeouts_delete     = "60m"
  image_tag_mutability = "IMMUTABLE"
  encryption_type     = "KMS"

  # Enable CloudWatch logging
  enable_logging     = true
  log_retention_days = 14

  // ...rest of configuration...
}
```

### CloudWatch Logging

The module supports sending ECR API actions and image push/pull events to CloudWatch Logs. When enabled:

- Creates a CloudWatch Log Group `/aws/ecr/{repository-name}`
- Sets up necessary IAM roles and policies for ECR to write logs
- Configurable log retention period (default: 30 days)

To enable logging:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name           = "ecr-repo-dev"
  enable_logging = true

  # Optional: customize retention period (in days)
  log_retention_days = 14  # Valid values: 0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1827,3653
}
```

The module outputs logging-related ARNs:
- `cloudwatch_log_group_arn` - The ARN of the CloudWatch Log Group
- `logging_role_arn` - The ARN of the IAM role used for logging

### Complete example
In this example the register is defined in detailed.

```
module "ecr" {

  source = "lgallard/ecr/aws"

  name                 = "ecr-repo-dev"
  scan_on_push         = true
  timeouts_delete      = "60m"
  image_tag_mutability = "MUTABLE"
  prevent_destroy      = true  # Protect repository from accidental deletion


  # Note that currently only one policy may be applied to a repository.
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "repo policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF

  # Only one lifecycle policy can be used per repository.
  # To apply multiple rules, combined them in one policy JSON.
  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 30 dev images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["dev"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

  # Tags
  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
  }

}

### Deleting ECR Repositories Protected with prevent_destroy

By default, ECR repositories created by this module have `prevent_destroy = true` set in their lifecycle configuration to prevent accidental deletion. When you need to remove a repository:

1. Set the `prevent_destroy` parameter to `false` for the module:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "ecr-repo-dev"
  prevent_destroy = false  # Allow repository to be destroyed
}
```

2. Apply the configuration change:

```bash
terraform apply
```

3. After successful apply, run destroy as normal:

```bash
terraform destroy
```

This approach allows protecting repositories by default while providing a controlled way to remove them when needed.

## Security Best Practices

Here are key security best practices for your ECR repositories:

1. **Enable Immutable Tags**: Prevent tags from being overwritten to ensure image integrity.
   ```hcl
   image_tag_mutability = "IMMUTABLE"
   ```

2. **Enable Vulnerability Scanning**: Automatically scan images for security vulnerabilities.
   ```hcl
   scan_on_push = true
   ```

3. **Implement Least Privilege Access**: Use repository policies that grant only necessary permissions.
   
4. **Enable KMS Encryption**: Use AWS KMS for enhanced encryption of container images.
   ```hcl
   encryption_type = "KMS"
   ```

5. **Configure Lifecycle Policies**: Automatically clean up old or unused images.

For a comprehensive guide with detailed examples, see [docs/security-best-practices.md](docs/security-best-practices.md).

## Troubleshooting

Common issues and solutions when working with ECR repositories:

| Issue | Solution |
|-------|----------|
| Authentication failures | Re-authenticate with `aws ecr get-login-password` |
| Permission denied errors | Check IAM policies and repository policies |
| Cannot delete repository | Check for `prevent_destroy` setting and set to `false` |
| Image scan failures | Verify supported image format and AWS region |
| Lifecycle policy not working | Check rule syntax and priorities |

For detailed troubleshooting steps, see [docs/troubleshooting.md](docs/troubleshooting.md).

## Variable Usage Examples

This module offers many configuration options through variables. Here are some examples of common variable configurations:

### Basic Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name   = "my-app-repo"
  tags   = {
    Environment = "Production"
  }
}
```

### Security Settings

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name                 = "secure-repo"
  image_tag_mutability = "IMMUTABLE"    # Prevent tag overwriting
  scan_on_push         = true           # Enable vulnerability scanning
  encryption_type      = "KMS"          # Use KMS encryption
  prevent_destroy      = true           # Protect from accidental deletion
}
```

### Advanced Options

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name            = "advanced-repo"
  force_delete    = false
  enable_logging  = true
  
  # Set custom timeouts
  timeouts = {
    delete = "45m"
  }
}
```

For detailed examples of all variables with explanations, see [docs/variable-examples.md](docs/variable-examples.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecr_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_lifecycle_policy.lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.repo_protected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_role.ecr_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.kms_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging for the repository.<br/>When enabled, ECR API actions and image push/pull events will be logged to CloudWatch.<br/>Defaults to false. | `bool` | `false` | no |
| <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type) | The encryption type for the repository. Valid values are "KMS" or "AES256". | `string` | `"AES256"` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to delete the repository even if it contains images.<br/>Setting this to true will delete all images in the repository when the repository is deleted.<br/>Use with caution as this operation cannot be undone.<br/>Defaults to false for safety. | `bool` | `false` | no |
| <a name="input_image_scanning_configuration"></a> [image\_scanning\_configuration](#input\_image\_scanning\_configuration) | Configuration block that defines image scanning configuration for the repository.<br/>Set to null to use the scan\_on\_push variable setting.<br/>Example: { scan\_on\_push = true } | <pre>object({<br/>    scan_on_push = bool<br/>  })</pre> | `null` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository.<br/>- MUTABLE: Image tags can be overwritten<br/>- IMMUTABLE: Image tags cannot be overwritten (recommended for production)<br/>Defaults to MUTABLE to maintain backwards compatibility. | `string` | `"MUTABLE"` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | The ARN of an existing KMS key to use for repository encryption.<br/>Only applicable when encryption\_type is set to 'KMS'.<br/>If not specified when using KMS encryption, a new KMS key will be created. | `string` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | JSON string representing the lifecycle policy.<br/>If null (default), no lifecycle policy will be created.<br/>See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain ECR logs in CloudWatch.<br/>Only applicable when enable\_logging is true.<br/>Defaults to 30 days. | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECR repository. This name must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON string representing the repository policy.<br/>If null (default), no repository policy will be created.<br/>See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html | `string` | `null` | no |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Whether to protect the repository from being destroyed.<br/>When set to true, the repository will have the lifecycle block with prevent\_destroy = true.<br/>When set to false, the repository can be destroyed.<br/>This provides a way to dynamically control protection against accidental deletion.<br/>Defaults to false to allow repository deletion. | `bool` | `false` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Indicates whether images should be scanned for vulnerabilities after being pushed to the repository.<br/>- true: Images will be automatically scanned after each push<br/>- false: Images must be scanned manually<br/>Only used if image\_scanning\_configuration is null. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources created by this module.<br/>Tags are key-value pairs that help you manage, identify, organize, search for and filter resources.<br/>Example: { Environment = "Production", Owner = "Team" } | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration for repository operations.<br/>Specify as an object with a 'delete' key containing a duration string (e.g. "20m").<br/>Example: { delete = "20m" } | <pre>object({<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_timeouts_delete"></a> [timeouts\_delete](#input\_timeouts\_delete) | Deprecated: Use timeouts = { delete = "duration" } instead.<br/>How long to wait for a repository to be deleted.<br/>Specify as a duration string, e.g. "20m" for 20 minutes. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch Log Group used for ECR logs (if logging is enabled) |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used for repository encryption. |
| <a name="output_logging_role_arn"></a> [logging\_role\_arn](#output\_logging\_role\_arn) | The ARN of the IAM role used for ECR logging (if logging is enabled) |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | ID of the ECR registry |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
