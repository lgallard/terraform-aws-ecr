# ECR Repository with Monitoring Example

This example demonstrates how to create an ECR repository with comprehensive CloudWatch monitoring and SNS alerting.

## Features Demonstrated

- **ECR Repository**: Basic ECR repository with security scanning enabled
- **CloudWatch Monitoring**: Comprehensive monitoring with multiple metric alarms
- **SNS Alerting**: Email notifications for alarm triggers
- **Enhanced Security**: Registry scanning with secret detection
- **Cost Optimization**: Production lifecycle policy
- **Custom Dashboard**: CloudWatch dashboard for visual monitoring
- **Activity Monitoring**: Custom alarm for repository inactivity

## Monitoring Features

### CloudWatch Alarms Created

1. **Storage Usage Alarm**: Monitors repository size in GB
2. **API Calls Alarm**: Monitors API call volume per minute
3. **Image Push Alarm**: Monitors image push frequency
4. **Image Pull Alarm**: Monitors image pull frequency
5. **Security Findings Alarm**: Monitors vulnerability count (requires enhanced scanning)
6. **Repository Inactivity Alarm**: Custom alarm for detecting inactive repositories

### SNS Integration

- Creates SNS topic for alert notifications
- Subscribes provided email addresses to the topic
- Sends notifications for alarm state changes

### CloudWatch Dashboard

- Visual dashboard showing key ECR metrics
- Repository size over time
- Push/pull activity
- API call patterns

## Usage

1. **Configure Variables**: Copy `terraform.tfvars.example` to `terraform.tfvars`
2. **Set Email Notifications**: Add your email addresses to `notification_emails`
3. **Deploy**: Run `terraform init && terraform apply`
4. **Confirm Subscriptions**: Check your email for SNS subscription confirmations

## Required Variables

```hcl
notification_emails = [
  "admin@company.com",
  "devops@company.com"
]
```

## Example terraform.tfvars

```hcl
aws_region                     = "us-east-1"
repository_name                = "my-monitored-app"
environment                    = "production"
project_name                   = "my-project"
owner                          = "platform-team"
storage_threshold_gb           = 10
api_calls_threshold            = 1000
security_findings_threshold    = 5
notification_emails            = ["admin@company.com", "devops@company.com"]
```

## Monitoring Thresholds

| Metric | Default Threshold | Description |
|--------|------------------|-------------|
| Storage Usage | 5 GB | Repository size in gigabytes |
| API Calls | 500/minute | API operations per minute |
| Security Findings | 5 | High/Critical vulnerabilities |
| Image Push | 10/5min | Push operations in 5 minutes |
| Image Pull | 100/5min | Pull operations in 5 minutes |
| Repository Inactivity | 1 push/day | Minimum daily activity |

## Post-Deployment

### Viewing Monitoring

1. **CloudWatch Console**: Navigate to CloudWatch alarms to view status
2. **Dashboard**: Access the custom dashboard via the output URL
3. **SNS**: Check SNS topic subscriptions are confirmed

### Testing Alerts

1. **Push Images**: Push large images to test storage thresholds
2. **API Activity**: Generate API calls to test volume thresholds
3. **Security Scanning**: Push vulnerable images to test security alerts

### Managing Notifications

1. **Add Subscribers**: Add more email addresses to SNS topic
2. **Modify Thresholds**: Update alarm thresholds as needed
3. **Disable Alarms**: Set alarm actions to empty list to disable notifications

## Cost Considerations

- CloudWatch alarms: $0.10 per alarm per month
- SNS notifications: First 1,000 email notifications free, then $0.75 per 1,000
- CloudWatch dashboard: Free for up to 3 dashboards
- ECR storage: $0.10 per GB per month

## Security Notes

- Enhanced scanning requires AWS Inspector
- Secret scanning automatically enabled with enhanced mode
- Email subscriptions require confirmation
- SNS topic policies restrict access to AWS services

## Troubleshooting

### Common Issues

1. **SNS Subscription Not Confirmed**: Check email and confirm subscriptions
2. **No Alarm Data**: Ensure repository has activity to generate metrics
3. **Permission Errors**: Verify IAM permissions for CloudWatch and SNS
4. **Threshold Too Low**: Adjust thresholds based on actual usage patterns

### Monitoring Validation

```bash
# Check alarm states
aws cloudwatch describe-alarms --alarm-names "my-app-ecr-storage-usage"

# Test SNS topic
aws sns publish --topic-arn "arn:aws:sns:us-east-1:123456789012:my-app-ecr-alerts" --message "Test message"

# View repository metrics
aws ecr describe-repositories --repository-names my-app
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_with_monitoring"></a> [ecr\_with\_monitoring](#module\_ecr\_with\_monitoring) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.ecr_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.repository_inactivity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_calls_threshold"></a> [api\_calls\_threshold](#input\_api\_calls\_threshold) | API calls threshold per minute for CloudWatch alarm | `number` | `500` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"production"` | no |
| <a name="input_notification_emails"></a> [notification\_emails](#input\_notification\_emails) | List of email addresses for SNS notifications | `list(string)` | `[]` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the repository | `string` | `"platform-team"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | `"my-project"` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the ECR repository | `string` | `"my-app-with-monitoring"` | no |
| <a name="input_security_findings_threshold"></a> [security\_findings\_threshold](#input\_security\_findings\_threshold) | Security findings threshold for CloudWatch alarm | `number` | `5` | no |
| <a name="input_storage_threshold_gb"></a> [storage\_threshold\_gb](#input\_storage\_threshold\_gb) | Storage threshold in GB for CloudWatch alarm | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_alarms"></a> [cloudwatch\_alarms](#output\_cloudwatch\_alarms) | CloudWatch alarms created for monitoring |
| <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url) | URL to the CloudWatch dashboard |
| <a name="output_example_docker_commands"></a> [example\_docker\_commands](#output\_example\_docker\_commands) | Example Docker commands for using the repository |
| <a name="output_monitoring_status"></a> [monitoring\_status](#output\_monitoring\_status) | Monitoring configuration status |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the ECR repository |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the ECR repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the ECR repository |
| <a name="output_security_status"></a> [security\_status](#output\_security\_status) | Security configuration status |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic for alerts |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
