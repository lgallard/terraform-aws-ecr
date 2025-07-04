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
