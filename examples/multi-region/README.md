# Multi-Region ECR Repository Example

This example demonstrates two approaches for creating ECR repositories across multiple AWS regions for disaster recovery and global distribution use cases:

1. **Built-in Replication (Recommended)** - Uses the module's new replication features for automatic cross-region replication
2. **Manual Setup (Alternative)** - Manually creates repositories in each region with custom replication configuration

## Architecture

### Built-in Replication Approach (Recommended)
```
┌─────────────────┐     ┌──────────────────────┐
│                 │     │  Primary Region      │
│  CI/CD System   │────▶│  ┌───────────────┐   │
│  (Image Builds) │     │  │ ECR Repository│   │
│                 │     │  │  + Replication│   │
│                 │     │  └───────────────┘   │
└─────────────────┘     └──────────┬───────────┘
                                   │
                                   │ Automatic Replication
                                   │ (Managed by AWS)
                                   ▼
┌─────────────────────┐
│  Secondary Region   │
│  ┌───────────────┐  │
│  │ ECR Repository│  │
│  │   (Replica)   │  │
│  └───────────────┘  │
└─────────────────────┘
```

### Manual Setup Approach (Alternative)
```
┌─────────────────┐     ┌──────────────────────┐
│                 │     │  Primary Region      │
│  CI/CD System   │────▶│  ┌───────────────┐   │
│  (Image Builds) │     │  │ ECR Repository│   │
│                 │     │  └───────────────┘   │
└─────────────────┘     └──────────┬───────────┘
                                   │
                                   │ Manual Replication Config
                                   ▼
┌─────────────────────┐
│  Secondary Region   │
│  ┌───────────────┐  │
│  │ ECR Repository│  │
│  │   (Manual)    │  │
│  └───────────────┘  │
└─────────────────────┘
```

## Use Cases

1. **Disaster Recovery** - Ensure container images are available even if a region becomes unavailable
2. **Global Deployments** - Deploy containers from region-local repositories to reduce latency
3. **Cross-Region Redundancy** - Support multi-region application architectures
4. **Edge Deployments** - Support edge computing scenarios with region-specific image repositories

## What This Example Creates

1. An ECR repository in the primary region
2. An ECR repository in the secondary region
3. ECR replication configuration to copy images automatically

## Prerequisites

- AWS account with permissions to create ECR resources in multiple regions
- Terraform 1.3.0+
- AWS provider 5.0.0+

## Usage

```bash
terraform init
terraform apply
```

After applying this Terraform code:

1. Push images to the primary region's repository
2. Images will automatically replicate to the secondary region
3. Your applications can pull from the geographically closest repository

## Pushing an Image

```bash
# Login to ECR in primary region
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build and tag your image
docker build -t multi-region-app:v1.0.0 .
docker tag multi-region-app:v1.0.0 <account-id>.dkr.ecr.us-east-1.amazonaws.com/multi-region-app:v1.0.0

# Push to primary region
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/multi-region-app:v1.0.0

# The image will automatically replicate to the secondary region
# You can pull from the secondary region after replication completes:
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com
docker pull <account-id>.dkr.ecr.us-west-2.amazonaws.com/multi-region-app:v1.0.0
```

## Monitoring Replication

You can monitor the replication status using AWS CLI:

```bash
aws ecr describe-images --repository-name multi-region-app --region us-east-1
aws ecr describe-images --repository-name multi-region-app --region us-west-2
```

## Best Practices

1. **Push to Primary Only** - Always push images to the primary region and let AWS handle replication
2. **Immutable Tags** - Use immutable tags to ensure consistency across regions
3. **Version Images** - Use semantic versioning in image tags (v1.0.0) rather than mutable tags like 'latest'
4. **Regional Endpoints** - Configure applications to pull from their regional ECR endpoint

## Clean Up

To destroy all resources created by this example:

```bash
terraform destroy
```

Note: You must delete all images from the repositories before they can be deleted, or set `force_delete = true` in the module configuration.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | 6.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_primary"></a> [ecr\_primary](#module\_ecr\_primary) | ../.. | n/a |
| <a name="module_ecr_secondary"></a> [ecr\_secondary](#module\_ecr\_secondary) | ../.. | n/a |
| <a name="module_ecr_with_replication"></a> [ecr\_with\_replication](#module\_ecr\_with\_replication) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_replication_configuration.manual_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_replication_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging | `bool` | `false` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Whether to use built-in ECR replication (recommended) | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"prod"` | no |
| <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region) | Primary AWS region for the ECR repository | `string` | `"us-east-1"` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the ECR repository | `string` | `"multi-region-app"` | no |
| <a name="input_secondary_region"></a> [secondary\_region](#input\_secondary\_region) | Secondary AWS region for the ECR repository | `string` | `"us-west-2"` | no |
| <a name="input_use_manual_setup"></a> [use\_manual\_setup](#input\_use\_manual\_setup) | Whether to demonstrate manual multi-region setup (alternative approach) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_approach_summary"></a> [approach\_summary](#output\_approach\_summary) | Summary of the multi-region approach being used |
| <a name="output_primary_repository_arn"></a> [primary\_repository\_arn](#output\_primary\_repository\_arn) | ARN of the primary ECR repository (manual setup) |
| <a name="output_primary_repository_url"></a> [primary\_repository\_url](#output\_primary\_repository\_url) | URL of the primary ECR repository (manual setup) |
| <a name="output_replicated_repository_arn"></a> [replicated\_repository\_arn](#output\_replicated\_repository\_arn) | ARN of the ECR repository with built-in replication |
| <a name="output_replicated_repository_url"></a> [replicated\_repository\_url](#output\_replicated\_repository\_url) | URL of the ECR repository with built-in replication |
| <a name="output_replication_regions"></a> [replication\_regions](#output\_replication\_regions) | Regions where images are replicated |
| <a name="output_replication_status"></a> [replication\_status](#output\_replication\_status) | Replication configuration status |
| <a name="output_secondary_repository_arn"></a> [secondary\_repository\_arn](#output\_secondary\_repository\_arn) | ARN of the secondary ECR repository (manual setup) |
| <a name="output_secondary_repository_url"></a> [secondary\_repository\_url](#output\_secondary\_repository\_url) | URL of the secondary ECR repository (manual setup) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
