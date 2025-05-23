# Multi-Region ECR Repository Example

This example demonstrates how to create an ECR repository that replicates images across multiple AWS regions for disaster recovery and global distribution use cases.

## Architecture

```
┌─────────────────┐     ┌──────────────────────┐
│                 │     │  Primary Region      │
│  CI/CD System   │────▶│  ┌───────────────┐   │
│  (Image Builds) │     │  │ ECR Repository│   │
│                 │     │  └───────────────┘   │
└─────────────────┘     └──────────┬───────────┘
                                   │
                                   │ Replication
                                   ▼
        ┌────────────────────────────────────────────┐
        │                                            │
        ▼                                            ▼
┌─────────────────────┐                   ┌─────────────────────┐
│  Secondary Region A │                   │  Secondary Region B │
│  ┌───────────────┐  │                   │  ┌───────────────┐  │
│  │ ECR Repository│  │                   │  │ ECR Repository│  │
│  └───────────────┘  │                   │  └───────────────┘  │
└─────────────────────┘                   └─────────────────────┘
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