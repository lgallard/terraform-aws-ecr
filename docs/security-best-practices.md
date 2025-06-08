# ECR Security Best Practices

This document outlines security best practices for using AWS ECR repositories created with the terraform-aws-ecr module.

## Least Privilege Access

Apply the principle of least privilege by creating repository policies that grant only the necessary permissions:

### Example: Limited Read-Only Access

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "LimitedReadAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EcsServiceRole"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
```

### Example: Controlled Push Access

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "LimitedPushAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CICDPipelineRole"
        },
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}
```

## Image Scanning and Vulnerability Management

### Enable Enhanced Scanning with AWS Inspector

For comprehensive security assessment, enable enhanced scanning with AWS Inspector integration:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  # Enhanced scanning configuration
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true
  
  # Filter for high and critical vulnerabilities
  registry_scan_filters = [
    {
      name   = "PACKAGE_VULNERABILITY_SEVERITY"
      values = ["HIGH", "CRITICAL"]
    }
  ]
}
```

Enhanced scanning provides:
- **OS and application vulnerability detection**: Comprehensive assessment using AWS Inspector
- **Secret detection**: Automatic identification of exposed API keys, passwords, and tokens
- **Compliance reporting**: Integration with AWS Security Hub and other services
- **Detailed remediation guidance**: Specific recommendations for fixing vulnerabilities

### Enable Basic Scanning (Alternative)

For basic vulnerability scanning without Inspector integration:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  scan_on_push = true
}
```

### Block Deployment of Vulnerable Images

Combine ECR scanning with CI/CD pipeline controls to prevent deployment of vulnerable images:

1. Configure your CI/CD pipeline to:
   - Pull scan results from ECR after pushing an image
   - Analyze the severity of findings
   - Block deployment if critical vulnerabilities are found

2. Example pipeline step (AWS CodeBuild):

```yaml
build:
  commands:
    - aws ecr describe-image-scan-findings --repository-name secure-ecr-repo --image-id imageTag=$IMAGE_TAG
    - |
      if [[ $(aws ecr describe-image-scan-findings --repository-name secure-ecr-repo --image-id imageTag=$IMAGE_TAG --query 'imageScanFindings.findings[?severity==`CRITICAL`]' --output json | jq length) -gt 0 ]]; then
        echo "Critical vulnerabilities found in image. Deployment blocked."
        exit 1
      fi
```

## Encryption

### Use KMS Encryption

Enable KMS encryption for ECR repositories containing sensitive images:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  encryption_type = "KMS"
  # Optionally specify your own KMS key:
  # kms_key = "arn:aws:kms:us-east-1:123456789012:key/your-key-id"
}
```

### Use Customer-Managed KMS Keys for Added Security

For enhanced control, create and manage your own KMS key:

```hcl
resource "aws_kms_key" "ecr_key" {
  description             = "KMS key for ECR repository encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  policy = jsonencode({
    // Custom key policy ...
  })
}

module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  encryption_type = "KMS"
  kms_key         = aws_kms_key.ecr_key.arn
}
```

## Image Immutability

Enable image tag immutability to prevent accidental or malicious overwriting of images:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  image_tag_mutability = "IMMUTABLE"
}
```

## Repository Protection

Enable protection for critical repositories to prevent accidental deletion:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  prevent_destroy = true
}
```

## Regular Image Cleanup

Implement lifecycle policies to limit exposure to older, potentially vulnerable images:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire images older than 90 days",
        selection = {
          tagStatus   = "any",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 90
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

## Pull-Through Cache for Enhanced Security

Configure pull-through cache to reduce external dependencies and improve security posture:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  # Enable pull-through cache for trusted registries
  enable_pull_through_cache = true
  pull_through_cache_rules = [
    {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
    },
    {
      ecr_repository_prefix = "quay"
      upstream_registry_url = "quay.io"
    }
  ]
}
```

Pull-through cache benefits:
- **Reduced external dependencies**: Images are cached locally, reducing reliance on external registries
- **Improved performance**: Faster image pulls from local cache
- **Enhanced security**: Centralized control over which upstream registries are allowed
- **Cost optimization**: Reduced data transfer costs from external registries
- **Availability**: Images remain accessible even if upstream registries are unavailable

### Usage with Pull-Through Cache

```bash
# Pull from cached Docker Hub image
docker pull <account>.dkr.ecr.<region>.amazonaws.com/docker-hub/library/nginx:latest

# Pull from cached Quay image
docker pull <account>.dkr.ecr.<region>.amazonaws.com/quay/prometheus/prometheus:latest
```

## Cross-Account Access Controls

For secure cross-account access:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "CrossAccountPull",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.consumer_account_id}:root"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
```

## Monitoring and Auditing

Enable AWS CloudTrail and CloudWatch to monitor ECR repository access:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-ecr-repo"
  
  # Enable CloudWatch logging
  enable_logging     = true
  log_retention_days = 90
  
  # Rest of configuration...
}
```