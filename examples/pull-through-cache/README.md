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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_with_pull_through_cache"></a> [ecr\_with\_pull\_through\_cache](#module\_ecr\_with\_pull\_through\_cache) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to force delete the repository even if it contains images | `bool` | `false` | no |
| <a name="input_github_credentials_arn"></a> [github\_credentials\_arn](#input\_github\_credentials\_arn) | ARN of AWS Secrets Manager secret containing GitHub Container Registry credentials (optional) | `string` | `null` | no |
| <a name="input_quay_credentials_arn"></a> [quay\_credentials\_arn](#input\_quay\_credentials\_arn) | ARN of AWS Secrets Manager secret containing Quay.io credentials (optional) | `string` | `null` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | The name of the ECR repository | `string` | `"my-cached-repo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docker_pull_examples"></a> [docker\_pull\_examples](#output\_docker\_pull\_examples) | Example docker pull commands using the configured cache rules |
| <a name="output_pull_through_cache_role_arn"></a> [pull\_through\_cache\_role\_arn](#output\_pull\_through\_cache\_role\_arn) | ARN of the IAM role used for pull-through cache operations |
| <a name="output_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#output\_pull\_through\_cache\_rules) | List of configured pull-through cache rules |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | The registry ID where the repository was created |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | The ARN of the ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the ECR repository |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
