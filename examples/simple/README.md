# Simple ECR Repository Example

This example demonstrates the basic usage of the terraform-aws-ecr module to create a simple, secure ECR repository with essential security features enabled.

## Use Cases

This simple configuration is perfect for:

- **Getting Started**: First-time users who want a straightforward ECR setup
- **Development Environments**: Basic container registries for development teams
- **Small Projects**: Simple applications that need a secure container registry
- **Learning**: Understanding core ECR features without complexity
- **MVP/Prototypes**: Quick setup for proof-of-concept projects

## Features Demonstrated

### 1. Basic Repository Configuration
- Repository creation with a descriptive name
- Essential security settings configured out-of-the-box

### 2. Security Best Practices
- **Image Tag Mutability**: Set to `IMMUTABLE` to prevent accidental tag overwrites
- **KMS Encryption**: Uses AWS KMS for encryption at rest
- **Vulnerability Scanning**: Enables `scan_on_push` for automatic security scanning

### 3. Safe Operations
- **Force Delete Protection**: Set to `false` to prevent accidental repository deletion
- **Comprehensive Tagging**: Includes ownership, environment, and management metadata

## Architecture

```
┌──────────────┐     ┌─────────────────────────┐     ┌──────────────────┐
│              │     │                         │     │                  │
│  Developer   │────▶│   Simple ECR Repository │────▶│   Development    │
│  Workstation │     │                         │     │   Environment    │
│              │     │   • KMS Encrypted       │     │                  │
└──────────────┘     │   • Immutable Tags      │     └──────────────────┘
                     │   • Scan on Push        │
                     │   • Basic Tagging       │
                     └─────────────────────────┘
```

## Configuration Details

### Repository Settings
- **Name**: `simple-ecr-repo`
- **Tag Mutability**: `IMMUTABLE` - prevents tag overwrites for better security
- **Force Delete**: `false` - protects against accidental deletion
- **Encryption**: KMS encryption enabled for data at rest

### Security Features
- **Vulnerability Scanning**: Automatically scans images when pushed
- **Access Control**: Uses default AWS ECR permissions
- **Encryption**: KMS encryption for enhanced security

### Tagging Strategy
The example includes a comprehensive tagging strategy for:
- **Ownership**: Identifies the responsible team (`DevOps team`)
- **Environment**: Specifies the environment type (`dev`)
- **Management**: Indicates Terraform management
- **Project**: Groups related resources (`ECR`)

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region | string | "us-east-1" | no |

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the planned changes**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Deploy to a different region**:
   ```bash
   terraform apply -var="region=us-west-2"
   ```

4. **Verify the repository**:
   ```bash
   # Get repository details
   aws ecr describe-repositories --repository-names simple-ecr-repo

   # Test image push (requires Docker)
   aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   ```

## Outputs

This example doesn't define explicit outputs, but you can access repository information through the module outputs:

- **Repository URL**: `module.ecr.repository_url`
- **Repository ARN**: `module.ecr.repository_arn`
- **Repository Name**: `module.ecr.repository_name`
- **Registry ID**: `module.ecr.registry_id`

## Testing

This example includes automated tests in `/test/ecr_basic_test.go` that verify:

- Repository creation with correct configuration
- Image tag mutability settings
- Basic repository properties
- AWS API integration

To run the tests:
```bash
cd test
go test -v -run TestEcrBasicCreation
```

## Clean Up

To remove all resources created by this example:
```bash
terraform destroy
```

## Next Steps

After trying this simple example, you might want to explore:

- **Complete Example**: See `../complete/` for advanced features like policies and lifecycle management
- **Lifecycle Policies**: Check `../lifecycle-policies/` for image retention strategies
- **Advanced Tagging**: Explore `../advanced-tagging/` for organizational tagging patterns
- **Security Features**: Review `../enhanced-security/` for additional security controls

## Best Practices Demonstrated

1. **Immutable Tags**: Prevents accidental overwrites and improves deployment reliability
2. **Encryption at Rest**: Uses KMS for enhanced security compliance
3. **Vulnerability Scanning**: Enables early detection of security issues
4. **Comprehensive Tagging**: Facilitates resource management and cost allocation
5. **Safe Defaults**: Conservative settings to prevent accidental data loss
