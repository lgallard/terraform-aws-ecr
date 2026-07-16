# ECR with ECS Integration Example

This example demonstrates how to create an ECR repository and integrate it with ECS for containerized deployments.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│                 │     │                  │     │                 │
│  CI/CD System   │────▶│   ECR Repository │────▶│   ECS Service   │
│  (Image Builds) │     │   (Image Store)  │     │  (Deployment)   │
│                 │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │                          │
                               ▼                          ▼
                        ┌──────────────┐          ┌───────────────┐
                        │              │          │               │
                        │ Image Scan   │          │ CloudWatch    │
                        │ (Security)   │          │ (Monitoring)  │
                        │              │          │               │
                        └──────────────┘          └───────────────┘
```

## What This Example Creates

1. An ECR repository with automatic vulnerability scanning
2. An ECS Cluster
3. An ECS Task Definition referencing the ECR repository
4. IAM roles for ECS to pull images from ECR
5. CloudWatch log group for container logs

## Usage

```bash
terraform init
terraform apply
```

After applying this Terraform code, you will need to:

1. Build and push your container image to the ECR repository
2. Create an ECS service using the task definition

## Pushing a Docker Image to ECR

Once the infrastructure is provisioned, you can push an image:

```bash
# Get ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build your image
docker build -t app-dev .

# Tag the image
docker tag app-dev:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/app-dev:latest

# Push the image
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/app-dev:latest
```

## Creating an ECS Service

After pushing your image, you can create an ECS service:

```bash
aws ecs create-service \
  --cluster app-cluster-dev \
  --service-name app-service \
  --task-definition app-dev \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}"
```

## Security Considerations

This example implements several security best practices:

1. **Immutable Tags**: Prevents overwriting existing container images
2. **Automatic Scanning**: Scans images for vulnerabilities on push
3. **Lifecycle Policy**: Automatically cleans up old images
4. **Least Privilege**: IAM policies grant minimal required permissions

## Clean Up

To destroy all resources created by this example:

```bash
terraform destroy
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_task_definition.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_pull](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
