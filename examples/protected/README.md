# Protected ECR Repository Example

This example demonstrates how to create a truly protected ECR repository using both Terraform safeguards and AWS IAM policies.

## Protection Mechanisms

This example implements two levels of protection:

1. **Terraform-level Protection** (`prevent_destroy = true`):
   - Prevents accidental destruction through Terraform operations
   - Useful for preventing accidents in CI/CD pipelines and Terraform workflows

2. **AWS-level Protection** (Repository Policy):
   - Denies `DeleteRepository` and `DeleteRepositoryPolicy` actions to all principals
   - Prevents deletion through AWS Console, AWS CLI, and AWS API
   - Provides true deletion protection at the AWS service level

## Usage

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "ecr-repo-protected"
  prevent_destroy = true  # Terraform-level protection

  # AWS-level protection through repository policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PreventDelete"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:DeleteRepository",
          "ecr:DeleteRepositoryPolicy"
        ]
        Resource = "arn:aws:ecr:${region}:${account_id}:repository/${name}"
      }
    ]
  })
}
```

## Important Notes

The repository is protected by two mechanisms:
1. Terraform's `prevent_destroy` blocks deletion via Terraform
2. Repository policy blocks deletion via any AWS interface

Both protections must be removed in sequence to delete the repository.

## Removing Protection and Deleting the Repository

To delete a protected repository, you must remove both protection mechanisms in the correct order:

### Step 1: Remove AWS IAM Policy Protection

First, remove the repository policy that prevents deletion:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "ecr-repo-protected"
  prevent_destroy = true  # Keep Terraform protection for now
  policy         = null   # Remove the protective policy
}
```

Apply this change:
```bash
terraform apply
```

### Step 2: Remove Terraform Protection

After the IAM policy is removed, update the configuration to remove Terraform's protection:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"

  name            = "ecr-repo-protected"
  prevent_destroy = false  # Remove Terraform protection
  policy         = null    # Keep policy removed
}
```

Apply this change:
```bash
terraform apply
```

### Step 3: Destroy the Repository

Finally, you can destroy the repository:
```bash
terraform destroy
```

Remember: Both protection mechanisms must be removed in this order:
1. Remove IAM policy first (allows AWS-level deletion)
2. Then remove prevent_destroy (allows Terraform deletion)
3. Finally run terraform destroy
