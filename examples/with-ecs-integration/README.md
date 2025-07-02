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
