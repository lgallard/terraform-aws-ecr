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
