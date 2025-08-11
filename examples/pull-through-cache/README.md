# Pull-Through Cache Example

This example demonstrates how to configure AWS ECR with pull-through cache rules for multiple upstream registries.

## Features Demonstrated

- Pull-through cache configuration for multiple upstream registries
- Docker Hub, Quay.io, GitHub Container Registry, and Amazon ECR Public integration
- Optional credential management for private registries
- Lifecycle policies optimized for cached images
- Enhanced image scanning and security features

## What This Example Creates

1. **ECR Repository** with pull-through cache enabled
2. **Pull-Through Cache Rules** for multiple upstream registries:
   - Docker Hub (`docker-hub/*`)
   - Quay.io (`quay/*`)
   - GitHub Container Registry (`ghcr/*`)
   - Amazon ECR Public (`public-ecr/*`)
3. **IAM Role and Policy** for cache operations
4. **Lifecycle Policy** to manage cached images
5. **Image Scanning** configuration

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# View outputs including pull examples
terraform output
```

## Configuration Options

### Required Variables

- `repository_name` - Name for your ECR repository

### Optional Variables

- `environment` - Environment tag (default: "dev")
- `force_delete` - Force delete repository with images (default: false)
- `quay_credentials_arn` - ARN for Quay.io credentials (for private repos)
- `github_credentials_arn` - ARN for GitHub credentials (for private repos)

## Using the Cache

Once deployed, you can pull images through your ECR cache:

```bash
# Configure AWS credentials
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
  --name "quay-io-credentials" \
  --description "Credentials for Quay.io private repositories" \
  --secret-string '{"username":"your-username","password":"your-password"}'

# Use the ARN in your Terraform variables
terraform apply -var="quay_credentials_arn=arn:aws:secretsmanager:us-west-2:123456789012:secret:quay-io-credentials-AbCdEf"
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
- Consider your image pull patterns when configuring cache rules