![Terraform](https://lgallardo.com/images/terraform.jpg)
# terraform-aws-ecr
Terraform module to create [AWS ECR](https://aws.amazon.com/ecr/) (Elastic Container Registry) which is a fully-managed Docker container registry.

## Usage
You can use this module to create an ECR registry using few parameters (simple example) or define in detail every aspect of the registry (complete example).

Check the [examples](examples/) for the  **simple** and the **complete** snippets.

### Simple example
This example creates an ECR registry using few parameters

```
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

### Complete example
In this example the register is defined in detailed.

```
module "ecr" {

  source = "lgallard/ecr/aws"

  name                 = "ecr-repo-dev"
  scan_on_push         = true
  timeouts_delete      = "60m"
  image_tag_mutability = "MUTABLE"


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

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_kms_alias.kms_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type) | The encryption type for the repository:<br/>- AES256: Use Amazon S3-managed encryption keys (SSE-S3)<br/>- KMS: Use AWS KMS-managed encryption keys (SSE-KMS)<br/>Default: AES256 | `string` | `"AES256"` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to delete the repository even if it contains images.<br/>Setting this to true will delete all images in the repository when the repository is deleted.<br/>Use with caution as this operation cannot be undone.<br/>Defaults to false for safety. | `bool` | `false` | no |
| <a name="input_image_scanning_configuration"></a> [image\_scanning\_configuration](#input\_image\_scanning\_configuration) | Configuration block that defines image scanning configuration for the repository.<br/>Can be provided as either:<br/>1. A map of configuration options (legacy format)<br/>2. An object with scan\_on\_push boolean (new format)<br/>If null (default), will use the scan\_on\_push variable setting.<br/>Example: { scan\_on\_push = true } | `any` | `null` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository.<br/>- MUTABLE: Image tags can be overwritten<br/>- IMMUTABLE: Image tags cannot be overwritten (recommended for production)<br/>Defaults to MUTABLE to maintain backwards compatibility. | `string` | `"MUTABLE"` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | The ARN of an existing KMS key to use for repository encryption.<br/>Only applicable when encryption\_type is set to 'KMS'.<br/>If not specified when using KMS encryption:<br/>- A new KMS key will be created if encryption\_type = "KMS"<br/>- The default AWS managed key will be used if encryption\_type = "AES256" | `string` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | JSON string representing the lifecycle policy.<br/>If null (default), no lifecycle policy will be created.<br/>See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECR repository. This name must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON string representing the repository policy.<br/>If null (default), no repository policy will be created.<br/>See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html | `string` | `null` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Indicates whether images should be scanned for vulnerabilities after being pushed to the repository.<br/>- true: Images will be automatically scanned after each push<br/>- false: Images must be scanned manually<br/>Only used if image\_scanning\_configuration is null. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources created by this module.<br/>Tags are key-value pairs that help you manage, identify, organize, search for and filter resources.<br/>Example: { Environment = "Production", Owner = "Team" } | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration for repository operations.<br/>Specify as a map with 'delete' key containing a duration string (e.g. "20m").<br/>Example: { delete = "20m" }<br/><br/>Note: While additional keys are allowed for backwards compatibility,<br/>only the 'delete' key is currently used by this module. | `any` | `{}` | no |
| <a name="input_timeouts_delete"></a> [timeouts\_delete](#input\_timeouts\_delete) | Deprecated: Use timeouts = { delete = "duration" } instead.<br/>How long to wait for a repository to be deleted.<br/>Specify as a duration string, e.g. "20m" for 20 minutes. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Full ARN of the repository |
| <a name="output_name"></a> [name](#output\_name) | The name of the repository. |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | The AWS account ID associated with the registry that contains the repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
