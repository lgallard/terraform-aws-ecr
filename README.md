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

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| image\_scanning\_configuration | Configuration block that defines image scanning configuration for the repository. By default, image scanning must be manually triggered. See the ECR User Guide for more information about image scanning. | `map` | `{}` | no |
| image\_tag\_mutability | The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. | `string` | `"MUTABLE"` | no |
| lifecycle\_policy | Manages the ECR repository lifecycle policy | `string` | n/a | yes |
| name | Name of the repository. | `string` | n/a | yes |
| policy | Manages the ECR repository policy | `string` | n/a | yes |
| scan\_on\_push | Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). | `bool` | `false` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| timeouts | Timeouts map. | `map` | `{}` | no |
| timeouts\_delete | Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | Full ARN of the repository |
| name | The name of the repository. |
| registry\_id | The registry ID where the repository was created. |
| repository\_url | The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`) |
