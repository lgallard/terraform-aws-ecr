# ECR Repository with Replication Example

This example demonstrates how to create an ECR repository with built-in cross-region replication support using the module's new replication features.

## What This Example Creates

- ECR repository with immutable tags for consistency
- Automatic cross-region replication to specified regions
- Optional CloudWatch logging
- Proper tagging for resource management

## Architecture

```
┌─────────────────────┐
│   Primary Region    │
│   (us-east-1)       │
│ ┌─────────────────┐ │
│ │ ECR Repository  │ │─────┐
│ │   (Source)      │ │     │
│ └─────────────────┘ │     │
└─────────────────────┘     │
                            │ Automatic
                            │ Replication
┌─────────────────────┐     │
│ Secondary Regions   │     │
│ (us-west-2,         │◄────┘
│  eu-west-1)         │
│ ┌─────────────────┐ │
│ │ ECR Repository  │ │
│ │   (Replicas)    │ │
│ └─────────────────┘ │
└─────────────────────┘
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.3.0
- AWS Provider >= 5.0.0

## Usage

1. Clone this repository
2. Navigate to this example directory
3. Update variables as needed
4. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

### Basic Configuration

```hcl
module "ecr_with_replication" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable replication
  enable_replication  = true
  replication_regions = ["us-west-2", "eu-west-1"]

  # Additional options
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  enable_logging       = true
}
```

## Important Notes

1. **Registry-Level Configuration**: ECR replication is configured at the registry level, meaning it affects all repositories in your AWS account for the specified regions.

2. **Immutable Tags Recommended**: When using replication, it's recommended to use immutable tags to ensure consistency across regions.

3. **Replication Delay**: There may be a slight delay in replication. Monitor replication status using the provided outputs.

4. **Cost Considerations**: Cross-region replication incurs additional costs for data transfer and storage.

## Monitoring Replication

You can monitor replication status using the module outputs:

```hcl
output "replication_info" {
  value = {
    status                = module.ecr_with_replication.replication_status
    regions              = module.ecr_with_replication.replication_regions
    configuration_arn    = module.ecr_with_replication.replication_configuration_arn
  }
}
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

Note: If repositories contain images, you may need to set `force_delete = true` in the module configuration or manually delete the images first.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_with_replication"></a> [ecr\_with\_replication](#module\_ecr\_with\_replication) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging | `bool` | `false` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Whether to enable ECR replication | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"example"` | no |
| <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region) | Primary AWS region | `string` | `"us-east-1"` | no |
| <a name="input_replication_regions"></a> [replication\_regions](#input\_replication\_regions) | List of regions to replicate ECR images to | `list(string)` | <pre>[<br/>  "us-west-2",<br/>  "eu-west-1"<br/>]</pre> | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the ECR repository | `string` | `"replication-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_replication_configuration_arn"></a> [replication\_configuration\_arn](#output\_replication\_configuration\_arn) | ARN of the replication configuration |
| <a name="output_replication_regions"></a> [replication\_regions](#output\_replication\_regions) | Regions where images are replicated |
| <a name="output_replication_status"></a> [replication\_status](#output\_replication\_status) | Replication configuration status |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
