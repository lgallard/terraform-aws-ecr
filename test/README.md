# Testing terraform-aws-ecr

This directory contains automated tests for the terraform-aws-ecr module. The tests use [Terratest](https://github.com/gruntwork-io/terratest), a Go library that provides utilities for testing Terraform code.

## Prerequisites

1. [Go](https://golang.org/) (version 1.16 or later)
2. [Terraform](https://www.terraform.io/) (version 1.3.0 or later)
3. AWS credentials configured (via environment variables, shared credentials file, or AWS IAM role)

## Running the Tests

To run all tests:

```bash
cd test
go test -v
```

To run a specific test:

```bash
cd test
go test -v -run TestEcrBasicCreation
```

## Test Structure

The test suite includes the following tests:

1. **Basic Repository Test**: Tests the creation of a simple ECR repository with minimal configuration.
   - Verifies repository creation
   - Checks image tag mutability
   - Validates repository URL and ARN

2. **Complete Repository Test**: Tests the creation of a fully configured ECR repository.
   - Verifies repository creation with all features
   - Validates repository policies
   - Checks lifecycle policies
   - Tests KMS encryption

## Test Fixtures

The test fixtures are located in the `fixtures` directory:

- `fixtures/basic`: A simple ECR repository configuration
- `fixtures/complete`: A full-featured ECR repository configuration with policies and KMS encryption

## AWS Resources

These tests create real AWS resources, which might incur costs. The tests use the `force_delete = true` option to ensure that repositories can be cleaned up even if they contain images.

All resources are tagged with `Test = "true"` for identification and are destroyed after the test completes. However, if a test fails, you may need to manually delete the resources.

## CI/CD Integration

These tests can be run in GitHub Actions using the workflow defined in `.github/workflows/test.yml`.