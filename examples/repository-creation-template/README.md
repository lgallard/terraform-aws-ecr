# ECR Repository Creation Template Example

This example shows how to configure repository creation templates for repositories that Amazon ECR creates on your behalf through pull-through cache, create-on-push, or replication workflows.

Repository creation templates apply only at repository creation time. They do not update existing repositories.

## What this example creates

- An ECR repository managed by the root module
- Pull-through cache rules for Docker Hub and Amazon ECR Public
- A pull-through cache repository creation template for the `docker-hub` prefix
- A default `ROOT` repository creation template for create-on-push and replication-created repositories

## Usage

```bash
terraform init
terraform plan
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.81.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_with_repository_creation_templates"></a> [ecr\_with\_repository\_creation\_templates](#module\_ecr\_with\_repository\_creation\_templates) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name for tagging | `string` | `"example"` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | The name of the ECR repository | `string` | `"repository-template-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#output\_pull\_through\_cache\_rules) | Configured pull-through cache rules |
| <a name="output_repository_creation_template_status"></a> [repository\_creation\_template\_status](#output\_repository\_creation\_template\_status) | Status of ECR repository creation template configuration |
| <a name="output_repository_creation_templates"></a> [repository\_creation\_templates](#output\_repository\_creation\_templates) | Map of ECR repository creation templates keyed by prefix |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
