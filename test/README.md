# Terraform validation fixtures

This directory contains Terraform fixture modules used by repository validation.

The GitHub Actions pre-commit workflow initializes each directory under `test/fixtures/*` with `terraform init -backend=false` so Terraform validation can exercise representative module configurations without creating live AWS resources.

## Fixtures

- `fixtures/basic`: Simple ECR repository configuration
- `fixtures/complete`: Full-featured ECR repository configuration with policies and KMS encryption
- `fixtures/advanced-tagging`: Tag normalization and repository-specific tags
- `fixtures/enhanced-security`: Enhanced scanning and security configuration
- `fixtures/lifecycle-policies`: Lifecycle policy coverage
- `fixtures/lifecycle-policies-helper-vars`: Lifecycle policy helper variable coverage
- `fixtures/lifecycle-policies-templates`: Lifecycle policy template coverage
- `fixtures/monitoring`: Monitoring configuration coverage

## Running validation locally

From the repository root:

```bash
terraform fmt -recursive
terraform init -backend=false
for dir in test/fixtures/*/; do
  terraform -chdir="$dir" init -backend=false
  terraform -chdir="$dir" validate
done
pre-commit run --all-files
```

These fixtures are not a Terratest suite and do not require Go dependencies.
