# Lifecycle Policies Example

This example demonstrates the various ways to configure lifecycle policies using the terraform-aws-ecr module.

## Features Demonstrated

1. **Template-based Configuration**: Using predefined templates for common scenarios
2. **Helper Variables**: Using individual helper variables for custom configurations
3. **Manual Override**: Using manual JSON policy configuration
4. **Precedence**: How different configuration methods override each other

## Available Templates

### Development Template
- Keeps 50 images
- Expires untagged images after 7 days
- Optimized for development workflows with frequent pushes

### Production Template
- Keeps 100 images
- Expires untagged images after 14 days
- Expires tagged images after 90 days
- Focuses on stability and reliability

### Cost Optimization Template
- Keeps only 10 images
- Expires untagged images after 3 days
- Expires tagged images after 30 days
- Aggressive cleanup to minimize storage costs

### Compliance Template
- Keeps 200 images
- Expires untagged images after 30 days
- Expires tagged images after 365 days
- Long retention for audit and compliance requirements

## Usage Examples

### Using a Template
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name = "my-app"
  lifecycle_policy_template = "production"
}
```

### Using Helper Variables
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name = "my-app"
  lifecycle_keep_latest_n_images      = 30
  lifecycle_expire_untagged_after_days = 5
  lifecycle_tag_prefixes_to_keep      = ["v", "release"]
}
```

### Manual Override
```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  
  name = "my-app"
  lifecycle_policy = jsonencode({
    rules = [
      # Custom rules here
    ]
  })
}
```

## Configuration Precedence

1. **Manual `lifecycle_policy`** (highest precedence)
2. **Template `lifecycle_policy_template`**
3. **Helper variables** (lowest precedence)

If multiple configuration methods are specified, the higher precedence method will be used.

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

## Clean Up

To remove all resources created by this example:
```bash
terraform destroy
```