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
