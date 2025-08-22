# Pull-Through Cache Submodule

This submodule manages AWS ECR pull-through cache rules and associated IAM resources.

## Features

- Creates pull-through cache rules for upstream registries
- Manages IAM role and policies for cache operations
- Supports multiple cache rules with different upstream registries
- Provides comprehensive validation for configuration inputs

## Usage

```hcl
module "pull_through_cache" {
  source = "./modules/pull-through-cache"

  name           = "my-ecr-repo"
  aws_account_id = "123456789012"

  pull_through_cache_rules = [
    {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "https://registry-1.docker.io"
      credential_arn        = null
    },
    {
      ecr_repository_prefix = "quay"
      upstream_registry_url = "https://quay.io"
      credential_arn        = "arn:aws:secretsmanager:us-west-2:123456789012:secret:my-quay-credentials"
    }
  ]

  tags = {
    Environment = "production"
    Module      = "pull-through-cache"
  }
}
```

## Supported Upstream Registries

- Docker Hub (`https://registry-1.docker.io`)
- Amazon ECR Public (`https://public.ecr.aws`)
- Quay.io (`https://quay.io`)
- GitHub Container Registry (`https://ghcr.io`)
- Azure Container Registry
- Google Container Registry
- Custom registries

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_pull_through_cache_rule.cache_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_iam_role.pull_through_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.pull_through_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name to use for the ECR repository and related resources. | `string` | n/a | yes |
| aws_account_id | The AWS account ID. | `string` | n/a | yes |
| pull_through_cache_rules | List of pull-through cache rules to create. | `list(object({ecr_repository_prefix=string, upstream_registry_url=string, credential_arn=optional(string)}))` | `[]` | no |
| tags | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| pull_through_cache_rules | List of pull-through cache rules |
| pull_through_cache_role_arn | The ARN of the IAM role used for pull-through cache operations |
