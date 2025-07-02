# Lifecycle Policies Example

This example demonstrates the various ways to configure lifecycle policies using the terraform-aws-ecr module, showcasing the enhanced lifecycle policy configuration features.

## Features Demonstrated

1. **Template-based Configuration**: Using predefined templates for common scenarios
2. **Helper Variables**: Using individual helper variables for custom configurations
3. **Manual Override**: Using manual JSON policy configuration
4. **Precedence**: How different configuration methods override each other
5. **Real-world Patterns**: Common lifecycle policy patterns for different environments

## Available Templates

### Development Template
- **Purpose**: Optimized for development workflows with frequent pushes and builds
- **Configuration**:
  - Keeps 50 images
  - Expires untagged images after 7 days
  - No tagged image expiry (developers may need old tagged builds)
  - Applies to tag prefixes: `["dev", "feature"]`
- **Best for**: CI/CD pipelines, feature branch testing, development environments

### Production Template
- **Purpose**: Balanced retention and stability for production workloads
- **Configuration**:
  - Keeps 100 images
  - Expires untagged images after 14 days
  - Expires tagged images after 90 days
  - Applies to tag prefixes: `["v", "release", "prod"]`
- **Best for**: Production applications, staging environments, release management

### Cost Optimization Template
- **Purpose**: Aggressive cleanup to minimize storage costs
- **Configuration**:
  - Keeps only 10 images
  - Expires untagged images after 3 days
  - Expires tagged images after 30 days
  - Applies to all images (no tag prefix filtering)
- **Best for**: Test environments, proof-of-concepts, temporary workloads

### Compliance Template
- **Purpose**: Long retention periods for audit and compliance requirements
- **Configuration**:
  - Keeps 200 images
  - Expires untagged images after 30 days
  - Expires tagged images after 365 days (1 year)
  - Applies to tag prefixes: `["v", "release", "audit"]`
- **Best for**: Regulated environments, audit trails, compliance documentation

## Configuration Methods and Examples

### Method 1: Using Templates (Recommended for Common Patterns)

Templates provide tested configurations for common use cases:

```hcl
# Development environment
module "ecr_development" {
  source = "lgallard/ecr/aws"

  name = "my-app-dev"
  lifecycle_policy_template = "development"

  tags = {
    Environment = "Development"
    Purpose     = "CI/CD"
  }
}

# Production environment
module "ecr_production" {
  source = "lgallard/ecr/aws"

  name = "my-app-prod"
  lifecycle_policy_template = "production"

  tags = {
    Environment = "Production"
    Purpose     = "Live Application"
  }
}
```

### Method 2: Using Helper Variables (Recommended for Custom Requirements)

Helper variables provide flexibility while maintaining simplicity:

```hcl
# Custom development configuration
module "ecr_custom_dev" {
  source = "lgallard/ecr/aws"

  name = "my-app-custom-dev"

  # Custom retention settings
  lifecycle_keep_latest_n_images      = 75    # More than standard dev template
  lifecycle_expire_untagged_after_days = 5    # Faster cleanup than standard
  lifecycle_expire_tagged_after_days   = 45   # Some tagged cleanup

  # Custom tag strategy
  lifecycle_tag_prefixes_to_keep = ["dev", "feature", "bugfix", "experimental"]

  tags = {
    Environment = "Development"
    Purpose     = "Custom Workflow"
  }
}

# Cost-conscious staging environment
module "ecr_staging_cost" {
  source = "lgallard/ecr/aws"

  name = "my-app-staging"

  # Aggressive cost optimization
  lifecycle_keep_latest_n_images      = 15
  lifecycle_expire_untagged_after_days = 2
  lifecycle_expire_tagged_after_days   = 14

  # Focus on release candidates
  lifecycle_tag_prefixes_to_keep = ["rc", "staging"]

  tags = {
    Environment = "Staging"
    Purpose     = "Cost Optimized Testing"
  }
}
```

### Method 3: Manual Policy (For Complex Requirements)

Manual JSON policies provide maximum control:

```hcl
module "ecr_manual_complex" {
  source = "lgallard/ecr/aws"

  name = "my-app-complex"

  # Complex multi-rule policy
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 5 latest 'latest' tags"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep 50 versioned releases"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 50
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 3
        description  = "Expire untagged after 3 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = {
    Environment = "Production"
    Purpose     = "Complex Lifecycle Management"
  }
}
```

## Configuration Precedence Examples

Understanding how different configuration methods interact:

### Example 1: Manual Policy Overrides Everything
```hcl
module "ecr_precedence_manual" {
  source = "lgallard/ecr/aws"
  name   = "precedence-manual"

  # This manual policy takes precedence over everything below
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manual policy wins"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      }
    ]
  })

  # These are ignored when lifecycle_policy is specified
  lifecycle_policy_template = "production"
  lifecycle_keep_latest_n_images = 100
  lifecycle_expire_untagged_after_days = 30
}
```

### Example 2: Template Overrides Helper Variables
```hcl
module "ecr_precedence_template" {
  source = "lgallard/ecr/aws"
  name   = "precedence-template"

  # Template takes precedence over helper variables
  lifecycle_policy_template = "cost_optimization"

  # These helper variables are ignored when template is specified
  lifecycle_keep_latest_n_images = 100        # Template uses 10
  lifecycle_expire_untagged_after_days = 30   # Template uses 3
}
```

### Example 3: Helper Variables Only
```hcl
module "ecr_precedence_helpers" {
  source = "lgallard/ecr/aws"
  name   = "precedence-helpers"

  # Only helper variables specified - these will be used
  lifecycle_keep_latest_n_images = 50
  lifecycle_expire_untagged_after_days = 10
  lifecycle_tag_prefixes_to_keep = ["main", "stable"]
}
```

## Advanced Patterns and Use Cases

### Multi-Environment Strategy
```hcl
# Development environment with template
module "ecr_dev" {
  source = "lgallard/ecr/aws"
  name   = "myapp-dev"
  lifecycle_policy_template = "development"
}

# Staging with custom settings
module "ecr_staging" {
  source = "lgallard/ecr/aws"
  name   = "myapp-staging"

  lifecycle_keep_latest_n_images      = 30
  lifecycle_expire_untagged_after_days = 5
  lifecycle_tag_prefixes_to_keep      = ["rc", "staging"]
}

# Production with template
module "ecr_prod" {
  source = "lgallard/ecr/aws"
  name   = "myapp-prod"
  lifecycle_policy_template = "production"
}

# Compliance environment
module "ecr_audit" {
  source = "lgallard/ecr/aws"
  name   = "myapp-audit"
  lifecycle_policy_template = "compliance"
}
```

### Tag Strategy Examples
```hcl
# Version-based tag strategy
module "ecr_versioned" {
  source = "lgallard/ecr/aws"
  name   = "versioned-app"

  lifecycle_keep_latest_n_images      = 100
  lifecycle_expire_untagged_after_days = 7
  lifecycle_tag_prefixes_to_keep      = ["v", "release-"]  # v1.0.0, release-2023-01
}

# Branch-based tag strategy
module "ecr_branched" {
  source = "lgallard/ecr/aws"
  name   = "branched-app"

  lifecycle_keep_latest_n_images      = 50
  lifecycle_expire_untagged_after_days = 3
  lifecycle_tag_prefixes_to_keep      = ["main", "develop", "hotfix"]
}

# Environment-based tag strategy
module "ecr_env_tags" {
  source = "lgallard/ecr/aws"
  name   = "env-tagged-app"

  lifecycle_keep_latest_n_images      = 75
  lifecycle_expire_untagged_after_days = 5
  lifecycle_tag_prefixes_to_keep      = ["prod", "staging", "dev"]
}
```

## Testing and Validation

### Policy Preview Testing
Before applying lifecycle policies in production, test them using AWS CLI:

```bash
# Apply the Terraform configuration first
terraform apply

# Then test the policy
aws ecr start-lifecycle-policy-preview --repository-name myapp-dev
aws ecr get-lifecycle-policy-preview --repository-name myapp-dev

# Check what images would be affected
aws ecr describe-images --repository-name myapp-dev
```

### Validation Checklist
- [ ] Verify template names are correct (development, production, cost_optimization, compliance)
- [ ] Check helper variable ranges (images: 1-10000, days: 1-3650)
- [ ] Ensure tag prefixes don't exceed 100 items or 255 characters each
- [ ] Test policy precedence matches expectations
- [ ] Use preview mode to validate behavior before production deployment

## Migration Guide

### From Manual Policies to Enhanced Configuration

1. **Document current policy:**
   ```bash
   aws ecr get-lifecycle-policy --repository-name my-repo > current-policy.json
   ```

2. **Identify equivalent configuration:**
   - Look for common patterns that match available templates
   - Map manual rules to helper variables
   - Consider if manual policy is still necessary for complex cases

3. **Implement gradually:**
   ```hcl
   # Start with closest template
   lifecycle_policy_template = "production"

   # Then customize with helper variables if needed
   lifecycle_keep_latest_n_images = 150  # More than template default
   ```

4. **Test thoroughly:**
   - Use non-production repositories first
   - Leverage policy preview functionality
   - Monitor actual image cleanup behavior

## Running This Example

1. Configure AWS credentials
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the deployment:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```
5. Test policy behavior:
   ```bash
   # For each repository created
   aws ecr start-lifecycle-policy-preview --repository-name <repo-name>
   aws ecr get-lifecycle-policy-preview --repository-name <repo-name>
   ```

## Clean Up

To remove all resources created by this example:
```bash
terraform destroy
```

## Best Practices Summary

1. **Start with templates** for common use cases
2. **Use helper variables** for customization
3. **Reserve manual policies** for complex requirements
4. **Test with preview mode** before production
5. **Consider tag prefix strategy** early in development
6. **Monitor storage costs** and adjust as needed
7. **Document policy decisions** for team understanding
