# ECR Troubleshooting Guide

This guide provides solutions for common issues you might encounter when using AWS ECR repositories created with the terraform-aws-ecr module.

## Authentication Issues

### Problem: "Error: Cannot perform an interactive login from a non TTY device"

When attempting to log in to ECR using `aws ecr get-login-password`.

**Solution:**

```bash
# Use this command instead:
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### Problem: "Error: Your authorization token has expired. Reauthenticate and try again."

**Solution:**

ECR login tokens are valid for 12 hours. Re-authenticate:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

## Push/Pull Issues

### Problem: "Error: denied: User is not authorized to perform: ecr:PutImage"

**Solution:**

Check and update the repository policy to include the necessary permissions:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "my-ecr-repo"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPush",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/YourPushRole"
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

### Problem: "Error: pull access denied, repository does not exist or may require docker login"

**Common causes:**
1. Not authenticated to ECR
2. The repository doesn't exist
3. IAM permissions are incorrect

**Solutions:**

1. Verify the repository exists:
```bash
aws ecr describe-repositories --repository-names my-repo-name
```

2. Check IAM permissions:
```bash
aws sts get-caller-identity
```

3. Ensure the user/role has the required permissions:
```bash
"ecr:BatchGetImage",
"ecr:BatchCheckLayerAvailability",
"ecr:GetDownloadUrlForLayer"
```

## Image Scanning Issues

### Problem: "Image scan failed" or missing vulnerability findings

**Solution:**

1. Check if the image format is supported by ECR scanning
2. Verify you're using a supported AWS region for scanning
3. Try a manual scan:

```bash
aws ecr start-image-scan --repository-name my-repo-name --image-id imageTag=latest
```

4. Check scan status:

```bash
aws ecr describe-image-scan-findings --repository-name my-repo-name --image-id imageTag=latest
```

## Lifecycle Policy Issues

### Enhanced Lifecycle Policy Troubleshooting

The module now provides enhanced lifecycle policy configuration. Here are common issues and solutions:

#### Problem: Enhanced lifecycle policy not working as expected

**Common Causes:**
1. Configuration precedence not understood
2. Validation errors in helper variables
3. Template configuration issues
4. AWS policy evaluation timing

**Solutions:**

1. **Check configuration precedence:**
   ```hcl
   # Manual policy overrides everything
   lifecycle_policy = "..." # This takes precedence

   # Template overrides helper variables
   lifecycle_policy_template = "production" # This overrides helper variables below

   # Helper variables (lowest precedence)
   lifecycle_keep_latest_n_images = 30
   ```

2. **Validate helper variable ranges:**
   - `lifecycle_keep_latest_n_images`: Must be 1-10000
   - `lifecycle_expire_untagged_after_days`: Must be 1-3650
   - `lifecycle_expire_tagged_after_days`: Must be 1-3650
   - `lifecycle_tag_prefixes_to_keep`: Max 100 prefixes, 255 chars each

3. **Verify template usage:**
   ```bash
   # Check what policy was actually applied
   aws ecr get-lifecycle-policy --repository-name my-repo-name
   ```

#### Problem: Template not applying the expected policy

**Solution:**

Check what each template includes:

- **development**: 50 images, 7-day untagged expiry, prefixes: `["dev", "feature"]`
- **production**: 100 images, 14-day untagged + 90-day tagged expiry, prefixes: `["v", "release", "prod"]`
- **cost_optimization**: 10 images, 3-day untagged + 30-day tagged expiry, all images
- **compliance**: 200 images, 30-day untagged + 365-day tagged expiry, prefixes: `["v", "release", "audit"]`

#### Problem: Tag prefixes not working correctly

**Solutions:**

1. **Understand tag prefix behavior:**
   ```hcl
   # This only applies keep-latest rule to images with these prefixes
   lifecycle_tag_prefixes_to_keep = ["v", "release"]
   lifecycle_keep_latest_n_images = 30

   # But expiry rules still apply to ALL images
   lifecycle_expire_untagged_after_days = 7
   ```

2. **Test with preview:**
   ```bash
   aws ecr start-lifecycle-policy-preview --repository-name my-repo-name
   aws ecr get-lifecycle-policy-preview --repository-name my-repo-name
   ```

#### Problem: Images not being cleaned up by enhanced lifecycle policy

**Solutions:**

1. **Verify the generated policy:**
   ```bash
   aws ecr get-lifecycle-policy --repository-name my-repo-name
   ```

2. **Check rule priority and conflicts:**
   - Rule 1: Expire untagged images
   - Rule 2: Keep latest N images
   - Rule 3: Expire tagged images

   Higher priority rules (lower numbers) execute first.

3. **Test policy evaluation:**
   ```bash
   # Trigger manual evaluation
   aws ecr start-lifecycle-policy-preview --repository-name my-repo-name

   # Check results after a few minutes
   aws ecr get-lifecycle-policy-preview --repository-name my-repo-name
   ```

4. **Common rule interactions:**
   ```hcl
   # This configuration might not work as expected:
   lifecycle_keep_latest_n_images = 100
   lifecycle_expire_tagged_after_days = 30

   # Because if images are older than 30 days, they'll be expired
   # even if you want to keep 100 latest images
   ```

#### Problem: Policy validation errors during terraform apply

**Solutions:**

1. **Check variable validation:**
   ```hcl
   # Invalid - out of range
   lifecycle_keep_latest_n_images = 15000  # Max is 10000

   # Invalid - out of range
   lifecycle_expire_untagged_after_days = 5000  # Max is 3650

   # Invalid - too many prefixes
   lifecycle_tag_prefixes_to_keep = [/* more than 100 items */]
   ```

2. **Fix template name typos:**
   ```hcl
   # Invalid
   lifecycle_policy_template = "prod"  # Not a valid template

   # Valid
   lifecycle_policy_template = "production"
   ```

#### Problem: Migration from manual policies causing issues

**Solution:**

When migrating from manual `lifecycle_policy`, follow this process:

1. **Document your current policy:**
   ```bash
   aws ecr get-lifecycle-policy --repository-name my-repo-name > current-policy.json
   ```

2. **Choose equivalent configuration:**
   ```hcl
   # Old manual policy
   lifecycle_policy = jsonencode({
     rules = [
       {
         rulePriority = 1
         description  = "Expire untagged after 7 days"
         selection = {
           tagStatus   = "untagged"
           countType   = "sinceImagePushed"
           countUnit   = "days"
           countNumber = 7
         }
         action = { type = "expire" }
       }
     ]
   })

   # Equivalent using helper variables
   lifecycle_expire_untagged_after_days = 7
   ```

3. **Test in non-production first:**
   ```hcl
   # Use preview to verify behavior
   aws ecr start-lifecycle-policy-preview --repository-name test-repo-name
   ```

### Legacy Lifecycle Policy Issues

#### Problem: Images not being cleaned up by lifecycle policy

**Solutions:**

1. Verify policy syntax:

```bash
aws ecr get-lifecycle-policy --repository-name my-repo-name
```

2. Trigger a manual policy evaluation (useful for testing):

```bash
aws ecr start-lifecycle-policy-preview --repository-name my-repo-name
```

3. View the results:

```bash
aws ecr get-lifecycle-policy-preview --repository-name my-repo-name
```

4. Check for overlapping rules - higher priority (lower numbered) rules are applied first

#### Problem: Policy preview shows unexpected results

**Solutions:**

1. **Review rule priorities and interactions:**
   - AWS evaluates rules in priority order (1, 2, 3...)
   - Once an image matches a rule, it's not evaluated by subsequent rules
   - Make sure your rule priorities align with your intent

2. **Check rule specificity:**
   ```json
   {
     "rules": [
       {
         "rulePriority": 1,
         "selection": {
           "tagStatus": "tagged",
           "tagPrefixList": ["prod"],
           "countType": "imageCountMoreThan",
           "countNumber": 10
         },
         "action": { "type": "expire" }
       },
       {
         "rulePriority": 2,
         "selection": {
           "tagStatus": "tagged",
           "countType": "sinceImagePushed",
           "countUnit": "days",
           "countNumber": 30
         },
         "action": { "type": "expire" }
       }
     ]
   }
   ```

3. **Test incrementally:**
   - Start with one rule and verify behavior
   - Add additional rules one at a time
   - Use preview mode extensively before applying

## Encryption Issues

### Problem: "Error when attempting to use KMS encryption"

**Solutions:**

1. Verify KMS key permissions include the IAM roles/users that need to work with ECR:

```hcl
resource "aws_kms_key" "ecr_key" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/YourRole"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*"
      }
    ]
  })
}
```

2. For cross-account usage, ensure the KMS key policy allows access from those accounts

## Protected Repository Issues

### Problem: "Error: Resource aws_ecr_repository.repo_protected has lifecycle.prevent_destroy set"

**Solution:**

When you need to delete a protected repository:

1. First update your configuration to remove the protection:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "my-ecr-repo"

  prevent_destroy = false
}
```

2. Apply the configuration change:

```bash
terraform apply
```

3. After the successful apply, you can destroy the resource:

```bash
terraform destroy
```

## Logging Issues

### Problem: ECR logs not appearing in CloudWatch

**Solutions:**

1. Verify logging is enabled:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  name   = "my-ecr-repo"

  enable_logging = true
}
```

2. Check the IAM role permissions for CloudWatch logging
3. Ensure the log group exists at `/aws/ecr/{repository-name}`

## Terraform-Specific Issues

### Problem: Changes to `prevent_destroy` not taking effect

**Solution:**

The `prevent_destroy` setting controls Terraform's behavior, not an actual AWS setting. To change it:

1. Make a terraform state pull to get the current state
2. Use `terraform state rm` to remove the resource from state
3. Update your configuration with the new `prevent_destroy` value
4. Run `terraform import` to bring the resource back under management with the new setting

### Problem: "Error applying plan: 1 error occurred: aws_ecr_repository.repo: inconsistent values"

**Solution:**

When you get inconsistent values during apply:

1. Check for differences between your configuration and what's in AWS
2. Use `terraform plan -refresh-only` to update Terraform's state with the current AWS configuration
3. Adjust your configuration to match the actual resource or consider using `terraform import` to reset the resource state

## Getting Help

If you're still experiencing issues after trying the solutions in this guide:

1. Check the [AWS ECR documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/common-errors.html)
2. Review CloudTrail logs for detailed error information
3. Open an issue in the [terraform-aws-ecr repository](https://github.com/lgallard/terraform-aws-ecr/issues) with:
   - Detailed error messages
   - Your module configuration (with sensitive information redacted)
   - Terraform version
   - AWS provider version
