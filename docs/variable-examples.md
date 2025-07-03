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

## Monitoring and Alerting

### `enable_monitoring` - CloudWatch Monitoring

Enable comprehensive CloudWatch monitoring with metric alarms for ECR repository metrics:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "monitored-application"

  # Enable monitoring
  enable_monitoring = true
  
  # Configure thresholds
  monitoring_threshold_storage         = 10    # Alert when storage exceeds 10 GB
  monitoring_threshold_api_calls       = 1000  # Alert when API calls exceed 1000/minute
  monitoring_threshold_security_findings = 5   # Alert when security findings exceed 5
  
  # Create SNS topic for notifications
  create_sns_topic      = true
  sns_topic_name        = "ecr-alerts"
  sns_topic_subscribers = ["admin@company.com", "devops@company.com"]
}
```

### Monitoring with Existing SNS Topic

Use an existing SNS topic for notifications:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "production-app"

  enable_monitoring = true
  
  # Use existing SNS topic
  create_sns_topic = false
  sns_topic_name   = "existing-alerts-topic"
  
  # Custom thresholds for production
  monitoring_threshold_storage         = 50    # Higher threshold for production
  monitoring_threshold_api_calls       = 2000  # Higher API threshold
  monitoring_threshold_security_findings = 0   # Zero tolerance for vulnerabilities
}
```

### Enhanced Monitoring with Security Scanning

Combine monitoring with enhanced security scanning for comprehensive coverage:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "secure-monitored-app"

  # Enable monitoring
  enable_monitoring                    = true
  monitoring_threshold_storage         = 25
  monitoring_threshold_api_calls       = 1500
  monitoring_threshold_security_findings = 3

  # SNS notifications
  create_sns_topic      = true
  sns_topic_subscribers = ["security@company.com", "devops@company.com"]

  # Enable enhanced scanning for security monitoring
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true

  # Enable logging for audit trail
  enable_logging     = true
  log_retention_days = 90
}
```

### CloudWatch Alarms Created

When monitoring is enabled, the following CloudWatch alarms are automatically created:

| Alarm | Metric | Threshold | Description |
|-------|--------|-----------|-------------|
| Storage Usage | `RepositorySizeInBytes` | Configurable (GB) | Monitors repository storage consumption |
| API Calls | `ApiCallCount` | Configurable (calls/min) | Monitors API operation volume |
| Image Push | `ImagePushCount` | 10 pushes/5min | Monitors push frequency |
| Image Pull | `ImagePullCount` | 100 pulls/5min | Monitors pull frequency |
| Security Findings | `HighSeverityVulnerabilityCount` | Configurable | Monitors vulnerability count (requires enhanced scanning) |

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

### Enhanced Lifecycle Policy Configuration

The module now provides enhanced lifecycle policy configuration through helper variables and predefined templates, making it easier to implement common lifecycle patterns without writing complex JSON.

#### Using Helper Variables

Configure lifecycle policies using individual helper variables for maximum flexibility:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "application-backend"

  # Keep only the latest 30 images
  lifecycle_keep_latest_n_images = 30

  # Delete untagged images after 7 days
  lifecycle_expire_untagged_after_days = 7

  # Delete tagged images after 90 days
  lifecycle_expire_tagged_after_days = 90

  # Apply retention rules only to specific tag prefixes
  lifecycle_tag_prefixes_to_keep = ["v", "release", "prod"]
}
```

#### Using Predefined Templates

Use predefined templates for common scenarios:

```hcl
# Development environment optimized for frequent builds
module "ecr_dev" {
  source = "lgallard/ecr/aws"
  name   = "dev-application"

  lifecycle_policy_template = "development"
  # Keeps 50 images, expires untagged after 7 days
}

# Production environment with longer retention
module "ecr_prod" {
  source = "lgallard/ecr/aws"
  name   = "prod-application"

  lifecycle_policy_template = "production"
  # Keeps 100 images, expires untagged after 14 days, tagged after 90 days
}

# Cost-optimized for minimal storage usage
module "ecr_cost" {
  source = "lgallard/ecr/aws"
  name   = "test-application"

  lifecycle_policy_template = "cost_optimization"
  # Keeps 10 images, expires untagged after 3 days, tagged after 30 days
}

# Compliance environment with long retention
module "ecr_compliance" {
  source = "lgallard/ecr/aws"
  name   = "audit-application"

  lifecycle_policy_template = "compliance"
  # Keeps 200 images, expires untagged after 30 days, tagged after 365 days
}
```

#### Configuration Precedence

When multiple lifecycle policy configurations are provided, they follow this precedence order:

1. **Manual `lifecycle_policy`** (highest) - Overrides all other settings
2. **Template `lifecycle_policy_template`** - Overrides helper variables
3. **Helper variables** (lowest) - Used when no template or manual policy is specified

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "example"

  # Manual policy takes precedence (this will be used)
  lifecycle_policy = jsonencode({
    rules = [{ /* custom rules */ }]
  })

  # These will be ignored since manual policy is provided
  lifecycle_policy_template = "production"
  lifecycle_keep_latest_n_images = 50
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
