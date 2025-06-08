# Variable Usage Examples

This document provides concrete examples of how to use the various variables in the terraform-aws-ecr module, along with explanations.

## Basic Variables

### `name` - Repository Name

The name of the ECR repository to create. This name must be unique within the AWS account and region.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"  # Repository will be named "application-backend"
}
```

### `tags` - Resource Tags

Tags to assign to all resources created by this module.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  tags = {
    Environment = "Production"
    Department  = "Engineering"
    Project     = "MyApp"
    Owner       = "DevOps Team"
    ManagedBy   = "Terraform"
  }
}
```

## Security Settings

### `scan_on_push` - Image Scanning

Enabling this setting ensures that all images are scanned for vulnerabilities when they are pushed to the repository.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  scan_on_push = true  # Images will be automatically scanned after being pushed
}
```

### `image_scanning_configuration` - Advanced Scanning Options

Alternative to using `scan_on_push` when more explicit configuration is preferred.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Equivalent to scan_on_push = true
  image_scanning_configuration = {
    scan_on_push = true
  }
}
```

### `enable_registry_scanning` - Enhanced Scanning with AWS Inspector

Enable registry-level enhanced scanning for comprehensive vulnerability assessment:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Enhanced scanning configuration
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true
  
  # Filter for high and critical vulnerabilities only
  registry_scan_filters = [
    {
      name   = "PACKAGE_VULNERABILITY_SEVERITY"
      values = ["HIGH", "CRITICAL"]
    }
  ]
}
```

### `enable_pull_through_cache` - Pull-Through Cache Configuration

Configure pull-through cache to cache images from upstream registries:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Enable pull-through cache
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

### `image_tag_mutability` - Tag Immutability

Controls whether image tags can be overwritten. Setting to "IMMUTABLE" prevents tags from being overwritten, which is a security best practice.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Prevent image tags from being overwritten
  image_tag_mutability = "IMMUTABLE"  # Requires users to create new tags rather than overwrite
}
```

### `encryption_type` - Repository Encryption

Controls how images are encrypted at rest. For sensitive workloads, KMS encryption provides enhanced security.

```hcl
# Example 1: Default AES256 encryption
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  encryption_type = "AES256"  # AWS-managed encryption (default)
}

# Example 2: KMS encryption with auto-created key
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend-secure"
  
  encryption_type = "KMS"  # Module will create a KMS key
}

# Example 3: KMS encryption with custom key
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend-secure"
  
  encryption_type = "KMS"
  kms_key         = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-1234-1234-1234-123456789abc"
}
```

### `prevent_destroy` - Deletion Protection

Protects the repository from accidental deletion through Terraform. This is a safety feature recommended for production repositories.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "production-backend"
  
  prevent_destroy = true  # Repository cannot be destroyed by Terraform without first changing this to false
}
```

### `force_delete` - Force Repository Deletion

When set to true, the repository will be deleted even if it contains images. Use with caution as this operation cannot be undone.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "temporary-repo"
  
  force_delete = true  # Repository will be deleted even if it contains images
}
```

## Policies and Lifecycle Management

### `policy` - Repository Policy

JSON string representing the repository policy. This controls who can access the repository and what actions they can perform.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Allow specific IAM roles to pull images
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPull"
        Effect    = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::123456789012:role/ECSTaskExecutionRole",
            "arn:aws:iam::123456789012:role/KubernetesNodeRole"
          ]
        }
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

### `lifecycle_policy` - Image Lifecycle Management

JSON string representing the lifecycle policy. This controls how images are automatically cleaned up over time.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Complex lifecycle policy with multiple rules
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only 100 dev images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["dev"]
          countType     = "imageCountMoreThan"
          countNumber   = 100
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Keep only 20 feature branch images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["feature"]
          countType     = "imageCountMoreThan"
          countNumber   = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

## Timeouts

### `timeouts` and `timeouts_delete` - Operation Timeouts

Configure how long Terraform will wait for repository operations to complete.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Modern approach using the timeouts object
  timeouts = {
    delete = "60m"  # Wait up to 60 minutes for deletion to complete
  }
  
  # Or using the legacy parameter (still supported but deprecated)
  # timeouts_delete = "60m"
}
```

## Logging Configuration

### `enable_logging` and `log_retention_days` - CloudWatch Logging

Enable logging of repository events to CloudWatch Logs and configure log retention.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"
  
  # Enable logging to CloudWatch
  enable_logging     = true
  log_retention_days = 90  # Retain logs for 90 days
}
```

## Complete Example with All Variables

Here's a comprehensive example showing all variables:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  # Basic settings
  name = "production-application"
  
  # Security settings
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "KMS"
  prevent_destroy      = true
  force_delete         = false
  
  # Repository policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::123456789012:role/ECSTaskExecutionRole" }
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
  
  # Lifecycle policy
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = { type = "expire" }
      }
    ]
  })
  
  # Timeouts
  timeouts = {
    delete = "30m"
  }
  
  # Logging
  enable_logging     = true
  log_retention_days = 90
  
  # Cross-region replication
  enable_replication  = true
  replication_regions = ["us-west-2", "eu-west-1"]
  
  # Tags
  tags = {
    Environment = "Production"
    Department  = "Engineering"
    Project     = "MyApp"
    ManagedBy   = "Terraform"
  }
}
```

## Cross-Region Replication Settings

### `enable_replication` - Enable Cross-Region Replication

Enable automatic cross-region replication for disaster recovery and multi-region deployments.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "production-app"
  
  enable_replication = true  # Enable automatic replication
}
```

### `replication_regions` - Target Regions for Replication

Specify the AWS regions where images should be automatically replicated.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "production-app"
  
  enable_replication  = true
  replication_regions = ["us-west-2", "eu-west-1", "ap-southeast-1"]
}
```

**Important Notes:**
- Replication is configured at the registry level (affects all repositories in the account)
- Use immutable tags for consistency across regions
- Additional costs apply for cross-region data transfer

### Complete Replication Example

```hcl
module "ecr_with_replication" {
  source = "lgallard/ecr/aws"
  
  name                 = "global-application"
  image_tag_mutability = "IMMUTABLE"  # Recommended for replication
  scan_on_push         = true
  
  # Enable replication for disaster recovery
  enable_replication  = true
  replication_regions = ["us-west-2", "eu-west-1", "ap-southeast-1"]
  
  # Optional: Use KMS encryption for source repository
  encryption_type = "KMS"
  
  # Enable logging for monitoring
  enable_logging = true
  
  tags = {
    Environment = "Production"
    Application = "GlobalApp"
    Purpose     = "MultiRegion"
  }
}