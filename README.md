![Terraform](https://lgallardo.com/images/terraform.jpg)
# terraform-aws-ecr

Terraform module to create [AWS ECR](https://aws.amazon.com/ecr/) (Elastic Container Registry) which is a fully-managed Docker container registry.

[![Test](https://github.com/lgallard/terraform-aws-ecr/actions/workflows/test.yml/badge.svg)](https://github.com/lgallard/terraform-aws-ecr/actions/workflows/test.yml)

## Architecture

The terraform-aws-ecr module enables several common architectures for container image management.

### Basic ECR Architecture

```
┌──────────────┐     ┌───────────────────────┐     ┌─────────────────┐
│              │     │                       │     │                 │
│  Developer   │────▶│    AWS ECR Registry   │◀────│  CI/CD Pipeline │
│  Workstation │     │                       │     │                 │
│              │     └───────────────────────┘     └─────────────────┘
└──────────────┘               │  ▲
                               │  │
                               ▼  │
                        ┌─────────────────┐
                        │                 │
                        │   ECS / EKS     │
                        │   Services      │
                        │                 │
                        └─────────────────┘
```

For more detailed architecture diagrams including CI/CD integration, multi-region deployments, and security controls, see [docs/diagrams.md](docs/diagrams.md).

## Submodules

This module is organized with specialized submodules for better maintainability and reusability:

### KMS Module (`modules/kms/`)
Manages KMS encryption keys for ECR repositories with advanced key policies, rotation, and access control.

### Pull-Through Cache Module (`modules/pull-through-cache/`)
Manages pull-through cache rules and associated IAM resources for upstream registry integration. Supports multiple upstream registries including Docker Hub, Quay.io, GitHub Container Registry, and Amazon ECR Public.

**Key Benefits of Submodule Architecture:**
- **Separation of Concerns** - Each submodule focuses on a specific functionality
- **Optional Components** - Use only the features you need
- **Easier Maintenance** - Isolated testing and development
- **Reusability** - Submodules can be used independently in other projects

## Versioning

This module follows [Semantic Versioning](https://semver.org/) principles. For full details on the versioning scheme, release process, and compatibility guarantees, see the following documentation:

- [VERSIONING.md](VERSIONING.md) - Details on the semantic versioning scheme and release process
- [VERSION_COMPATIBILITY.md](VERSION_COMPATIBILITY.md) - Terraform and AWS provider compatibility matrix

## Usage
You can use this module to create an ECR registry using few parameters (simple example) or define in detail every aspect of the registry (complete example).

Check the [examples](examples/) directory for examples including:
- **Simple** - Basic ECR repository with minimal configuration
- **Complete** - Full-featured ECR repository with all options
- **Protected** - Repository with deletion protection
- **With ECS Integration** - ECR configured for use with ECS
- **Multi-Region** - Repository configured for cross-region replication (manual and automatic approaches)
- **Replication** - ECR repository with built-in cross-region replication support
- **Advanced Tagging** - Comprehensive tagging strategies with templates, validation, and normalization
- **Enhanced Security** - Advanced security features with scanning and compliance
- **Lifecycle Policies** - Image lifecycle management with predefined templates
- **Pull Request Rules** - Governance and approval workflows for container images
- **Enhanced KMS** - Advanced KMS key configuration with custom policies and access control
- **Pull-Through Cache** - Cached access to upstream registries (Docker Hub, Quay, GitHub, etc.)

### Simple example
This example creates an ECR registry using few parameters

```hcl
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

### Complete example with logging
In this example, the registry is defined in detail including CloudWatch logging:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name                 = "ecr-repo-dev"
  scan_on_push        = true
  image_tag_mutability = "IMMUTABLE"
  encryption_type     = "KMS"

  # Enable CloudWatch logging
  enable_logging     = true
  log_retention_days = 14

  // ...rest of configuration...
}
```

### CloudWatch Logging

The module supports sending ECR API actions and image push/pull events to CloudWatch Logs. When enabled:

- Creates a CloudWatch Log Group `/aws/ecr/{repository-name}`
- Sets up necessary IAM roles and policies for ECR to write logs
- Configurable log retention period (default: 30 days)

To enable logging:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name           = "ecr-repo-dev"
  enable_logging = true

  # Optional: customize retention period (in days)
  log_retention_days = 14  # Valid values: 0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1827,3653
}
```

The module outputs logging-related ARNs:
- `cloudwatch_log_group_arn` - The ARN of the CloudWatch Log Group
- `logging_role_arn` - The ARN of the IAM role used for logging

### CloudWatch Monitoring and Alerting

The module provides comprehensive CloudWatch monitoring with metric alarms and SNS notifications for proactive repository management. When enabled:

- Creates CloudWatch metric alarms for key ECR metrics
- Monitors storage usage, API calls, and security findings
- Sends notifications via SNS for alarm state changes
- Provides visibility into repository usage and costs

#### Basic Monitoring Setup

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name              = "monitored-app"
  enable_monitoring = true

  # Configure monitoring thresholds
  monitoring_threshold_storage         = 10    # GB
  monitoring_threshold_api_calls       = 1000  # calls per minute
  monitoring_threshold_security_findings = 5   # findings count

  # Create SNS topic for notifications
  create_sns_topic      = true
  sns_topic_name        = "ecr-alerts"
  sns_topic_subscribers = ["admin@company.com", "devops@company.com"]
}
```

#### Monitoring Features

**CloudWatch Alarms Created:**
- **Storage Usage**: Monitors repository size in GB
- **API Call Volume**: Monitors API operations per minute
- **Image Push Count**: Monitors push frequency (10 pushes per 5 minutes)
- **Image Pull Count**: Monitors pull frequency (100 pulls per 5 minutes)
- **Security Findings**: Monitors vulnerability count (requires enhanced scanning)

**SNS Integration:**
- Automatic SNS topic creation with configurable name
- Email subscriptions for immediate notifications
- Alarm and OK state notifications
- Support for existing SNS topics

#### Advanced Monitoring Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "production-app"

  # Enable monitoring with custom thresholds
  enable_monitoring                    = true
  monitoring_threshold_storage         = 50    # 50 GB threshold
  monitoring_threshold_api_calls       = 2000  # 2000 calls/minute
  monitoring_threshold_security_findings = 0   # Zero tolerance for vulnerabilities

  # Use existing SNS topic
  create_sns_topic = false
  sns_topic_name   = "existing-alerts-topic"

  # Enable enhanced scanning for security monitoring
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true
}
```

**Monitoring Outputs:**
- `monitoring_status` - Complete monitoring configuration status
- `sns_topic_arn` - ARN of the SNS topic (if created)
- `cloudwatch_alarms` - Details of all created CloudWatch alarms

**Cost Considerations:**
- CloudWatch alarms: $0.10 per alarm per month
- SNS notifications: First 1,000 emails free, then $0.75 per 1,000
- No additional charges for metrics collection

### Cross-Region Replication

The module now supports automatic cross-region replication for disaster recovery and multi-region deployments. When enabled, images are automatically replicated to specified regions whenever they are pushed to the primary repository.

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-application"

  # Enable cross-region replication
  enable_replication  = true
  replication_regions = ["us-west-2", "eu-west-1", "ap-southeast-1"]

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

**Key Benefits:**
- **Disaster Recovery** - Images remain available if a region becomes unavailable
- **Reduced Latency** - Pull images from the nearest region
- **High Availability** - Improved resilience for multi-region workloads
- **Automatic Sync** - No manual intervention required for replication

**Important Notes:**
- Replication is configured at the registry level (affects all repositories in the account)
- Use immutable tags (`image_tag_mutability = "IMMUTABLE"`) for consistency across regions
- Additional costs apply for cross-region data transfer and storage
- Replication is one-way from the source region to destination regions

The module provides replication-related outputs:
- `replication_status` - Overall replication configuration status
- `replication_regions` - List of destination regions
- `replication_configuration_arn` - ARN of the replication configuration

For more detailed examples, see the [replication example](examples/replication/) and [multi-region example](examples/multi-region/).

### Complete example
In this example the register is defined in detailed.

```
module "ecr" {

  source = "lgallard/ecr/aws"

  name                 = "ecr-repo-dev"
  scan_on_push         = true
  image_tag_mutability = "MUTABLE"
  prevent_destroy      = true  # Protect repository from accidental deletion


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

### Deleting ECR Repositories Protected with prevent_destroy

By default, ECR repositories created by this module have `prevent_destroy = true` set in their lifecycle configuration to prevent accidental deletion. When you need to remove a repository:

1. Set the `prevent_destroy` parameter to `false` for the module:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "ecr-repo-dev"
  prevent_destroy = false  # Allow repository to be destroyed
}
```

2. Apply the configuration change:

```bash
terraform apply
```

3. After successful apply, run destroy as normal:

```bash
terraform destroy
```

This approach allows protecting repositories by default while providing a controlled way to remove them when needed.

## Advanced Tagging Configuration

The module provides comprehensive tagging strategies to support better resource management, cost allocation, and organizational compliance. These features enable consistent, validated, and normalized tagging across all ECR resources while maintaining full backward compatibility.

### Key Features

- **Default Tag Templates**: Predefined organizational tag standards for common scenarios
- **Tag Validation**: Ensure required tags are present and follow naming conventions
- **Tag Normalization**: Consistent casing and format across all resources
- **Cost Allocation**: Specialized tags for financial tracking and reporting
- **Compliance**: Tags required for security and regulatory frameworks
- **Backward Compatible**: All advanced features are opt-in

### Default Tag Templates

The module provides four predefined templates for common organizational needs:

#### Basic Template
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable basic organizational tagging
  enable_default_tags = true
  default_tags_template = "basic"
  default_tags_environment = "production"
  default_tags_owner = "platform-team"
  default_tags_project = "user-service"
}
```

**Applied tags**: `CreatedBy`, `ManagedBy`, `Environment`, `Owner`, `Project`

#### Cost Allocation Template
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable cost allocation tagging
  enable_default_tags = true
  default_tags_template = "cost_allocation"
  default_tags_environment = "production"
  default_tags_owner = "platform-team"
  default_tags_project = "user-service"
  default_tags_cost_center = "engineering-cc-001"
}
```

**Applied tags**: All basic tags plus `CostCenter`, `BillingProject`, `ResourceType`, `Service`, `Billable`

#### Compliance Template
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable compliance tagging
  enable_default_tags = true
  default_tags_template = "compliance"
  default_tags_environment = "production"
  default_tags_owner = "security-team"
  default_tags_project = "payment-service"
  default_tags_cost_center = "security-cc-002"
}
```

**Applied tags**: All cost allocation tags plus `DataClass`, `Compliance`, `BackupRequired`, `MonitoringLevel`, `SecurityReview`

#### SDLC Template
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable SDLC tagging
  enable_default_tags = true
  default_tags_template = "sdlc"
  default_tags_environment = "development"
  default_tags_owner = "dev-team"
  default_tags_project = "mobile-app"
}
```

**Applied tags**: Basic organizational tags plus `Application`, `Version`, `DeploymentStage`, `LifecycleStage`, `MaintenanceWindow`

### Tag Validation and Compliance

Ensure organizational compliance by validating that required tags are present:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable tag validation
  enable_tag_validation = true
  required_tags = [
    "Environment",
    "Owner",
    "Project",
    "CostCenter"
  ]

  # This will fail if any required tags are missing
  default_tags_environment = "production"
  default_tags_owner = "platform-team"
  default_tags_project = "user-service"
  default_tags_cost_center = "eng-001"
}
```

### Tag Normalization

Ensure consistent tag formatting across all resources:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable tag normalization
  enable_tag_normalization = true
  tag_key_case = "PascalCase"  # Options: PascalCase, camelCase, snake_case, kebab-case
  normalize_tag_values = true

  tags = {
    "cost-center" = "  engineering-001  "  # Will be normalized to "CostCenter" = "engineering-001"
    "data_class"  = "internal"             # Will be normalized to "DataClass" = "internal"
  }
}
```

### Custom Default Tags

Configure custom default tags without using templates:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Enable custom default tags
  enable_default_tags = true
  default_tags_template = null  # Use custom configuration
  default_tags_environment = "staging"
  default_tags_owner = "full-stack-team"
  default_tags_project = "analytics-service"
  default_tags_cost_center = "data-cc-003"

  # Additional custom tags
  tags = {
    team_slack = "analytics-team"
    oncall_rotation = "analytics-oncall"
  }
}
```

### Legacy Compatibility

Disable advanced tagging features for backward compatibility:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Disable advanced tagging features
  enable_default_tags = false
  enable_tag_validation = false
  enable_tag_normalization = false

  # Traditional manual tagging
  tags = {
    Environment = "production"
    Owner = "legacy-team"
    ManagedBy = "Terraform"
  }
}
```

### Tagging Best Practices

1. **Start with Templates**: Use predefined templates that match your organizational needs
2. **Enable Validation**: Enforce required tags for compliance and consistency
3. **Normalize Consistently**: Choose a casing strategy and apply it across all resources
4. **Plan for Cost Allocation**: Include cost center and billing project tags early
5. **Consider Compliance**: Include data classification and security review tags for regulated environments
6. **Monitor Tag Drift**: Use the validation and normalization features to maintain consistency

For comprehensive examples demonstrating different tagging strategies, see [examples/advanced-tagging](examples/advanced-tagging/).

## Enhanced Lifecycle Policy Configuration

The module provides enhanced lifecycle policy configuration through helper variables and predefined templates, making it easier to implement common lifecycle patterns without writing complex JSON. This feature significantly simplifies ECR image lifecycle management while maintaining full backwards compatibility.

### Configuration Methods

There are three ways to configure lifecycle policies, listed in order of precedence:

1. **Manual JSON Policy** (`lifecycle_policy`) - Highest precedence, full control
2. **Predefined Templates** (`lifecycle_policy_template`) - Medium precedence, common patterns
3. **Helper Variables** - Lowest precedence, individual settings

**🚨 Important: Configuration Precedence Rules**

- When `lifecycle_policy` is specified, ALL template and helper variable settings are ignored
- When `lifecycle_policy_template` is specified, ALL helper variable settings are ignored
- Only helper variables are used when neither `lifecycle_policy` nor `lifecycle_policy_template` are specified
- **AWS ECR Limitations**: Maximum 25 rules per policy, rule priorities must be unique (1-999), up to 100 tag prefixes per rule

For complete AWS ECR lifecycle policy documentation and examples, see [AWS ECR Lifecycle Policy Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html).

### Helper Variables

Configure lifecycle policies using individual helper variables for maximum flexibility:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name = "my-app"

  # Keep only the latest 30 images (range: 1-10000)
  lifecycle_keep_latest_n_images = 30

  # Delete untagged images after 7 days (range: 1-3650)
  lifecycle_expire_untagged_after_days = 7

  # Delete tagged images after 90 days (range: 1-3650)
  lifecycle_expire_tagged_after_days = 90

  # Apply rules only to specific tag prefixes (optional)
  lifecycle_tag_prefixes_to_keep = ["v", "release", "prod"]
}
```

#### Helper Variable Details

- **`lifecycle_keep_latest_n_images`**: Controls how many of the most recent images to retain. When combined with `lifecycle_tag_prefixes_to_keep`, only applies to images with those tag prefixes.
- **`lifecycle_expire_untagged_after_days`**: Automatically deletes untagged images after the specified number of days.
- **`lifecycle_expire_tagged_after_days`**: Automatically deletes tagged images after the specified number of days.
- **`lifecycle_tag_prefixes_to_keep`**: When specified, limits the `lifecycle_keep_latest_n_images` rule to only images with these tag prefixes. Other lifecycle rules still apply to all images.

### Predefined Templates

Use predefined templates for common scenarios. Each template encapsulates best practices for specific environments:

```hcl
# Development environment - optimized for frequent builds and testing
module "ecr_dev" {
  source = "lgallard/ecr/aws"
  name   = "dev-app"
  lifecycle_policy_template = "development"
}

# Production environment - balanced retention and stability
module "ecr_prod" {
  source = "lgallard/ecr/aws"
  name   = "prod-app"
  lifecycle_policy_template = "production"
}

# Cost optimization - minimal storage costs
module "ecr_cost" {
  source = "lgallard/ecr/aws"
  name   = "test-app"
  lifecycle_policy_template = "cost_optimization"
}

# Compliance - long retention for audit requirements
module "ecr_compliance" {
  source = "lgallard/ecr/aws"
  name   = "audit-app"
  lifecycle_policy_template = "compliance"
}
```

### Available Templates

| Template | Keep Images | Untagged Expiry | Tagged Expiry | Tag Prefixes | Use Case |
|----------|-------------|-----------------|---------------|--------------|----------|
| `development` | 50 | 7 days | - | `["dev", "feature"]` | Development workflows with frequent builds |
| `production` | 100 | 14 days | 90 days | `["v", "release", "prod"]` | Production environments requiring stability |
| `cost_optimization` | 10 | 3 days | 30 days | `[]` (all images) | Test environments with aggressive cost optimization |
| `compliance` | 200 | 30 days | 365 days | `["v", "release", "audit"]` | Compliance environments requiring long retention |

### Configuration Precedence and Examples

The module follows a clear precedence order when multiple configuration methods are specified:

#### 1. Manual Policy (Highest Precedence)
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "custom-app"

  # This manual policy takes precedence over everything else
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Custom rule"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 5
        }
        action = { type = "expire" }
      }
    ]
  })

  # These are ignored when lifecycle_policy is specified
  lifecycle_policy_template = "production"
  lifecycle_keep_latest_n_images = 30
}
```

#### 2. Template Configuration
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "template-app"

  # Template takes precedence over helper variables
  lifecycle_policy_template = "production"

  # These helper variables are ignored when template is specified
  lifecycle_keep_latest_n_images = 30
  lifecycle_expire_untagged_after_days = 5
}
```

#### 3. Helper Variables (Lowest Precedence)
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "helper-app"

  # Only helper variables specified - these will be used
  lifecycle_keep_latest_n_images = 30
  lifecycle_expire_untagged_after_days = 5
  lifecycle_expire_tagged_after_days = 60
  lifecycle_tag_prefixes_to_keep = ["v", "stable"]
}
```

### Advanced Usage Patterns

#### Environment-Specific Configurations
```hcl
# Development with custom retention
module "ecr_dev_custom" {
  source = "lgallard/ecr/aws"
  name   = "dev-custom-app"

  lifecycle_keep_latest_n_images      = 20    # Fewer than default dev template
  lifecycle_expire_untagged_after_days = 3    # Faster cleanup than default
  lifecycle_tag_prefixes_to_keep      = ["dev", "feat", "fix"]
}

# Production with extended retention for releases
module "ecr_prod_extended" {
  source = "lgallard/ecr/aws"
  name   = "prod-extended-app"

  lifecycle_keep_latest_n_images      = 150   # More than default prod template
  lifecycle_expire_untagged_after_days = 21   # Longer than default
  lifecycle_expire_tagged_after_days   = 180  # Extended retention
  lifecycle_tag_prefixes_to_keep      = ["v", "release", "hotfix"]
}
```

#### Cost-Conscious Multi-Environment Setup
```hcl
# Aggressive cleanup for test environments
module "ecr_test" {
  source = "lgallard/ecr/aws"
  name   = "test-app"

  lifecycle_keep_latest_n_images      = 5     # Minimal retention
  lifecycle_expire_untagged_after_days = 1    # Daily cleanup
  lifecycle_expire_tagged_after_days   = 7    # Weekly cleanup
}

# Balanced approach for staging
module "ecr_staging" {
  source = "lgallard/ecr/aws"
  name   = "staging-app"

  lifecycle_policy_template = "development"  # Use template for consistency
}
```

### Best Practices

#### Template Selection Guidelines

- **Use `development`** for: CI/CD environments, feature branch testing, development workflows
- **Use `production`** for: Live applications, staging environments, release candidates
- **Use `cost_optimization`** for: Temporary test environments, proof-of-concepts, experimental workloads
- **Use `compliance`** for: Regulated environments, audit trails, long-term archival needs

#### Custom Configuration Guidelines

1. **Start with a template** that's closest to your needs, then use helper variables if needed
2. **Use tag prefixes** to apply different retention rules to different image types
3. **Monitor storage costs** and adjust retention periods based on usage patterns
4. **Consider compliance requirements** when setting retention periods

#### Tag Prefix Strategy Examples

```hcl
# Strategy 1: Environment-based prefixes
lifecycle_tag_prefixes_to_keep = ["prod", "staging", "release"]

# Strategy 2: Version-based prefixes
lifecycle_tag_prefixes_to_keep = ["v", "release-"]

# Strategy 3: Branch-based prefixes
lifecycle_tag_prefixes_to_keep = ["main", "develop", "hotfix"]

# Strategy 4: Mixed strategy
lifecycle_tag_prefixes_to_keep = ["v", "release", "prod", "stable"]
```

### Validation and Constraints

The module includes built-in validation to prevent common configuration errors:

- **Image count**: Must be between 1 and 10,000
- **Days**: Must be between 1 and 3,650 (10 years)
- **Tag prefixes**: Maximum 100 prefixes, each up to 255 characters
- **Template names**: Must be one of the four predefined templates

### Generated Policy Structure

When using helper variables or templates, the module generates policies with this structure:

1. **Rule 1**: Expire untagged images (if `expire_untagged_after_days` specified)
2. **Rule 2**: Keep latest N images (if `keep_latest_n_images` specified)
3. **Rule 3**: Expire tagged images (if `expire_tagged_after_days` specified)

### Migration from Manual Policies

To migrate from existing manual `lifecycle_policy` to the enhanced configuration:

#### Migration Steps

1. **Analyze Your Current Policy**: Review your existing JSON lifecycle policy to understand the rules.

   ```bash
   # Get current policy from Terraform state
   terraform show | grep -A 20 lifecycle_policy
   ```

2. **Choose Migration Path**:
   - Use a **template** if your policy matches common patterns
   - Use **helper variables** for custom configurations
   - Keep **manual policy** for complex, non-standard rules

3. **Template Migration Example**:
   ```hcl
   # Before (manual policy)
   module "ecr" {
     source = "lgallard/ecr/aws"
     name   = "my-app"

     lifecycle_policy = jsonencode({
       rules = [
         {
           rulePriority = 1
           description  = "Keep last 100 images"
           selection = {
             tagStatus   = "any"
             countType   = "imageCountMoreThan"
             countNumber = 100
           }
           action = { type = "expire" }
         },
         {
           rulePriority = 2
           description  = "Expire untagged after 14 days"
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
   }

   # After (using production template)
   module "ecr" {
     source = "lgallard/ecr/aws"
     name   = "my-app"

     lifecycle_policy_template = "production"  # Matches the pattern above
   }
   ```

4. **Helper Variables Migration Example**:
   ```hcl
   # Before (manual policy)
   lifecycle_policy = jsonencode({
     rules = [
       {
         rulePriority = 1
         description  = "Keep 30 images with specific prefixes"
         selection = {
           tagStatus     = "tagged"
           tagPrefixList = ["v", "release"]
           countType     = "imageCountMoreThan"
           countNumber   = 30
         }
         action = { type = "expire" }
       }
     ]
   })

   # After (using helper variables)
   lifecycle_keep_latest_n_images = 30
   lifecycle_tag_prefixes_to_keep = ["v", "release"]
   ```

5. **Test Migration**: Apply changes in a non-production environment first:
   ```bash
   terraform plan  # Review the changes carefully
   terraform apply # Apply when ready
   ```

6. **Verify Results**: Check that lifecycle policies are correctly applied:
   ```bash
   aws ecr describe-lifecycle-policy --repository-name my-app
   ```

#### Migration Validation

- **Before migration**: Document current retention behavior
- **After migration**: Verify identical behavior with new configuration
- **Monitor**: Watch for unexpected image deletions in the first week

For more complex migration scenarios, see the [migration examples](examples/lifecycle-policies/migration-examples.md).

See the [lifecycle policies example](examples/lifecycle-policies/) for comprehensive usage examples and the [troubleshooting guide](docs/troubleshooting.md) for common issues.

## Pull Request Rules Configuration

The module provides pull request rules functionality to implement governance and approval workflows for container images, similar to pull request approval processes for code repositories. This feature enables organizations to enforce quality control, security validation, and compliance requirements before images are deployed to production.

### Overview

Pull request rules provide:
- **Approval workflows**: Require manual approval for production images
- **Security validation**: Automatic checks for vulnerabilities and compliance
- **CI/CD integration**: Webhook notifications for external systems
- **Governance controls**: Policy-based restrictions on image usage
- **Audit trails**: Complete tracking of image approval workflows

### Basic Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "production-app"

  # Enable pull request rules
  enable_pull_request_rules = true

  # Configure approval requirements
  pull_request_rules = [
    {
      name    = "production-approval"
      type    = "approval"
      enabled = true
      conditions = {
        tag_patterns       = ["prod-*", "release-*"]
        severity_threshold = "HIGH"
      }
      actions = {
        require_approval_count = 2
        notification_topic_arn = "arn:aws:sns:region:account:topic"
      }
    }
  ]
}
```

### Rule Types

#### 1. Approval Rules (`type = "approval"`)
Require manual approval before images can be used in production:

```hcl
{
  name    = "security-approval"
  type    = "approval"
  enabled = true
  conditions = {
    tag_patterns            = ["prod-*", "release-*"]
    severity_threshold      = "HIGH"
    require_scan_completion = true
    allowed_principals      = ["arn:aws:iam::account:role/SecurityTeam"]
  }
  actions = {
    require_approval_count  = 2
    notification_topic_arn  = "arn:aws:sns:region:account:topic"
    block_on_failure       = true
    approval_timeout_hours = 24
  }
}
```

#### 2. Security Scan Rules (`type = "security_scan"`)
Automatically validate images against security criteria:

```hcl
{
  name    = "vulnerability-check"
  type    = "security_scan"
  enabled = true
  conditions = {
    severity_threshold      = "MEDIUM"
    require_scan_completion = true
  }
  actions = {
    notification_topic_arn = "arn:aws:sns:region:account:topic"
    block_on_failure       = true
  }
}
```

#### 3. CI Integration Rules (`type = "ci_integration"`)
Integrate with CI/CD systems through webhooks:

```hcl
{
  name    = "ci-validation"
  type    = "ci_integration"
  enabled = true
  conditions = {
    tag_patterns = ["feature-*", "dev-*"]
  }
  actions = {
    webhook_url      = "https://ci.company.com/webhook/ecr"
    block_on_failure = false
  }
}
```

### Configuration Options

#### Conditions
- `tag_patterns`: List of tag patterns that trigger the rule
- `severity_threshold`: Minimum vulnerability severity (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`)
- `require_scan_completion`: Whether to require completed security scans
- `allowed_principals`: List of IAM principals allowed to interact with approved images

#### Actions
- `require_approval_count`: Number of approvals required (1-10)
- `notification_topic_arn`: SNS topic for notifications
- `webhook_url`: Webhook URL for external integrations
- `block_on_failure`: Whether to block operations on rule failure
- `approval_timeout_hours`: Hours to wait for approval (1-168)

### Approval Workflow

1. **Image Push**: Developer pushes image to ECR repository
2. **Rule Evaluation**: Pull request rules evaluate the image against configured criteria
3. **Notification**: If approval is required, notifications are sent to configured channels
4. **Security Scan**: Automatic vulnerability scanning is performed
5. **Manual Review**: Security team reviews scan results and compliance
6. **Approval**: If acceptable, image is tagged with approval status
7. **Deployment**: Approved images can be deployed to production

### Example: Complete Governance Setup

```hcl
module "ecr_governance" {
  source = "lgallard/ecr/aws"
  name   = "critical-application"

  enable_pull_request_rules = true
  pull_request_rules = [
    # Production approval workflow
    {
      name    = "production-security-approval"
      type    = "approval"
      enabled = true
      conditions = {
        tag_patterns            = ["prod-*", "release-*"]
        severity_threshold      = "HIGH"
        require_scan_completion = true
        allowed_principals = [
          "arn:aws:iam::123456789012:role/SecurityTeam",
          "arn:aws:iam::123456789012:role/ReleaseManagers"
        ]
      }
      actions = {
        require_approval_count  = 3
        notification_topic_arn  = aws_sns_topic.security_alerts.arn
        block_on_failure       = true
        approval_timeout_hours = 48
      }
    },
    # Automatic security validation
    {
      name    = "security-scan-gate"
      type    = "security_scan"
      enabled = true
      conditions = {
        tag_patterns            = ["*"]
        severity_threshold      = "MEDIUM"
        require_scan_completion = true
      }
      actions = {
        notification_topic_arn = aws_sns_topic.security_alerts.arn
        block_on_failure       = true
      }
    },
    # CI/CD integration
    {
      name    = "ci-pipeline-integration"
      type    = "ci_integration"
      enabled = true
      conditions = {
        tag_patterns = ["feature-*", "dev-*", "staging-*"]
      }
      actions = {
        webhook_url      = "https://ci.company.com/webhook/ecr-validation"
        block_on_failure = false
      }
    }
  ]

  # Enhanced security scanning
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true
}
```

### Approval Commands

After implementing pull request rules, use these commands to manage approvals:

```bash
# Check image scan results
aws ecr describe-image-scan-findings \
  --repository-name production-app \
  --image-id imageTag=prod-v1.0.0

# Approve image for production use
aws ecr put-image \
  --repository-name production-app \
  --image-tag prod-v1.0.0 \
  --tag-list Key=ApprovalStatus,Value=approved

# List images with approval status
aws ecr describe-images \
  --repository-name production-app \
  --query 'imageDetails[*].[imageTags[0],imageTagMutability,imageScanFindingsSummary.findings]'
```

### Best Practices

1. **Layered Approach**: Use multiple rule types for comprehensive governance
2. **Graduated Enforcement**: Strict rules for production, flexible for development
3. **Clear Workflows**: Document approval processes and responsibilities
4. **Monitoring**: Set up CloudWatch alarms for rule violations
5. **Regular Reviews**: Periodically review and update rule configurations
6. **Testing**: Test rule configurations in non-production environments first

### Integration with CI/CD

Pull request rules integrate seamlessly with CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Check ECR approval status
  run: |
    STATUS=$(aws ecr describe-images \
      --repository-name $REPO_NAME \
      --image-ids imageTag=$IMAGE_TAG \
      --query 'imageDetails[0].imageTags' \
      --output text | grep -o 'ApprovalStatus.*approved' || echo "not-approved")

    if [[ "$STATUS" != *"approved"* ]]; then
      echo "Image not approved for deployment"
      exit 1
    fi
```

See the [pull request rules example](examples/pull-request-rules/) for a complete implementation guide.

## Security Best Practices

Here are key security best practices for your ECR repositories:

1. **Enable Immutable Tags**: Prevent tags from being overwritten to ensure image integrity.
   ```hcl
   image_tag_mutability = "IMMUTABLE"
   ```

2. **Enable Enhanced Scanning**: Use AWS Inspector for comprehensive vulnerability assessment.
   ```hcl
   enable_registry_scanning = true
   registry_scan_type      = "ENHANCED"
   enable_secret_scanning  = true
   ```

3. **Configure Pull-Through Cache**: Reduce external dependencies and improve performance.
   ```hcl
   enable_pull_through_cache = true
   pull_through_cache_rules = [
     {
       ecr_repository_prefix = "docker-hub"
       upstream_registry_url = "registry-1.docker.io"
     }
   ]
   ```

4. **Enable Basic Scanning**: Automatically scan images for security vulnerabilities (if not using enhanced).
   ```hcl
   scan_on_push = true
   ```

5. **Implement Least Privilege Access**: Use repository policies that grant only necessary permissions.

6. **Enable KMS Encryption**: Use AWS KMS for enhanced encryption of container images.
   ```hcl
   encryption_type = "KMS"
   ```

   For advanced KMS configuration options, see the [Enhanced KMS Configuration](#enhanced-kms-configuration) section below.

7. **Configure Lifecycle Policies**: Automatically clean up old or unused images.

For a comprehensive guide with detailed examples, see [docs/security-best-practices.md](docs/security-best-practices.md).

## Troubleshooting

Common issues and solutions when working with ECR repositories:

| Issue | Solution |
|-------|----------|
| Authentication failures | Re-authenticate with `aws ecr get-login-password` |
| Permission denied errors | Check IAM policies and repository policies |
| Cannot delete repository | Check for `prevent_destroy` setting and set to `false` |
| Image scan failures | Verify supported image format and AWS region |
| Lifecycle policy not working | Check rule syntax and priorities |

For detailed troubleshooting steps, see [docs/troubleshooting.md](docs/troubleshooting.md).

## Enhanced KMS Configuration

This module includes a dedicated KMS submodule that provides enhanced encryption configuration options for ECR repositories. The KMS submodule offers fine-grained control over key policies, rotation settings, and access management.

### Basic KMS Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "my-encrypted-repo"
  encryption_type = "KMS"

  # Enhanced KMS options
  kms_deletion_window_in_days = 14
  kms_enable_key_rotation     = true
  kms_key_rotation_period     = 90

  tags = {
    Environment = "production"
  }
}
```

### Advanced KMS Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "production-app"
  encryption_type = "KMS"

  # Advanced KMS configuration
  kms_deletion_window_in_days = 30
  kms_enable_key_rotation     = true
  kms_key_rotation_period     = 180
  kms_multi_region           = true

  # Access control
  kms_key_administrators = [
    "arn:aws:iam::123456789012:role/KMSAdminRole"
  ]

  kms_key_users = [
    "arn:aws:iam::123456789012:role/ECRAccessRole",
    "arn:aws:iam::123456789012:role/CI-CD-Role"
  ]

  # Custom alias
  kms_alias_name = "production/ecr/my-app"

  # KMS-specific tags
  kms_tags = {
    KeyType      = "ECR-Encryption"
    Rotation     = "180-days"
    MultiRegion  = "true"
  }
}
```

### Custom KMS Policy

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "custom-policy-repo"
  encryption_type = "KMS"

  # Custom policy statements
  kms_custom_policy_statements = [
    {
      sid    = "AllowCrossAccountAccess"
      effect = "Allow"
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::TRUSTED-ACCOUNT:root"]
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      conditions = [
        {
          test     = "StringEquals"
          variable = "kms:ViaService"
          values   = ["ecr.us-east-1.amazonaws.com"]
        }
      ]
    }
  ]
}
```

### KMS Configuration Options

| Feature | Variable | Description |
|---------|----------|-------------|
| **Key Management** | `kms_deletion_window_in_days` | Days before key deletion (7-30) |
| | `kms_enable_key_rotation` | Enable automatic rotation |
| | `kms_key_rotation_period` | Rotation period in days (90-2555) |
| | `kms_multi_region` | Create multi-region key |
| **Access Control** | `kms_key_administrators` | Principals with full key access |
| | `kms_key_users` | Principals with encrypt/decrypt access |
| | `kms_additional_principals` | Additional principals with basic access |
| **Policy Customization** | `kms_custom_policy_statements` | Additional policy statements |
| | `kms_custom_policy` | Complete custom policy JSON |
| **Naming & Tagging** | `kms_alias_name` | Custom alias name |
| | `kms_tags` | KMS-specific tags |

### Benefits of Enhanced KMS Configuration

1. **Granular Access Control**: Define specific roles for key administration and usage
2. **Flexible Rotation**: Configure custom rotation periods for compliance requirements
3. **Multi-Region Support**: Create keys that work across multiple AWS regions
4. **Custom Policies**: Add specific policy statements or use completely custom policies
5. **Enhanced Monitoring**: KMS-specific tags for better cost tracking and compliance
6. **Cross-Account Access**: Secure sharing of encrypted repositories across AWS accounts

### Example: Production Setup

```hcl
module "production_ecr" {
  source = "lgallard/ecr/aws"

  name = "production-microservice"

  # Production-grade KMS encryption
  encryption_type = "KMS"
  kms_deletion_window_in_days = 30  # Longer window for recovery
  kms_enable_key_rotation     = true
  kms_key_rotation_period     = 90   # Quarterly rotation
  kms_multi_region           = true  # Multi-region deployment

  # Role-based access control
  kms_key_administrators = [
    "arn:aws:iam::123456789012:role/ProductionKMSAdmins"
  ]

  kms_key_users = [
    "arn:aws:iam::123456789012:role/ProductionECRAccess",
    "arn:aws:iam::123456789012:role/GitHubActions-Production"
  ]

  # Production tagging strategy
  tags = {
    Environment = "production"
    Application = "microservice"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }

  kms_tags = {
    EncryptionType = "ECR-Production"
    ComplianceLevel = "SOC2"
    BackupRequired = "true"
  }
}
```

For complete examples and advanced use cases, see the [enhanced-kms example](examples/enhanced-kms/).

## Variable Usage Examples

This module offers many configuration options through variables. Here are some examples of common variable configurations:

### Basic Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name   = "my-app-repo"
  tags   = {
    Environment = "Production"
  }
}
```

### Security Settings

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name                 = "secure-repo"
  image_tag_mutability = "IMMUTABLE"    # Prevent tag overwriting
  scan_on_push         = true           # Enable basic vulnerability scanning
  encryption_type      = "KMS"          # Use KMS encryption
  prevent_destroy      = true           # Protect from accidental deletion
}
```

### Enhanced Security Configuration

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name                 = "enhanced-secure-repo"
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "KMS"

  # Enhanced scanning with AWS Inspector
  enable_registry_scanning = true
  registry_scan_type      = "ENHANCED"
  enable_secret_scanning  = true

  # Registry scan filters for high/critical vulnerabilities
  registry_scan_filters = [
    {
      name   = "PACKAGE_VULNERABILITY_SEVERITY"
      values = ["HIGH", "CRITICAL"]
    }
  ]

  # Pull-through cache for Docker Hub
  enable_pull_through_cache = true
  pull_through_cache_rules = [
    {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
    }
  ]
}
```

### Advanced Options

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "advanced-repo"
  force_delete    = false
  enable_logging  = true

  # Set custom timeouts
  timeouts = {
    delete = "45m"
  }
}
```

For detailed examples of all variables with explanations, see [docs/variable-examples.md](docs/variable-examples.md).

## Testing

This module uses [Terratest](https://github.com/gruntwork-io/terratest) for automated testing of the module functionality. The tests validate that the module can correctly:

- Create an ECR repository with basic settings
- Apply repository and lifecycle policies
- Configure KMS encryption
- Set up image tag mutability
- Configure scan on push features

### Running Tests Locally

To run the tests locally, you'll need:

1. [Go](https://golang.org/) 1.16+
2. [Terraform](https://www.terraform.io/) 1.3.0+
3. AWS credentials configured locally

```bash
# Clone the repository
git clone https://github.com/lgallard/terraform-aws-ecr.git
cd terraform-aws-ecr

# Run the tests
cd test
go mod tidy
go test -v
```

For more details on tests, see the [test directory README](test/README.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | ./modules/kms | n/a |
| <a name="module_pull_through_cache"></a> [pull\_through\_cache](#module\_pull\_through\_cache) | ./modules/pull-through-cache | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.pull_request_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.pull_request_rules_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.ecr_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecr_lifecycle_policy.lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_registry_scanning_configuration.scanning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_scanning_configuration) | resource |
| [aws_ecr_replication_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_replication_configuration) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.repo_protected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_role.ecr_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.ecr_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.pull_request_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.ecr_monitoring_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create an SNS topic for CloudWatch alarm notifications. | `bool` | `false` | no |
| <a name="input_default_tags_cost_center"></a> [default\_tags\_cost\_center](#input\_default\_tags\_cost\_center) | Cost center tag value for financial tracking. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_environment"></a> [default\_tags\_environment](#input\_default\_tags\_environment) | Environment tag value applied to all resources. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_owner"></a> [default\_tags\_owner](#input\_default\_tags\_owner) | Owner tag value applied to all resources. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_project"></a> [default\_tags\_project](#input\_default\_tags\_project) | Project tag value applied to all resources. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_template"></a> [default\_tags\_template](#input\_default\_tags\_template) | Predefined default tag template. Options: basic, cost\_allocation, compliance, sdlc. | `string` | `null` | no |
| <a name="input_enable_default_tags"></a> [enable\_default\_tags](#input\_enable\_default\_tags) | Whether to enable automatic default tags for all resources. | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging for the repository. | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Whether to enable CloudWatch monitoring and alerting for the ECR repository. | `bool` | `false` | no |
| <a name="input_enable_pull_request_rules"></a> [enable\_pull\_request\_rules](#input\_enable\_pull\_request\_rules) | Whether to enable pull request rules for enhanced governance and quality control. | `bool` | `false` | no |
| <a name="input_enable_pull_through_cache"></a> [enable\_pull\_through\_cache](#input\_enable\_pull\_through\_cache) | Whether to create pull-through cache rules. | `bool` | `false` | no |
| <a name="input_enable_registry_scanning"></a> [enable\_registry\_scanning](#input\_enable\_registry\_scanning) | Whether to enable enhanced scanning for the ECR registry. | `bool` | `false` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Whether to enable cross-region replication for the ECR registry. | `bool` | `false` | no |
| <a name="input_enable_secret_scanning"></a> [enable\_secret\_scanning](#input\_enable\_secret\_scanning) | Whether to enable secret scanning. Detects secrets in container images. | `bool` | `false` | no |
| <a name="input_enable_tag_normalization"></a> [enable\_tag\_normalization](#input\_enable\_tag\_normalization) | Whether to enable automatic tag normalization. | `bool` | `true` | no |
| <a name="input_enable_tag_validation"></a> [enable\_tag\_validation](#input\_enable\_tag\_validation) | Whether to enable tag validation to ensure compliance with organizational standards. | `bool` | `false` | no |
| <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type) | Repository encryption type. Either KMS or AES256. | `string` | `"AES256"` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to delete the repository even if it contains images. Use with caution. | `bool` | `false` | no |
| <a name="input_image_scanning_configuration"></a> [image\_scanning\_configuration](#input\_image\_scanning\_configuration) | Image scanning configuration block. Set to null to use scan\_on\_push variable. | <pre>object({<br/>    scan_on_push = bool<br/>  })</pre> | `null` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository. Either MUTABLE, IMMUTABLE, IMMUTABLE\_WITH\_EXCLUSION, or MUTABLE\_WITH\_EXCLUSION. | `string` | `"MUTABLE"` | no |
| <a name="input_kms_additional_principals"></a> [kms\_additional\_principals](#input\_kms\_additional\_principals) | List of additional IAM principals (ARNs) to grant KMS key access. | `list(string)` | `[]` | no |
| <a name="input_kms_alias_name"></a> [kms\_alias\_name](#input\_kms\_alias\_name) | Custom alias name for the KMS key (without 'alias/' prefix). | `string` | `null` | no |
| <a name="input_kms_custom_policy"></a> [kms\_custom\_policy](#input\_kms\_custom\_policy) | Complete custom policy JSON for the KMS key. Use with caution. | `string` | `null` | no |
| <a name="input_kms_custom_policy_statements"></a> [kms\_custom\_policy\_statements](#input\_kms\_custom\_policy\_statements) | List of custom policy statements to add to the KMS key policy. | <pre>list(object({<br/>    sid    = optional(string)<br/>    effect = string<br/>    principals = optional(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    }))<br/>    actions   = list(string)<br/>    resources = optional(list(string), ["*"])<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Number of days to wait before deleting the KMS key (7-30 days). | `number` | `7` | no |
| <a name="input_kms_enable_key_rotation"></a> [kms\_enable\_key\_rotation](#input\_kms\_enable\_key\_rotation) | Whether to enable automatic key rotation for the KMS key. | `bool` | `true` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | ARN of existing KMS key for repository encryption. If null, a new key is created. | `string` | `null` | no |
| <a name="input_kms_key_administrators"></a> [kms\_key\_administrators](#input\_kms\_key\_administrators) | List of IAM principals (ARNs) who can administer the KMS key. | `list(string)` | `[]` | no |
| <a name="input_kms_key_rotation_period"></a> [kms\_key\_rotation\_period](#input\_kms\_key\_rotation\_period) | Number of days between automatic key rotations (90-2555 days). | `number` | `null` | no |
| <a name="input_kms_key_users"></a> [kms\_key\_users](#input\_kms\_key\_users) | List of IAM principals (ARNs) who can use the KMS key for crypto operations. | `list(string)` | `[]` | no |
| <a name="input_kms_multi_region"></a> [kms\_multi\_region](#input\_kms\_multi\_region) | Whether to create a multi-region KMS key. | `bool` | `false` | no |
| <a name="input_kms_tags"></a> [kms\_tags](#input\_kms\_tags) | Additional tags specific to KMS resources. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_expire_tagged_after_days"></a> [lifecycle\_expire\_tagged\_after\_days](#input\_lifecycle\_expire\_tagged\_after\_days) | Number of days after which tagged images expire (1-3650). Use with caution. | `number` | `null` | no |
| <a name="input_lifecycle_expire_untagged_after_days"></a> [lifecycle\_expire\_untagged\_after\_days](#input\_lifecycle\_expire\_untagged\_after\_days) | Number of days after which untagged images expire (1-3650). Null to disable. | `number` | `null` | no |
| <a name="input_lifecycle_keep_latest_n_images"></a> [lifecycle\_keep\_latest\_n\_images](#input\_lifecycle\_keep\_latest\_n\_images) | Number of latest images to keep in the repository (1-10000). Null to disable. | `number` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | JSON string representing the lifecycle policy. Takes precedence over helper variables. | `string` | `null` | no |
| <a name="input_lifecycle_policy_template"></a> [lifecycle\_policy\_template](#input\_lifecycle\_policy\_template) | Predefined lifecycle policy template. Options: development, production, cost\_optimization, compliance. | `string` | `null` | no |
| <a name="input_lifecycle_tag_prefixes_to_keep"></a> [lifecycle\_tag\_prefixes\_to\_keep](#input\_lifecycle\_tag\_prefixes\_to\_keep) | List of tag prefixes for keep-latest rule. Empty list applies to all images. Max 100 prefixes. | `list(string)` | `[]` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain ECR logs in CloudWatch. | `number` | `30` | no |
| <a name="input_monitoring_threshold_api_calls"></a> [monitoring\_threshold\_api\_calls](#input\_monitoring\_threshold\_api\_calls) | API call volume threshold per minute to trigger CloudWatch alarm. | `number` | `1000` | no |
| <a name="input_monitoring_threshold_image_pull"></a> [monitoring\_threshold\_image\_pull](#input\_monitoring\_threshold\_image\_pull) | Image pull frequency threshold per 5-minute period to trigger CloudWatch alarm. | `number` | `100` | no |
| <a name="input_monitoring_threshold_image_push"></a> [monitoring\_threshold\_image\_push](#input\_monitoring\_threshold\_image\_push) | Image push frequency threshold per 5-minute period to trigger CloudWatch alarm. | `number` | `10` | no |
| <a name="input_monitoring_threshold_security_findings"></a> [monitoring\_threshold\_security\_findings](#input\_monitoring\_threshold\_security\_findings) | Security findings threshold to trigger CloudWatch alarm. | `number` | `10` | no |
| <a name="input_monitoring_threshold_storage"></a> [monitoring\_threshold\_storage](#input\_monitoring\_threshold\_storage) | Storage usage threshold in GB to trigger CloudWatch alarm. | `number` | `10` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECR repository. This name must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_normalize_tag_values"></a> [normalize\_tag\_values](#input\_normalize\_tag\_values) | Whether to normalize tag values by trimming whitespace. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON string representing the repository policy. If null, no policy is created. | `string` | `null` | no |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Whether to protect the repository from being destroyed via lifecycle prevent\_destroy. | `bool` | `false` | no |
| <a name="input_pull_request_rules"></a> [pull\_request\_rules](#input\_pull\_request\_rules) | List of pull request rule configurations for enhanced governance. | <pre>list(object({<br/>    name    = string<br/>    type    = string<br/>    enabled = bool<br/>    conditions = optional(object({<br/>      tag_patterns            = optional(list(string), [])<br/>      severity_threshold      = optional(string, "MEDIUM")<br/>      require_scan_completion = optional(bool, true)<br/>      allowed_principals      = optional(list(string), [])<br/>    }), {})<br/>    actions = optional(object({<br/>      require_approval_count = optional(number, 1)<br/>      notification_topic_arn = optional(string)<br/>      webhook_url            = optional(string)<br/>      block_on_failure       = optional(bool, true)<br/>      approval_timeout_hours = optional(number, 24)<br/>    }), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#input\_pull\_through\_cache\_rules) | List of pull-through cache rules to create. | <pre>list(object({<br/>    ecr_repository_prefix = string<br/>    upstream_registry_url = string<br/>    credential_arn        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_registry_scan_filters"></a> [registry\_scan\_filters](#input\_registry\_scan\_filters) | List of scan filters for filtering scan results when querying ECR findings. | <pre>list(object({<br/>    name   = string<br/>    values = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_registry_scan_type"></a> [registry\_scan\_type](#input\_registry\_scan\_type) | The type of scanning to configure for the registry. Either BASIC or ENHANCED. | `string` | `"ENHANCED"` | no |
| <a name="input_replication_regions"></a> [replication\_regions](#input\_replication\_regions) | List of AWS regions to replicate ECR images to. | `list(string)` | `[]` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | List of tag keys that are required to be present. Empty list disables validation. | `list(string)` | `[]` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Whether images should be scanned after being pushed to the repository. | `bool` | `true` | no |
| <a name="input_scan_repository_filters"></a> [scan\_repository\_filters](#input\_scan\_repository\_filters) | List of repository filters to apply for registry scanning. Supports wildcards. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the SNS topic to create or use for alarm notifications. | `string` | `null` | no |
| <a name="input_sns_topic_subscribers"></a> [sns\_topic\_subscribers](#input\_sns\_topic\_subscribers) | List of email addresses to subscribe to the SNS topic for alarm notifications. | `list(string)` | `[]` | no |
| <a name="input_tag_key_case"></a> [tag\_key\_case](#input\_tag\_key\_case) | Enforce consistent casing for tag keys. Options: PascalCase, camelCase, snake\_case, kebab-case. | `string` | `"PascalCase"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration for repository operations. Example: { delete = "20m" } | <pre>object({<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applied_tags"></a> [applied\_tags](#output\_applied\_tags) | The final set of tags applied to all resources after normalization and default tag application |
| <a name="output_cloudwatch_alarms"></a> [cloudwatch\_alarms](#output\_cloudwatch\_alarms) | List of CloudWatch alarms created for ECR monitoring |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch Log Group used for ECR logs (if logging is enabled) |
| <a name="output_kms_alias_arn"></a> [kms\_alias\_arn](#output\_kms\_alias\_arn) | The ARN of the KMS alias (if created by this module). |
| <a name="output_kms_configuration"></a> [kms\_configuration](#output\_kms\_configuration) | Complete KMS configuration information. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used for repository encryption. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The globally unique identifier for the KMS key (if created by this module). |
| <a name="output_lifecycle_policy"></a> [lifecycle\_policy](#output\_lifecycle\_policy) | The lifecycle policy JSON applied to the repository (if any) |
| <a name="output_logging_role_arn"></a> [logging\_role\_arn](#output\_logging\_role\_arn) | The ARN of the IAM role used for ECR logging (if logging is enabled) |
| <a name="output_monitoring_status"></a> [monitoring\_status](#output\_monitoring\_status) | Status of CloudWatch monitoring configuration |
| <a name="output_pull_request_rules"></a> [pull\_request\_rules](#output\_pull\_request\_rules) | Information about pull request rules configuration |
| <a name="output_pull_through_cache_role_arn"></a> [pull\_through\_cache\_role\_arn](#output\_pull\_through\_cache\_role\_arn) | The ARN of the IAM role used for pull-through cache operations (if enabled) |
| <a name="output_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#output\_pull\_through\_cache\_rules) | List of pull-through cache rules (if enabled) |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | ID of the ECR registry |
| <a name="output_registry_scan_filters"></a> [registry\_scan\_filters](#output\_registry\_scan\_filters) | The configured scan filters for filtering scan results (e.g., by vulnerability severity) |
| <a name="output_registry_scanning_configuration_arn"></a> [registry\_scanning\_configuration\_arn](#output\_registry\_scanning\_configuration\_arn) | The ARN of the ECR registry scanning configuration (if enhanced scanning is enabled) |
| <a name="output_registry_scanning_status"></a> [registry\_scanning\_status](#output\_registry\_scanning\_status) | Status of ECR registry scanning configuration |
| <a name="output_replication_configuration_arn"></a> [replication\_configuration\_arn](#output\_replication\_configuration\_arn) | The ARN of the ECR replication configuration (if replication is enabled) |
| <a name="output_replication_regions"></a> [replication\_regions](#output\_replication\_regions) | List of regions where ECR images are replicated to (if replication is enabled) |
| <a name="output_replication_status"></a> [replication\_status](#output\_replication\_status) | Status of ECR replication configuration |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the ECR repository |
| <a name="output_repository_policy_exists"></a> [repository\_policy\_exists](#output\_repository\_policy\_exists) | Whether a repository policy exists for this ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Comprehensive security status of the ECR configuration |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic used for ECR monitoring alerts (if created) |
| <a name="output_tag_compliance_status"></a> [tag\_compliance\_status](#output\_tag\_compliance\_status) | Tag compliance and validation status |
| <a name="output_tagging_strategy"></a> [tagging\_strategy](#output\_tagging\_strategy) | Summary of the tagging strategy configuration |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Automation & Feature Discovery

### Automated Feature Discovery System

This module includes an automated feature discovery system that runs weekly to identify new AWS ECR features, deprecations, and bug fixes from the AWS provider. The system uses Claude Code with MCP (Model Context Protocol) servers to analyze provider documentation and automatically create GitHub issues for new functionality.

#### How It Works

1. **Weekly Scanning**: Every Sunday at 00:00 UTC, the system scans the latest AWS provider documentation
2. **MCP Integration**: Uses Terraform and Context7 MCP servers to access up-to-date provider docs
3. **Intelligent Analysis**: Compares provider capabilities with current module implementation
4. **Automated Issues**: Creates categorized GitHub issues for discovered items:
   - 🚀 **New Features** - ECR resources/arguments not yet implemented
   - ⚠️ **Deprecations** - Features being phased out requiring action
   - 🐛 **Bug Fixes** - Important provider fixes affecting the module

#### Feature Discovery Workflow

The discovery process follows this workflow:

```
┌─────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│                 │    │                      │    │                     │
│  Weekly Trigger │───▶│   Claude Code CLI    │───▶│   GitHub Issues     │
│  (GitHub Action)│    │   + MCP Servers      │    │   (Auto-created)    │
│                 │    │                      │    │                     │
└─────────────────┘    └──────────────────────┘    └─────────────────────┘
                                 │
                                 ▼
                       ┌──────────────────────┐
                       │                      │
                       │  Feature Tracking    │
                       │    Database          │
                       │  (.github/tracker/)  │
                       │                      │
                       └──────────────────────┘
```

#### Manual Discovery

You can manually trigger feature discovery:

```bash
# Standard discovery
gh workflow run feature-discovery.yml

# Dry run mode (analyze without creating issues)
gh workflow run feature-discovery.yml -f dry_run=true

# Specific provider version
gh workflow run feature-discovery.yml -f provider_version=5.82.0

# Force full scan
gh workflow run feature-discovery.yml -f force_scan=true
```

#### Discovery Categories

The system identifies and categorizes findings as:

**New Features (`enhancement` label):**
- New ECR resources (`aws_ecr_*`)
- New arguments on existing resources
- New data sources (`data.aws_ecr_*`)
- New lifecycle configurations
- New security/monitoring features

**Deprecations (`deprecation` label):**
- Arguments marked for removal
- Resources being phased out
- Configuration patterns no longer recommended

**Bug Fixes (`bug` label):**
- Provider fixes affecting module functionality
- Performance improvements
- Security patches

#### Issue Templates

Each discovery type uses a structured template:

- **New Features**: Implementation checklist, examples, testing requirements
- **Deprecations**: Migration guidance, timeline, impact assessment
- **Bug Fixes**: Impact analysis, testing strategy, version requirements

#### Feature Tracking

All discoveries are tracked in `.github/feature-tracker/ecr-features.json`:

```json
{
  "metadata": {
    "last_scan": "2025-01-21T00:00:00Z",
    "provider_version": "5.82.0",
    "scan_count": 42
  },
  "current_implementation": {
    "resources": {
      "aws_ecr_repository": {
        "implemented": ["name", "image_tag_mutability", "scan_on_push"],
        "pending": ["force_delete"]
      }
    }
  },
  "discovered_features": {
    "new_resources": {},
    "deprecations": {},
    "bug_fixes": {}
  }
}
```

#### MCP Server Integration

The system leverages Model Context Protocol servers for real-time documentation access:

- **Terraform MCP**: `@modelcontextprotocol/server-terraform@latest`
  - AWS provider resource documentation
  - Argument specifications and examples
  - Version compatibility information

- **Context7 MCP**: `@upstash/context7-mcp@latest`
  - Provider changelogs and release notes
  - Community discussions and best practices
  - Historical change tracking

#### Benefits

- **Stay Current**: Never miss new AWS ECR features
- **Proactive Maintenance**: Identify deprecations before they break
- **Automated Tracking**: Comprehensive feature database
- **Community Value**: Users benefit from latest AWS capabilities
- **Reduced Manual Work**: No need for manual provider monitoring

#### Contributing to Discovery

The system is designed to minimize false positives, but you can help improve accuracy:

1. **Review Auto-Created Issues**: Validate and prioritize discoveries
2. **Update Tracking**: Mark features as implemented when complete
3. **Improve Templates**: Suggest enhancements to issue templates
4. **Report Gaps**: Let us know if the system misses important features

For more details on the discovery system architecture, see `.github/scripts/discovery-prompt.md`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | ./modules/kms | n/a |
| <a name="module_pull_through_cache"></a> [pull\_through\_cache](#module\_pull\_through\_cache) | ./modules/pull-through-cache | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.pull_request_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.pull_request_rules_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.ecr_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecr_lifecycle_policy.lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_registry_scanning_configuration.scanning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_scanning_configuration) | resource |
| [aws_ecr_replication_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_replication_configuration) | resource |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.repo_protected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_role.ecr_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.ecr_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.pull_request_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.ecr_monitoring_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.pull_request_rules_webhook](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create an SNS topic for CloudWatch alarm notifications. | `bool` | `false` | no |
| <a name="input_default_tags_cost_center"></a> [default\_tags\_cost\_center](#input\_default\_tags\_cost\_center) | Cost center tag value for financial tracking. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_environment"></a> [default\_tags\_environment](#input\_default\_tags\_environment) | Environment tag value applied to all resources. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_owner"></a> [default\_tags\_owner](#input\_default\_tags\_owner) | Owner tag value applied to all resources. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_project"></a> [default\_tags\_project](#input\_default\_tags\_project) | Project tag value applied to all resources. Null to disable. | `string` | `null` | no |
| <a name="input_default_tags_template"></a> [default\_tags\_template](#input\_default\_tags\_template) | Predefined default tag template. Options: basic, cost\_allocation, compliance, sdlc. | `string` | `null` | no |
| <a name="input_enable_default_tags"></a> [enable\_default\_tags](#input\_enable\_default\_tags) | Whether to enable automatic default tags for all resources. | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable CloudWatch logging for the repository. | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Whether to enable CloudWatch monitoring and alerting for the ECR repository. | `bool` | `false` | no |
| <a name="input_enable_pull_request_rules"></a> [enable\_pull\_request\_rules](#input\_enable\_pull\_request\_rules) | Whether to enable pull request rules for enhanced governance and quality control. | `bool` | `false` | no |
| <a name="input_enable_pull_through_cache"></a> [enable\_pull\_through\_cache](#input\_enable\_pull\_through\_cache) | Whether to create pull-through cache rules. | `bool` | `false` | no |
| <a name="input_enable_registry_scanning"></a> [enable\_registry\_scanning](#input\_enable\_registry\_scanning) | Whether to enable enhanced scanning for the ECR registry. | `bool` | `false` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Whether to enable cross-region replication for the ECR registry. | `bool` | `false` | no |
| <a name="input_enable_secret_scanning"></a> [enable\_secret\_scanning](#input\_enable\_secret\_scanning) | Whether to enable secret scanning. Detects secrets in container images. | `bool` | `false` | no |
| <a name="input_enable_tag_normalization"></a> [enable\_tag\_normalization](#input\_enable\_tag\_normalization) | Whether to enable automatic tag normalization. | `bool` | `true` | no |
| <a name="input_enable_tag_validation"></a> [enable\_tag\_validation](#input\_enable\_tag\_validation) | Whether to enable tag validation to ensure compliance with organizational standards. | `bool` | `false` | no |
| <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type) | Repository encryption type. Either KMS or AES256. | `string` | `"AES256"` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to delete the repository even if it contains images. Use with caution. | `bool` | `false` | no |
| <a name="input_image_scanning_configuration"></a> [image\_scanning\_configuration](#input\_image\_scanning\_configuration) | Image scanning configuration block. Set to null to use scan\_on\_push variable. | <pre>object({<br/>    scan_on_push = bool<br/>  })</pre> | `null` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository. Either MUTABLE, IMMUTABLE, IMMUTABLE\_WITH\_EXCLUSION, or MUTABLE\_WITH\_EXCLUSION. | `string` | `"MUTABLE"` | no |
| <a name="input_kms_additional_principals"></a> [kms\_additional\_principals](#input\_kms\_additional\_principals) | List of additional IAM principals (ARNs) to grant KMS key access. | `list(string)` | `[]` | no |
| <a name="input_kms_alias_name"></a> [kms\_alias\_name](#input\_kms\_alias\_name) | Custom alias name for the KMS key (without 'alias/' prefix). | `string` | `null` | no |
| <a name="input_kms_custom_policy"></a> [kms\_custom\_policy](#input\_kms\_custom\_policy) | Complete custom policy JSON for the KMS key. Use with caution. | `string` | `null` | no |
| <a name="input_kms_custom_policy_statements"></a> [kms\_custom\_policy\_statements](#input\_kms\_custom\_policy\_statements) | List of custom policy statements to add to the KMS key policy. | <pre>list(object({<br/>    sid    = optional(string)<br/>    effect = string<br/>    principals = optional(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    }))<br/>    actions   = list(string)<br/>    resources = optional(list(string), ["*"])<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Number of days to wait before deleting the KMS key (7-30 days). | `number` | `7` | no |
| <a name="input_kms_enable_key_rotation"></a> [kms\_enable\_key\_rotation](#input\_kms\_enable\_key\_rotation) | Whether to enable automatic key rotation for the KMS key. | `bool` | `true` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | ARN of existing KMS key for repository encryption. If null, a new key is created. | `string` | `null` | no |
| <a name="input_kms_key_administrators"></a> [kms\_key\_administrators](#input\_kms\_key\_administrators) | List of IAM principals (ARNs) who can administer the KMS key. | `list(string)` | `[]` | no |
| <a name="input_kms_key_rotation_period"></a> [kms\_key\_rotation\_period](#input\_kms\_key\_rotation\_period) | Number of days between automatic key rotations (90-2555 days). | `number` | `null` | no |
| <a name="input_kms_key_users"></a> [kms\_key\_users](#input\_kms\_key\_users) | List of IAM principals (ARNs) who can use the KMS key for crypto operations. | `list(string)` | `[]` | no |
| <a name="input_kms_multi_region"></a> [kms\_multi\_region](#input\_kms\_multi\_region) | Whether to create a multi-region KMS key. | `bool` | `false` | no |
| <a name="input_kms_tags"></a> [kms\_tags](#input\_kms\_tags) | Additional tags specific to KMS resources. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_expire_tagged_after_days"></a> [lifecycle\_expire\_tagged\_after\_days](#input\_lifecycle\_expire\_tagged\_after\_days) | Number of days after which tagged images expire (1-3650). Use with caution. | `number` | `null` | no |
| <a name="input_lifecycle_expire_untagged_after_days"></a> [lifecycle\_expire\_untagged\_after\_days](#input\_lifecycle\_expire\_untagged\_after\_days) | Number of days after which untagged images expire (1-3650). Null to disable. | `number` | `null` | no |
| <a name="input_lifecycle_keep_latest_n_images"></a> [lifecycle\_keep\_latest\_n\_images](#input\_lifecycle\_keep\_latest\_n\_images) | Number of latest images to keep in the repository (1-10000). Null to disable. | `number` | `null` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | JSON string representing the lifecycle policy. Takes precedence over helper variables. | `string` | `null` | no |
| <a name="input_lifecycle_policy_template"></a> [lifecycle\_policy\_template](#input\_lifecycle\_policy\_template) | Predefined lifecycle policy template. Options: development, production, cost\_optimization, compliance. | `string` | `null` | no |
| <a name="input_lifecycle_tag_prefixes_to_keep"></a> [lifecycle\_tag\_prefixes\_to\_keep](#input\_lifecycle\_tag\_prefixes\_to\_keep) | List of tag prefixes for keep-latest rule. Empty list applies to all images. Max 100 prefixes. | `list(string)` | `[]` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain ECR logs in CloudWatch. | `number` | `30` | no |
| <a name="input_monitoring_threshold_api_calls"></a> [monitoring\_threshold\_api\_calls](#input\_monitoring\_threshold\_api\_calls) | API call volume threshold per minute to trigger CloudWatch alarm. | `number` | `1000` | no |
| <a name="input_monitoring_threshold_image_pull"></a> [monitoring\_threshold\_image\_pull](#input\_monitoring\_threshold\_image\_pull) | Image pull frequency threshold per 5-minute period to trigger CloudWatch alarm. | `number` | `100` | no |
| <a name="input_monitoring_threshold_image_push"></a> [monitoring\_threshold\_image\_push](#input\_monitoring\_threshold\_image\_push) | Image push frequency threshold per 5-minute period to trigger CloudWatch alarm. | `number` | `10` | no |
| <a name="input_monitoring_threshold_security_findings"></a> [monitoring\_threshold\_security\_findings](#input\_monitoring\_threshold\_security\_findings) | Security findings threshold to trigger CloudWatch alarm. | `number` | `10` | no |
| <a name="input_monitoring_threshold_storage"></a> [monitoring\_threshold\_storage](#input\_monitoring\_threshold\_storage) | Storage usage threshold in GB to trigger CloudWatch alarm. | `number` | `10` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECR repository. This name must be unique within the AWS account and region. | `string` | n/a | yes |
| <a name="input_normalize_tag_values"></a> [normalize\_tag\_values](#input\_normalize\_tag\_values) | Whether to normalize tag values by trimming whitespace. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON string representing the repository policy. If null, no policy is created. | `string` | `null` | no |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Whether to protect the repository from being destroyed via lifecycle prevent\_destroy. | `bool` | `false` | no |
| <a name="input_pull_request_rules"></a> [pull\_request\_rules](#input\_pull\_request\_rules) | List of pull request rule configurations for enhanced governance. | <pre>list(object({<br/>    name    = string<br/>    type    = string<br/>    enabled = bool<br/>    conditions = optional(object({<br/>      tag_patterns            = optional(list(string), [])<br/>      severity_threshold      = optional(string, "MEDIUM")<br/>      require_scan_completion = optional(bool, true)<br/>      allowed_principals      = optional(list(string), [])<br/>    }), {})<br/>    actions = optional(object({<br/>      require_approval_count = optional(number, 1)<br/>      notification_topic_arn = optional(string)<br/>      webhook_url            = optional(string)<br/>      block_on_failure       = optional(bool, true)<br/>      approval_timeout_hours = optional(number, 24)<br/>    }), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#input\_pull\_through\_cache\_rules) | List of pull-through cache rules to create. | <pre>list(object({<br/>    ecr_repository_prefix = string<br/>    upstream_registry_url = string<br/>    credential_arn        = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_registry_scan_filters"></a> [registry\_scan\_filters](#input\_registry\_scan\_filters) | List of scan filters for filtering scan results when querying ECR findings. | <pre>list(object({<br/>    name   = string<br/>    values = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_registry_scan_type"></a> [registry\_scan\_type](#input\_registry\_scan\_type) | The type of scanning to configure for the registry. Either BASIC or ENHANCED. | `string` | `"ENHANCED"` | no |
| <a name="input_replication_regions"></a> [replication\_regions](#input\_replication\_regions) | List of AWS regions to replicate ECR images to. | `list(string)` | `[]` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | List of tag keys that are required to be present. Empty list disables validation. | `list(string)` | `[]` | no |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Whether images should be scanned after being pushed to the repository. | `bool` | `true` | no |
| <a name="input_scan_repository_filters"></a> [scan\_repository\_filters](#input\_scan\_repository\_filters) | List of repository filters to apply for registry scanning. Supports wildcards. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the SNS topic to create or use for alarm notifications. | `string` | `null` | no |
| <a name="input_sns_topic_subscribers"></a> [sns\_topic\_subscribers](#input\_sns\_topic\_subscribers) | List of email addresses to subscribe to the SNS topic for alarm notifications. | `list(string)` | `[]` | no |
| <a name="input_tag_key_case"></a> [tag\_key\_case](#input\_tag\_key\_case) | Enforce consistent casing for tag keys. Options: PascalCase, camelCase, snake\_case, kebab-case. | `string` | `"PascalCase"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeout configuration for repository operations. Example: { delete = "20m" } | <pre>object({<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applied_tags"></a> [applied\_tags](#output\_applied\_tags) | The final set of tags applied to all resources after normalization and default tag application |
| <a name="output_cloudwatch_alarms"></a> [cloudwatch\_alarms](#output\_cloudwatch\_alarms) | List of CloudWatch alarms created for ECR monitoring |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch Log Group used for ECR logs (if logging is enabled) |
| <a name="output_kms_alias_arn"></a> [kms\_alias\_arn](#output\_kms\_alias\_arn) | The ARN of the KMS alias (if created by this module). |
| <a name="output_kms_configuration"></a> [kms\_configuration](#output\_kms\_configuration) | Complete KMS configuration information. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used for repository encryption. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The globally unique identifier for the KMS key (if created by this module). |
| <a name="output_lifecycle_policy"></a> [lifecycle\_policy](#output\_lifecycle\_policy) | The lifecycle policy JSON applied to the repository (if any) |
| <a name="output_logging_role_arn"></a> [logging\_role\_arn](#output\_logging\_role\_arn) | The ARN of the IAM role used for ECR logging (if logging is enabled) |
| <a name="output_monitoring_status"></a> [monitoring\_status](#output\_monitoring\_status) | Status of CloudWatch monitoring configuration |
| <a name="output_pull_request_rules"></a> [pull\_request\_rules](#output\_pull\_request\_rules) | Information about pull request rules configuration |
| <a name="output_pull_through_cache_role_arn"></a> [pull\_through\_cache\_role\_arn](#output\_pull\_through\_cache\_role\_arn) | The ARN of the IAM role used for pull-through cache operations (if enabled) |
| <a name="output_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#output\_pull\_through\_cache\_rules) | List of pull-through cache rules (if enabled) |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | ID of the ECR registry |
| <a name="output_registry_scan_filters"></a> [registry\_scan\_filters](#output\_registry\_scan\_filters) | The configured scan filters for filtering scan results (e.g., by vulnerability severity) |
| <a name="output_registry_scanning_configuration_arn"></a> [registry\_scanning\_configuration\_arn](#output\_registry\_scanning\_configuration\_arn) | The ARN of the ECR registry scanning configuration (if enhanced scanning is enabled) |
| <a name="output_registry_scanning_status"></a> [registry\_scanning\_status](#output\_registry\_scanning\_status) | Status of ECR registry scanning configuration |
| <a name="output_replication_configuration_arn"></a> [replication\_configuration\_arn](#output\_replication\_configuration\_arn) | The ARN of the ECR replication configuration (if replication is enabled) |
| <a name="output_replication_regions"></a> [replication\_regions](#output\_replication\_regions) | List of regions where ECR images are replicated to (if replication is enabled) |
| <a name="output_replication_status"></a> [replication\_status](#output\_replication\_status) | Status of ECR replication configuration |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the ECR repository |
| <a name="output_repository_policy_exists"></a> [repository\_policy\_exists](#output\_repository\_policy\_exists) | Whether a repository policy exists for this ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Comprehensive security status of the ECR configuration |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic used for ECR monitoring alerts (if created) |
| <a name="output_tag_compliance_status"></a> [tag\_compliance\_status](#output\_tag\_compliance\_status) | Tag compliance and validation status |
| <a name="output_tagging_strategy"></a> [tagging\_strategy](#output\_tagging\_strategy) | Summary of the tagging strategy configuration |
<!-- END_TF_DOCS -->
