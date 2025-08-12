# ECR Pull-Through Cache Example

This example demonstrates how to configure Amazon ECR with pull-through cache rules to cache images from public registries like Docker Hub, Quay.io, GitHub Container Registry, and Amazon ECR Public.

## What This Example Creates

- **ECR Repository** with pull-through cache enabled
- **Pull-Through Cache Rules** for multiple upstream registries
- **IAM Role and Policies** for cache operations
- **Lifecycle Policy** for managing cached images
- **Enhanced Image Scanning** for security

## Architecture

```
External Registries          Your AWS ECR
┌─────────────────┐          ┌──────────────────┐
│   Docker Hub    │──────────│                  │
│     Quay.io     │   Pull   │  Pull-Through    │
│     GHCR        │ ────────►│     Cache        │
│  ECR Public     │          │                  │
└─────────────────┘          └──────────────────┘
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- ECR permissions for pull-through cache management

## Usage

### 1. Configure Variables

```bash
# Set your preferred AWS region
export AWS_DEFAULT_REGION=us-west-2

# Optional: Configure credentials for private registries
export TF_VAR_quay_credentials_arn="arn:aws:secretsmanager:region:account:secret:quay-creds"
export TF_VAR_github_credentials_arn="arn:aws:secretsmanager:region:account:secret:github-creds"
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3. Use Pull-Through Cache

After deployment, you can pull images through your cache:

```bash
# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com

# Pull from Docker Hub through your cache
docker pull <account-id>.dkr.ecr.us-west-2.amazonaws.com/docker-hub/library/nginx:latest

# Pull from Quay.io through your cache
docker pull <account-id>.dkr.ecr.us-west-2.amazonaws.com/quay/prometheus/prometheus:latest

# Pull from GitHub Container Registry through your cache
docker pull <account-id>.dkr.ecr.us-west-2.amazonaws.com/ghcr/actions/runner:latest

# Pull from Amazon ECR Public through your cache
docker pull <account-id>.dkr.ecr.us-west-2.amazonaws.com/public-ecr/amazonlinux:latest
```

## Benefits of Pull-Through Cache

1. **Reduced Latency** - Images cached in your AWS region
2. **Improved Reliability** - Reduces dependency on external registries
3. **Cost Optimization** - Reduces data transfer costs
4. **Enhanced Security** - Images scanned after caching
5. **Bandwidth Efficiency** - Shared cache across your organization

## Credential Management

For private registries, store credentials in AWS Secrets Manager:

```bash
# Example: Store Quay.io credentials
aws secretsmanager create-secret \
    --name "ecr-pullthroughcache/quay" \
    --description "Quay.io credentials for ECR pull-through cache" \
    --secret-string '{"username":"your-username","accessToken":"your-token"}'

# Example: Store GitHub credentials
aws secretsmanager create-secret \
    --name "ecr-pullthroughcache/github" \
    --description "GitHub Container Registry credentials" \
    --secret-string '{"username":"your-username","accessToken":"ghp_your_personal_access_token"}'
```

## Monitoring and Troubleshooting

- Check ECR console for cached images
- Monitor CloudWatch logs for cache operations
- Use AWS CLI to inspect cache rules: `aws ecr describe-pull-through-cache-rules`

## Clean Up

```bash
terraform destroy
```

**Note**: If `force_delete` is false and the repository contains images, you'll need to manually delete images first or set `force_delete = true`.

## Cost Considerations

- Storage costs apply to cached images
- Use lifecycle policies to manage storage costs