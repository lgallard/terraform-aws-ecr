# Migration Guide: Count to For_Each Pattern Optimization

## Overview

This migration guide helps users transition from version `0.27.x` (count-based resources) to version `0.28.x+` (for_each-based resources) in the terraform-aws-ecr module. The optimization improves resource state management, terraform performance, and future maintainability.

⚠️ **BREAKING CHANGES**: This migration requires manual terraform state operations to avoid resource recreation.

## What Changed

The module converted from `count` patterns to `for_each` patterns for better resource management:

- **CloudWatch Alarms**: 5 individual alarm resources → unified `for_each` pattern
- **SNS Resources**: Count-based topic and subscriptions → for_each with dynamic mapping
- **Auxiliary Resources**: KMS, logging, replication, scanning → for_each patterns
- **Pull Request Rules**: Count-based CloudWatch events → for_each with complex key mapping

## Benefits

✅ **Better State Management**: Stable resource addresses that don't shift when configuration changes
✅ **Improved Performance**: Better terraform parallelization and plan efficiency
✅ **Enhanced Maintainability**: Centralized resource configuration with locals
✅ **Future-Proof Design**: Easier to extend with new monitoring types and configurations

## Prerequisites

- Terraform >= 1.0
- AWS Provider >= 5.0
- Existing terraform state with the old module version (0.27.x)
- Backup of your terraform state file (`terraform state pull > backup.tfstate`)

## Migration Steps

### Step 1: Backup Your State

```bash
# Create a backup of your current state
terraform state pull > terraform-state-backup-$(date +%Y%m%d-%H%M%S).tfstate

# Optional: Create a plan with the old module to ensure current state is stable
terraform plan
```

### Step 2: Update Module Version

Update your Terraform configuration to use the new module version:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  version = "~> 0.28.0"  # Update to the new version

  # Your existing configuration...
}
```

### Step 3: Execute State Migration Commands

Run the following `terraform state mv` commands to migrate resource addresses:

#### **CloudWatch Monitoring Resources**

```bash
# CloudWatch Alarms (if monitoring is enabled)
terraform state mv 'module.ecr.aws_cloudwatch_metric_alarm.repository_storage_usage[0]' 'module.ecr.aws_cloudwatch_metric_alarm.monitoring["storage_usage"]'
terraform state mv 'module.ecr.aws_cloudwatch_metric_alarm.api_call_volume[0]' 'module.ecr.aws_cloudwatch_metric_alarm.monitoring["api_call_volume"]'
terraform state mv 'module.ecr.aws_cloudwatch_metric_alarm.image_push_count[0]' 'module.ecr.aws_cloudwatch_metric_alarm.monitoring["image_push_count"]'
terraform state mv 'module.ecr.aws_cloudwatch_metric_alarm.image_pull_count[0]' 'module.ecr.aws_cloudwatch_metric_alarm.monitoring["image_pull_count"]'

# Security findings alarm (only if enhanced scanning is enabled)
terraform state mv 'module.ecr.aws_cloudwatch_metric_alarm.security_findings[0]' 'module.ecr.aws_cloudwatch_metric_alarm.monitoring["security_findings"]'
```

#### **SNS Resources**

```bash
# SNS Topic (if monitoring and SNS creation are enabled)
terraform state mv 'module.ecr.aws_sns_topic.ecr_monitoring[0]' 'module.ecr.aws_sns_topic.ecr_monitoring["ecr_monitoring"]'

# SNS Subscriptions (run for each email subscriber, starting from index 0)
terraform state mv 'module.ecr.aws_sns_topic_subscription.ecr_monitoring_email[0]' 'module.ecr.aws_sns_topic_subscription.ecr_monitoring_email["subscription-0"]'
terraform state mv 'module.ecr.aws_sns_topic_subscription.ecr_monitoring_email[1]' 'module.ecr.aws_sns_topic_subscription.ecr_monitoring_email["subscription-1"]'
terraform state mv 'module.ecr.aws_sns_topic_subscription.ecr_monitoring_email[2]' 'module.ecr.aws_sns_topic_subscription.ecr_monitoring_email["subscription-2"]'
# Continue for all subscribers...
```

#### **Auxiliary Resources**

```bash
# KMS Module (if KMS key creation is enabled)
terraform state mv 'module.ecr.module.kms[0]' 'module.ecr.module.kms["kms"]'

# Logging Resources (if logging is enabled)
terraform state mv 'module.ecr.aws_cloudwatch_log_group.ecr_logs[0]' 'module.ecr.aws_cloudwatch_log_group.ecr_logs["log_group"]'
terraform state mv 'module.ecr.aws_iam_role.ecr_logging[0]' 'module.ecr.aws_iam_role.ecr_logging["iam_role"]'

# Replication Configuration (if replication is enabled)
terraform state mv 'module.ecr.aws_ecr_replication_configuration.replication[0]' 'module.ecr.aws_ecr_replication_configuration.replication["replication"]'

# Registry Scanning Configuration (if enhanced scanning is enabled)
terraform state mv 'module.ecr.aws_ecr_registry_scanning_configuration.scanning[0]' 'module.ecr.aws_ecr_registry_scanning_configuration.scanning["scanning"]'

# Pull-Through Cache Module (if pull-through cache is enabled)
terraform state mv 'module.ecr.module.pull_through_cache[0]' 'module.ecr.module.pull_through_cache["cache"]'
```

#### **Pull Request Rules (Advanced)**

If you have pull request rules enabled, you'll need to migrate CloudWatch Event Rules and related resources. The exact commands depend on your specific rule configuration:

```bash
# Example for first rule (adjust indices and names based on your configuration)
terraform state mv 'module.ecr.aws_cloudwatch_event_rule.pull_request_rules[0]' 'module.ecr.aws_cloudwatch_event_rule.pull_request_rules["0-rule-name"]'
terraform state mv 'module.ecr.aws_cloudwatch_event_target.pull_request_rules_sns[0]' 'module.ecr.aws_cloudwatch_event_target.pull_request_rules_sns["sns-0"]'
# Continue for all rules...
```

### Step 4: Verify Migration

After running all applicable migration commands:

```bash
# Initialize and plan - should show no changes if migration was successful
terraform init
terraform plan

# The plan should show "No changes" or only minor configuration updates
# If it shows resource recreation, review the migration commands
```

### Step 5: Apply and Validate

```bash
# Apply any remaining configuration changes
terraform apply

# Validate that all resources are properly managed
terraform state list | grep -E "(monitoring|ecr_monitoring|kms|ecr_logs|replication|scanning|pull_through_cache)"
```

## Automated Migration Script

For convenience, use the included migration script:

```bash
# Download and run the migration script
curl -O https://raw.githubusercontent.com/lgallard/terraform-aws-ecr/main/scripts/migrate-to-foreach.sh
chmod +x migrate-to-foreach.sh

# Run with your module name (default: "ecr")
./migrate-to-foreach.sh [module_name]
```

## New Configuration Options

The new version introduces configurable monitoring thresholds:

```hcl
module "ecr" {
  source = "lgallard/ecr/aws"
  version = "~> 0.28.0"

  # Previous configuration...

  # New configurable thresholds (optional)
  monitoring_threshold_image_push = 15    # Default: 10
  monitoring_threshold_image_pull = 150   # Default: 100
}
```

## Troubleshooting

### Common Issues

**1. Resource Not Found Error**
```
Error: Resource not found in state
```
**Solution**: The resource might not exist in your configuration. Check if the feature is enabled (e.g., monitoring, KMS, logging).

**2. Resource Already Exists**
```
Error: Resource already exists in state
```
**Solution**: The resource may have already been migrated. Check `terraform state list` to verify current addresses.

**3. Invalid Resource Address**
```
Error: Invalid resource address
```
**Solution**: Ensure you're using the correct module name in the state move commands. Replace `module.ecr` with your actual module name.

### Validation Commands

```bash
# Check current state addresses
terraform state list | grep -E "(monitoring|sns|kms|logs|replication|scanning)"

# Show specific resource details
terraform state show 'module.ecr.aws_cloudwatch_metric_alarm.monitoring["storage_usage"]'

# Validate configuration
terraform validate
terraform plan
```

### Recovery Steps

If migration fails:

1. Restore from backup:
   ```bash
   terraform state push terraform-state-backup-[timestamp].tfstate
   ```

2. Review and retry migration commands

3. Contact support with specific error messages

## Advanced Scenarios

### Multiple Module Instances

If you have multiple ECR modules:

```bash
# Module instance: app1
terraform state mv 'module.app1_ecr.aws_cloudwatch_metric_alarm.repository_storage_usage[0]' 'module.app1_ecr.aws_cloudwatch_metric_alarm.monitoring["storage_usage"]'

# Module instance: app2
terraform state mv 'module.app2_ecr.aws_cloudwatch_metric_alarm.repository_storage_usage[0]' 'module.app2_ecr.aws_cloudwatch_metric_alarm.monitoring["storage_usage"]'
```

### Selective Feature Usage

Only migrate resources for features you have enabled:

- **Monitoring disabled**: Skip CloudWatch and SNS migrations
- **KMS disabled**: Skip KMS module migration
- **Logging disabled**: Skip logging resource migrations
- **Enhanced scanning disabled**: Skip scanning configuration and security findings alarm

## Support

- **GitHub Issues**: [terraform-aws-ecr issues](https://github.com/lgallard/terraform-aws-ecr/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lgallard/terraform-aws-ecr/discussions)
- **Documentation**: [Module README](https://github.com/lgallard/terraform-aws-ecr/blob/main/README.md)

## Version Compatibility

| Module Version | Terraform | AWS Provider | Migration Required |
|----------------|-----------|--------------|-------------------|
| 0.27.x         | >= 1.0    | >= 5.0       | From (count)      |
| 0.28.x+        | >= 1.0    | >= 5.0       | To (for_each)     |

---

**Note**: This migration is a one-time operation. Once completed, future updates within the 0.28.x series will not require state migrations.
