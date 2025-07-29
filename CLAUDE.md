# Terraform AWS ECR Module - Development Guidelines

## Overview
This document outlines Terraform-specific development guidelines for the terraform-aws-ecr module, focusing on best practices for AWS Elastic Container Registry infrastructure as code.

## Module Structure & Organization

### File Organization
- **main.tf** - Primary ECR resource definitions and locals (1,321 lines)
- **variables.tf** - Input variable definitions with validation (1,009 lines)
- **outputs.tf** - Output value definitions (277 lines)
- **versions.tf** - Provider version constraints
- **modules/kms/** - KMS submodule for ECR encryption key management
- **examples/** - 12 comprehensive example configurations
- **test/** - Go-based Terratest integration tests

### Code Organization Principles
- Group ECR resources logically with dual repository patterns
- Use descriptive locals for complex lifecycle and policy expressions
- Maintain backward compatibility with existing variable names
- Implement conditional resource creation patterns
- Organize KMS encryption as a separate submodule

## Terraform Best Practices

### ECR Resource Creation Patterns
**Use conditional creation for protected vs non-protected repositories:**

```hcl
# Preferred: Conditional repository creation
resource "aws_ecr_repository" "this" {
  count = var.create_repository && !var.repository_read_write_access_arns_enabled ? 1 : 0

  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  lifecycle {
    ignore_changes = [image_scanning_configuration]
  }
}

resource "aws_ecr_repository" "this_with_policy" {
  count = var.create_repository && var.repository_read_write_access_arns_enabled ? 1 : 0

  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}
```

### ECR Lifecycle Management
**Implement template-based lifecycle policies:**

```hcl
# Example: Lifecycle policy with template support
variable "repository_lifecycle_policy" {
  description = "The policy document for repository lifecycle policy"
  type        = string
  default     = ""
}

variable "repository_lifecycle_policy_template_variables" {
  description = "Template variables for lifecycle policy"
  type        = map(string)
  default     = {}
}

locals {
  repository_lifecycle_policy = var.repository_lifecycle_policy != "" ? (
    length(var.repository_lifecycle_policy_template_variables) > 0 ?
    templatefile(var.repository_lifecycle_policy, var.repository_lifecycle_policy_template_variables) :
    var.repository_lifecycle_policy
  ) : ""
}
```

### Advanced Tagging Strategy
**Use sophisticated tagging with normalization and validation:**

```hcl
# Example: Advanced tagging pattern
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "repository_tags" {
  description = "Additional tags for the repository"
  type        = map(string)
  default     = {}
}

locals {
  # Normalize and merge tags
  normalized_tags = merge(
    var.tags,
    var.repository_tags,
    {
      Name = var.repository_name
      Type = "ECR"
    }
  )
}
```

## Testing Requirements

### Terratest Integration
**Use Go-based testing for ECR resources:**

```go
// Example: Basic ECR testing pattern
func TestTerraformECRExample(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/simple",
        Vars: map[string]interface{}{
            "repository_name": fmt.Sprintf("test-repo-%s", random.UniqueId()),
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate ECR repository creation
    repositoryName := terraform.Output(t, terraformOptions, "repository_name")
    assert.NotEmpty(t, repositoryName)
}
```

### Test Coverage Strategy
**Comprehensive testing for ECR functionality:**
- **Create corresponding test files** in `test/` directory
- **Test both protected and non-protected repository patterns**
- **Validate KMS encryption integration**
- **Test lifecycle policies and image scanning**
- **Verify registry scanning and pull-through cache**
- **Test multi-region replication scenarios**

## Security Considerations

### KMS Encryption Best Practices
**Use dedicated KMS submodule for encryption:**

```hcl
# Example: KMS integration pattern
module "kms" {
  count  = var.create_kms_key ? 1 : 0
  source = "./modules/kms"

  alias_name                    = var.kms_key_alias
  deletion_window_in_days       = var.kms_key_deletion_window_in_days
  enable_key_rotation           = var.enable_key_rotation
  kms_key_administrators        = var.kms_key_administrators
  kms_key_service_principals    = var.kms_key_service_principals
  kms_key_source_policy_documents = var.kms_key_source_policy_documents

  tags = local.normalized_tags
}
```

### Image Security Patterns
**Enable comprehensive scanning and security features:**

```hcl
# Example: Security configuration
variable "registry_scan_type" {
  description = "The scanning type for the registry"
  type        = string
  default     = "ENHANCED"

  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.registry_scan_type)
    error_message = "Registry scan type must be either BASIC or ENHANCED."
  }
}

variable "registry_scan_rules" {
  description = "Registry scanning rules"
  type = list(object({
    scan_frequency = string
    filter = list(object({
      filter      = string
      filter_type = string
    }))
  }))
  default = []
}
```

## ECR-Specific Development Patterns

### Dual Repository Management
**Handle both protected and non-protected repositories:**

```hcl
# Pattern: Conditional resource creation based on access requirements
locals {
  should_create_protected_repo = var.create_repository && var.repository_read_write_access_arns_enabled
  should_create_standard_repo  = var.create_repository && !var.repository_read_write_access_arns_enabled
}

resource "aws_ecr_repository" "this" {
  count = local.should_create_standard_repo ? 1 : 0
  # Standard repository configuration
}

resource "aws_ecr_repository" "this_with_policy" {
  count = local.should_create_protected_repo ? 1 : 0
  # Protected repository configuration
}
```

### Multi-Region Replication
**Support cross-region replication patterns:**

```hcl
# Example: Replication configuration
variable "registry_replication_rules" {
  description = "Registry replication rules"
  type = list(object({
    destinations = list(object({
      region      = string
      registry_id = string
    }))
    repository_filters = list(object({
      filter      = string
      filter_type = string
    }))
  }))
  default = []
}

resource "aws_ecr_replication_configuration" "this" {
  count = length(var.registry_replication_rules) > 0 ? 1 : 0

  dynamic "replication_configuration" {
    for_each = var.registry_replication_rules
    content {
      dynamic "rule" {
        for_each = replication_configuration.value.destinations
        content {
          destination {
            region      = rule.value.region
            registry_id = rule.value.registry_id
          }
        }
      }
    }
  }
}
```

### Policy Management
**Implement flexible policy handling:**

```hcl
# Example: Repository policy with template support
variable "repository_policy" {
  description = "The JSON policy document for the repository"
  type        = string
  default     = ""
}

variable "attach_repository_policy" {
  description = "Determines whether a repository policy will be attached"
  type        = bool
  default     = true
}

locals {
  repository_policy = var.repository_policy != "" ? var.repository_policy : (
    var.repository_read_write_access_arns_enabled ?
    templatefile("${path.module}/templates/repository_policy.json.tpl", {
      read_write_access_arns = jsonencode(var.repository_read_write_access_arns)
    }) : ""
  )
}
```

## Development Workflow

### Pre-commit Requirements
- **Run `terraform fmt`** on all modified files
- **Execute `terraform validate`** to ensure syntax correctness
- **Run `go test ./test/...`** for comprehensive testing
- **Validate examples** in `examples/` directory
- **Check KMS submodule** integration if modified
- **Update documentation** for variable or output changes

### ECR-Specific Testing
**Run comprehensive ECR tests:**

```bash
# Run all ECR tests
cd test/
go test -v -timeout 30m

# Run specific test categories
go test -v -timeout 30m -run TestTerraformECRSimple
go test -v -timeout 30m -run TestTerraformECRComplete
go test -v -timeout 30m -run TestTerraformECRSecurity
```

### Release Management
- **Use conventional commit messages** for proper automation
- **Follow semantic versioning** principles
- **DO NOT manually update CHANGELOG.md** - use release-please
- **Test all examples** before releasing

## Common ECR Patterns

### 1. **Conditional Resource Creation**
Use conditional logic for different repository types and features

### 2. **Template-Based Policies**
Support both static and template-based policy documents

### 3. **Comprehensive Tagging**
Implement sophisticated tagging with normalization and validation

### 4. **Security-First Approach**
Default to secure configurations with KMS encryption and scanning

### 5. **Multi-Region Support**
Design for replication and pull-through cache scenarios

### 6. **Lifecycle Management**
Provide flexible lifecycle policy configuration

### 7. **Monitoring Integration**
Include CloudWatch alarms and SNS notifications

### 8. **Backward Compatibility**
Maintain compatibility while adding new features

## Example Configurations

### Simple ECR Repository
```hcl
module "ecr" {
  source = "./terraform-aws-ecr"

  repository_name = "my-app"
  scan_on_push    = true

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Complete ECR with Security
```hcl
module "ecr" {
  source = "./terraform-aws-ecr"

  repository_name                = "my-secure-app"
  create_kms_key                 = true
  kms_key_alias                  = "alias/ecr-my-secure-app"
  enable_registry_scanning       = true
  registry_scan_type             = "ENHANCED"

  repository_lifecycle_policy = file("${path.module}/policies/lifecycle.json")

  tags = {
    Environment = "production"
    Application = "my-secure-app"
    Security    = "enhanced"
  }
}
```

## Provider Version Management

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

## Key Module Features

1. **Dual Repository Pattern** - Protected and non-protected repositories
2. **KMS Encryption Submodule** - Dedicated encryption key management
3. **Advanced Lifecycle Policies** - Template-based and helper variables
4. **Comprehensive Security** - Image scanning, registry scanning, pull-request rules
5. **Multi-Region Support** - Replication and pull-through cache
6. **Monitoring & Alerting** - CloudWatch alarms and SNS notifications
7. **Flexible Tagging** - Sophisticated tagging with normalization
8. **Terratest Integration** - Go-based comprehensive testing
9. **12 Example Configurations** - From simple to advanced use cases
10. **Security-First Design** - Secure defaults with compliance support

*Note: This module focuses on AWS ECR best practices and patterns specific to container registry management.*

---

## Enhanced Claude Code Review

This module now includes enhanced Claude Code Review capabilities that focus on PR changes by default:

### Command Usage
- `codebot` - Hunt mode on PR changes (default)
- `codebot hunt` - Quick bug detection on PR changes
- `codebot analyze` - Deep technical analysis on PR changes
- `codebot security` - Security-focused review on PR changes
- `codebot performance` - Performance optimization review on PR changes
- `codebot review` - Comprehensive review on PR changes

### Scope Options
- Add `--full` to any command to analyze the entire codebase
- Example: `codebot hunt --full` - Hunt for bugs in the entire codebase
- Default behavior (without --full) focuses only on changed files in the PR

This enhancement provides more focused, actionable feedback by analyzing only the files changed in pull requests while maintaining the option for complete codebase analysis when needed.
