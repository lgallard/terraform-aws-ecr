# Complete ECR Repository Example

This example demonstrates the full capabilities of the terraform-aws-ecr module by creating multiple ECR repositories with different configurations, showcasing advanced features like repository policies, lifecycle management, logging, and security controls.

## Use Cases

This comprehensive configuration is ideal for:

- **Production Environments**: Enterprise-grade container registries with full security controls
- **Multi-Environment Setups**: Different repository configurations for dev, staging, and production
- **Compliance Requirements**: Repositories with audit logging and strict access controls
- **Advanced Lifecycle Management**: Automated image cleanup and retention policies
- **Team Collaboration**: Shared repositories with fine-grained access permissions
- **Cost Optimization**: Efficient storage management through lifecycle policies

## Features Demonstrated

### 1. Basic Repository with Full Configuration
- **Repository Policies**: Custom IAM policies for fine-grained access control
- **Lifecycle Policies**: Automated image cleanup and retention management
- **CloudWatch Logging**: Comprehensive audit trail for repository activities
- **KMS Encryption**: Enhanced security with customer-managed encryption keys

### 2. Protected Repository (Production-Ready)
- **Immutable Configuration**: Prevents accidental tag overwrites
- **Destroy Protection**: Terraform-level protection against accidental deletion
- **Conditional Access**: Role-based access control with specific IAM conditions
- **Long-term Retention**: Conservative lifecycle policies for production images

### 3. Enhanced Lifecycle Management
- **Helper Variables**: Simplified lifecycle policy configuration using module variables
- **Tag-based Retention**: Intelligent retention based on image tags
- **Development-Friendly**: Policies optimized for development workflows

### 4. Comprehensive Security Controls
- **Multi-layered Access Control**: Repository policies with different permission levels
- **Audit Logging**: CloudWatch integration for compliance and monitoring
- **Encryption at Rest**: KMS encryption for all repositories
- **Vulnerability Scanning**: Automated security scanning on image push

## Architecture

```
┌──────────────────┐     ┌─────────────────────────────────────────┐
│                  │     │           Complete ECR Setup            │
│   Development    │────▶│                                         │
│   Pipeline       │     │  ┌─────────────────┐ ┌─────────────────┐│
│                  │     │  │  Basic Repository│ │Protected Repo   ││
└──────────────────┘     │  │  • Full Policies │ │• Prod Settings  ││
                         │  │  • Lifecycle Mgmt│ │• Access Control ││
┌──────────────────┐     │  │  • Audit Logging │ │• Long Retention ││
│                  │     │  └─────────────────┘ └─────────────────┘│
│   Production     │────▶│                                         │
│   Pipeline       │     │  ┌─────────────────┐                   │
│                  │     │  │Enhanced Lifecycle│                   │
└──────────────────┘     │  │• Helper Variables│                   │
                         │  │• Tag-based Rules │                   │
┌──────────────────┐     │  │• Dev-friendly    │                   │
│                  │     │  └─────────────────┘                   │
│  CloudWatch      │◀────│                                         │
│  Monitoring      │     │         All Encrypted with KMS         │
│                  │     │         Vulnerability Scanning         │
└──────────────────┘     └─────────────────────────────────────────┘
```

## Repository Configurations

### 1. Complete ECR Repository (`complete-ecr-repo`)

**Purpose**: Demonstrates all basic features with custom policies and lifecycle management.

**Key Features**:
- **Extended Deletion Timeout**: 60-minute timeout for safe deletion operations
- **Custom Repository Policy**: Multi-statement policy with different access levels
- **Manual Lifecycle Policy**: JSON-based lifecycle configuration with specific rules
- **CloudWatch Logging**: 14-day log retention for audit purposes

**Use Case**: Production applications requiring custom access patterns and audit trails.

### 2. Protected ECR Repository (`protected-ecr-repo`)

**Purpose**: Maximum security configuration for critical production workloads.

**Key Features**:
- **Terraform Protection**: `prevent_destroy = true` prevents accidental Terraform destruction
- **Conditional Access**: Role-based access control with specific IAM role requirements
- **Conservative Lifecycle**: Keep tagged images for extended periods (100+ years for releases)
- **Short Untagged Retention**: Remove untagged images after 14 days

**Use Case**: Critical production images that require long-term retention and strict access control.

### 3. Enhanced Lifecycle Repository (`enhanced-lifecycle-repo`)

**Purpose**: Demonstrates simplified lifecycle management using module helper variables.

**Key Features**:
- **Helper Variables**: Simplified configuration using `lifecycle_keep_latest_n_images`
- **Tag-based Retention**: Intelligent retention for specific tag prefixes (`v`, `release`, `stable`)
- **Development-Friendly**: Balanced retention suitable for development workflows
- **Quick Cleanup**: 7-day retention for untagged images

**Use Case**: Development and staging environments with automated CI/CD pipelines.

## Configuration Patterns

### Repository Policies

The example demonstrates three types of repository access patterns:

1. **Limited Access**: Read-only operations for general users
2. **Admin Access**: Full repository management for administrative roles
3. **Conditional Access**: Role-based access with specific IAM role requirements

### Lifecycle Policies

Two approaches to lifecycle management:

1. **Manual JSON Configuration**: Full control with custom JSON policies
2. **Helper Variables**: Simplified configuration using module variables

### Tagging Strategies

Comprehensive tagging for:
- **Resource Identification**: Name, Owner, Project
- **Environment Classification**: Development, Production
- **Management Tracking**: Terraform, Lifecycle Policy types
- **Security Classification**: Protected status

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region | string | "us-east-1" | no |
| tags | Additional tags to add to all resources | map(string) | {} | no |

The `tags` variable allows you to add custom tags to all repositories created by this example, which will be merged with the default tags specified in each module configuration.

## Usage

### 1. Basic Deployment

```bash
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Apply all configurations
terraform apply
```

### 2. Custom Region Deployment

```bash
# Deploy to a specific region
terraform apply -var="region=eu-west-1"
```

### 3. Custom Tags Deployment

```bash
# Deploy with additional custom tags
terraform apply -var='tags={"CostCenter":"Engineering","Project":"MyApp","Team":"DevOps"}'
```

### 2. Selective Deployment

Deploy specific repositories:

```bash
# Deploy only the basic repository
terraform apply -target=module.ecr

# Deploy only the protected repository
terraform apply -target=module.ecr_protected

# Deploy only the enhanced lifecycle repository
terraform apply -target=module.ecr_enhanced_lifecycle
```

### 3. Validation and Testing

```bash
# List all created repositories
aws ecr describe-repositories

# Test repository policies
aws ecr get-repository-policy --repository-name complete-ecr-repo

# Check lifecycle policies
aws ecr get-lifecycle-policy --repository-name complete-ecr-repo

# Preview lifecycle policy effects
aws ecr start-lifecycle-policy-preview --repository-name enhanced-lifecycle-repo
aws ecr get-lifecycle-policy-preview --repository-name enhanced-lifecycle-repo

# Test image operations
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
```

## Outputs

The example provides comprehensive outputs for monitoring and integration:

### Basic Repository Outputs
- `repository_url`: ECR repository URL for Docker operations
- `repository_arn`: ARN for IAM policy references
- `repository_name`: Repository name for CLI operations
- `registry_id`: AWS account's registry ID

### Logging Outputs
- `ecr_log_group_arn`: CloudWatch Log Group ARN for monitoring setup
- `ecr_logging_role_arn`: IAM role ARN for logging configuration

### Protected Repository Outputs
- `protected_repository_url`: Protected repository URL
- `protected_repository_arn`: Protected repository ARN
- `protected_repository_name`: Protected repository name

### Enhanced Lifecycle Outputs
- `enhanced_lifecycle_repository_url`: Enhanced repository URL
- `enhanced_lifecycle_repository_arn`: Enhanced repository ARN
- `enhanced_lifecycle_policy`: Generated lifecycle policy JSON

## Testing

This example includes comprehensive automated tests in `/test/ecr_complete_test.go` that verify:

- All repository configurations are created correctly
- Repository policies are applied and accessible
- Lifecycle policies are configured properly
- Image tag mutability settings
- AWS API integration and resource validation

To run the tests:
```bash
cd test
go test -v -run TestEcrCompleteRepository
```

## Advanced Usage Patterns

### 1. Custom Variable Configuration

```bash
# Deploy with custom tags
terraform apply -var='tags={"CostCenter":"Engineering","Project":"MyApp"}'
```

### 2. Environment-Specific Configuration

```bash
# Production deployment
terraform apply -var='environment=production' -var='retention_days=365'

# Development deployment
terraform apply -var='environment=development' -var='retention_days=30'
```

### 3. Integration with CI/CD

The outputs can be used in CI/CD pipelines:

```yaml
# Example GitHub Actions integration
- name: Get ECR Repository URL
  run: |
    REPO_URL=$(terraform output -raw repository_url)
    echo "ECR_REPO_URL=$REPO_URL" >> $GITHUB_ENV
```

## Best Practices Demonstrated

### 1. Security
- **Defense in Depth**: Multiple layers of access control
- **Principle of Least Privilege**: Role-based access patterns
- **Audit Trail**: Comprehensive logging for compliance
- **Encryption**: KMS encryption for data at rest

### 2. Operational Excellence
- **Infrastructure as Code**: Complete Terraform configuration
- **Automated Testing**: Comprehensive test coverage
- **Monitoring Integration**: CloudWatch logging setup
- **Disaster Recovery**: Protected configurations with extended timeouts

### 3. Cost Optimization
- **Lifecycle Management**: Automated cleanup to reduce storage costs
- **Flexible Retention**: Different policies for different use cases
- **Tag-based Management**: Intelligent retention based on image importance

### 4. Reliability
- **Immutable Infrastructure**: Immutable tag settings
- **Protection Mechanisms**: Multiple layers of deletion protection
- **Timeout Configuration**: Extended timeouts for safe operations
- **Error Handling**: Graceful handling of edge cases

## Cleanup

To remove all resources created by this example:

```bash
# Note: Protected repository has prevent_destroy=true
# You may need to remove this setting first or use -target for selective destruction

terraform destroy
```

For the protected repository, you may need to:
1. Remove `prevent_destroy = true` from the configuration
2. Run `terraform apply` to update the state
3. Then run `terraform destroy`

## Related Examples

- **Simple Example**: See `../simple/` for basic ECR setup
- **Lifecycle Policies**: Check `../lifecycle-policies/` for advanced lifecycle management
- **Advanced Tagging**: Explore `../advanced-tagging/` for enterprise tagging strategies
- **Enhanced Security**: Review `../enhanced-security/` for additional security features
- **Monitoring**: See `../monitoring/` for comprehensive monitoring setup

## Migration Path

If migrating from simpler configurations:

1. Start with the basic repository configuration
2. Add repository policies for access control
3. Implement lifecycle policies for cost management
4. Enable logging for compliance requirements
5. Add protection mechanisms for production use

This example serves as a comprehensive reference for production-ready ECR deployments with enterprise-grade features and security controls.
