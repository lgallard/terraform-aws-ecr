# ECR Pull Request Rules Example

This example demonstrates how to configure ECR repositories with pull request rules for enhanced governance and quality control.

## Overview

Pull request rules provide approval workflows and validation requirements for container images, similar to pull request approval processes for code repositories. This example shows how to:

- Configure approval requirements for production images
- Set up security scan validation rules
- Integrate with CI/CD workflows through webhooks
- Create notification systems for rule triggers

## Features Demonstrated

### 1. Security Approval Required
- Requires manual approval for production images (`prod-*`, `release-*` tags)
- Enforces high severity threshold for vulnerabilities
- Requires completion of security scans before approval
- Sends notifications when approval is needed

### 2. Security Scan Validation
- Automatically validates all images against security criteria
- Blocks deployment if medium or higher severity vulnerabilities are found
- Provides notifications about scan results

### 3. CI Integration
- Integrates with CI/CD systems through webhooks
- Validates feature and development branches
- Provides flexible enforcement (non-blocking for development)

## Usage

```hcl
module "ecr_with_pr_rules" {
  source = "lgallard/ecr/aws//examples/pull-request-rules"

  repository_name = "my-application"
  environment     = "production"

  notification_emails = [
    "security-team@company.com",
    "devops-team@company.com"
  ]

  ci_webhook_url = "https://ci.company.com/webhook/ecr"
}
```

## Approval Workflow

1. **Image Push**: Developer pushes image to ECR
2. **Automatic Scan**: ECR automatically scans the image for vulnerabilities
3. **Rule Evaluation**: Pull request rules evaluate the image against configured criteria
4. **Notification**: If approval is required, notifications are sent to configured channels
5. **Manual Review**: Security team reviews scan results and image compliance
6. **Approval**: If acceptable, image is tagged with approval status
7. **Deployment**: Approved images can be deployed to production

## Example Commands

After deployment, you can work with the repository using these commands:

```bash
# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-west-2.amazonaws.com

# Build and tag image
docker build -t my-application:latest .
docker tag my-application:latest <account>.dkr.ecr.us-west-2.amazonaws.com/my-application:prod-v1.0.0

# Push image (will trigger pull request rules)
docker push <account>.dkr.ecr.us-west-2.amazonaws.com/my-application:prod-v1.0.0

# After review, approve the image
aws ecr put-image \
  --repository-name my-application \
  --image-tag prod-v1.0.0 \
  --tag-list Key=ApprovalStatus,Value=approved
```

## Security Considerations

- Pull request rules use repository policies to enforce governance
- Approval workflows require proper IAM permissions
- Webhook integrations should use HTTPS and authentication
- Notification topics should have appropriate access controls

## Cost Implications

- CloudWatch Events and Lambda functions incur minimal costs
- SNS notifications are charged per message
- Enhanced security scanning may have additional costs
- Consider using lifecycle policies to manage storage costs

## Customization

The example can be customized by:

- Modifying rule conditions (tag patterns, severity thresholds)
- Adjusting approval requirements (count, timeout)
- Adding additional notification channels
- Implementing custom webhook handlers
- Creating organization-specific rule templates
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.51.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_with_pr_rules"></a> [ecr\_with\_pr\_rules](#module\_ecr\_with\_pr\_rules) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.ecr_approval_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_approval_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_sns_topic.ecr_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_webhook_url"></a> [ci\_webhook\_url](#input\_ci\_webhook\_url) | Webhook URL for CI integration notifications | `string` | `null` | no |
| <a name="input_enable_ci_integration"></a> [enable\_ci\_integration](#input\_enable\_ci\_integration) | Whether to enable CI integration pull request rule | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_notification_emails"></a> [notification\_emails](#input\_notification\_emails) | List of email addresses for notifications | `list(string)` | `[]` | no |
| <a name="input_notification_topic_arn"></a> [notification\_topic\_arn](#input\_notification\_topic\_arn) | SNS topic ARN for notifications. If not provided, a topic will be created. | `string` | `null` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the ECR repository | `string` | `"example-pr-rules-repo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_approval_role_arn"></a> [approval\_role\_arn](#output\_approval\_role\_arn) | ARN of the ECR approval role |
| <a name="output_example_approval_workflow"></a> [example\_approval\_workflow](#output\_example\_approval\_workflow) | Example workflow for approving images |
| <a name="output_example_docker_commands"></a> [example\_docker\_commands](#output\_example\_docker\_commands) | Example Docker commands for working with the repository |
| <a name="output_notification_topic_arn"></a> [notification\_topic\_arn](#output\_notification\_topic\_arn) | SNS topic ARN for notifications |
| <a name="output_pull_request_rules"></a> [pull\_request\_rules](#output\_pull\_request\_rules) | Pull request rules configuration |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
