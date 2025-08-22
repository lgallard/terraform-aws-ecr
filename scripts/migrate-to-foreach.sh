#!/bin/bash

# Migration Script: Count to For_Each Pattern Migration
# terraform-aws-ecr module v0.27.x -> v0.28.x+
#
# This script helps migrate terraform state from count-based resources
# to for_each-based resources in the terraform-aws-ecr module.
#
# Usage: ./migrate-to-foreach.sh [module_name]
# Example: ./migrate-to-foreach.sh my_ecr_module

set -e

# Configuration
MODULE_NAME="${1:-ecr}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="terraform-state-backup-${TIMESTAMP}.tfstate"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if resource exists in state
resource_exists() {
    terraform state list | grep -q "^$1$" 2>/dev/null
}

# Safely move resource with existence check
safe_state_mv() {
    local from="$1"
    local to="$2"
    local description="$3"

    if resource_exists "$from"; then
        log_info "Migrating: $description"
        if terraform state mv "$from" "$to"; then
            log_success "✓ $description"
        else
            log_error "✗ Failed to migrate: $description"
            return 1
        fi
    else
        log_warning "Resource not found, skipping: $description"
    fi
}

# Main migration function
main() {
    log_info "Starting terraform-aws-ecr migration from count to for_each patterns"
    log_info "Module name: $MODULE_NAME"

    # Step 1: Validate prerequisites
    log_info "Checking prerequisites..."

    if ! command -v terraform &> /dev/null; then
        log_error "Terraform not found. Please install Terraform."
        exit 1
    fi

    if ! terraform version | grep -E "Terraform v(1\.|[2-9]\.)"; then
        log_error "Terraform 1.0+ required. Please upgrade Terraform."
        exit 1
    fi

    # Step 2: Create state backup
    log_info "Creating state backup: $BACKUP_FILE"
    if terraform state pull > "$BACKUP_FILE"; then
        log_success "State backup created: $BACKUP_FILE"
    else
        log_error "Failed to create state backup"
        exit 1
    fi

    # Step 3: Validate current state
    log_info "Validating current state..."
    if ! terraform plan -detailed-exitcode > /dev/null 2>&1; then
        log_warning "Current configuration has pending changes. Consider applying before migration."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Migration cancelled by user"
            exit 0
        fi
    fi

    # Step 4: Execute migrations
    log_info "Starting resource migrations..."

    # CloudWatch Monitoring Resources
    log_info "Migrating CloudWatch monitoring resources..."
    safe_state_mv "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.repository_storage_usage[0]" \
                  "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.monitoring[\"storage_usage\"]" \
                  "Storage usage alarm"

    safe_state_mv "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.api_call_volume[0]" \
                  "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.monitoring[\"api_call_volume\"]" \
                  "API call volume alarm"

    safe_state_mv "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.image_push_count[0]" \
                  "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.monitoring[\"image_push_count\"]" \
                  "Image push count alarm"

    safe_state_mv "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.image_pull_count[0]" \
                  "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.monitoring[\"image_pull_count\"]" \
                  "Image pull count alarm"

    safe_state_mv "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.security_findings[0]" \
                  "module.${MODULE_NAME}.aws_cloudwatch_metric_alarm.monitoring[\"security_findings\"]" \
                  "Security findings alarm"

    # SNS Resources
    log_info "Migrating SNS resources..."
    safe_state_mv "module.${MODULE_NAME}.aws_sns_topic.ecr_monitoring[0]" \
                  "module.${MODULE_NAME}.aws_sns_topic.ecr_monitoring[\"ecr_monitoring\"]" \
                  "SNS topic"

    # SNS Subscriptions (check up to 10 subscriptions)
    log_info "Migrating SNS subscriptions..."
    for i in {0..9}; do
        safe_state_mv "module.${MODULE_NAME}.aws_sns_topic_subscription.ecr_monitoring_email[$i]" \
                      "module.${MODULE_NAME}.aws_sns_topic_subscription.ecr_monitoring_email[\"subscription-$i\"]" \
                      "SNS subscription $i"
    done

    # Auxiliary Resources
    log_info "Migrating auxiliary resources..."

    # KMS Module
    safe_state_mv "module.${MODULE_NAME}.module.kms[0]" \
                  "module.${MODULE_NAME}.module.kms[\"kms\"]" \
                  "KMS module"

    # Logging Resources
    safe_state_mv "module.${MODULE_NAME}.aws_cloudwatch_log_group.ecr_logs[0]" \
                  "module.${MODULE_NAME}.aws_cloudwatch_log_group.ecr_logs[\"log_group\"]" \
                  "CloudWatch log group"

    safe_state_mv "module.${MODULE_NAME}.aws_iam_role.ecr_logging[0]" \
                  "module.${MODULE_NAME}.aws_iam_role.ecr_logging[\"iam_role\"]" \
                  "IAM logging role"

    # Replication Configuration
    safe_state_mv "module.${MODULE_NAME}.aws_ecr_replication_configuration.replication[0]" \
                  "module.${MODULE_NAME}.aws_ecr_replication_configuration.replication[\"replication\"]" \
                  "Replication configuration"

    # Registry Scanning Configuration
    safe_state_mv "module.${MODULE_NAME}.aws_ecr_registry_scanning_configuration.scanning[0]" \
                  "module.${MODULE_NAME}.aws_ecr_registry_scanning_configuration.scanning[\"scanning\"]" \
                  "Registry scanning configuration"

    # Pull-Through Cache Module
    safe_state_mv "module.${MODULE_NAME}.module.pull_through_cache[0]" \
                  "module.${MODULE_NAME}.module.pull_through_cache[\"cache\"]" \
                  "Pull-through cache module"

    # Step 5: Validate migration
    log_info "Validating migration..."

    if terraform plan -detailed-exitcode > /dev/null 2>&1; then
        log_success "Migration completed successfully! No resource changes detected."
    else
        log_warning "Migration completed, but terraform plan shows changes."
        log_info "This may be normal if you've updated module version or configuration."
        log_info "Run 'terraform plan' to review the changes."
    fi

    # Step 6: Show summary
    log_info "Migration Summary:"
    log_info "- Backup created: $BACKUP_FILE"
    log_info "- Module migrated: $MODULE_NAME"
    log_info "- Migration completed: $(date)"

    log_success "Migration completed successfully!"
    log_info "Next steps:"
    log_info "1. Run 'terraform plan' to review any configuration changes"
    log_info "2. Run 'terraform apply' if needed"
    log_info "3. Update your module version to 0.28.x+ in your configuration"

    # Cleanup suggestion
    echo
    read -p "Keep state backup file $BACKUP_FILE? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        rm "$BACKUP_FILE"
        log_info "State backup file removed"
    else
        log_info "State backup preserved: $BACKUP_FILE"
    fi
}

# Recovery function
recover() {
    log_error "Migration failed. Recovering from backup..."
    if [[ -f "$BACKUP_FILE" ]]; then
        if terraform state push "$BACKUP_FILE"; then
            log_success "State recovered from backup"
        else
            log_error "Failed to recover state. Manual intervention required."
            log_error "Backup file: $BACKUP_FILE"
        fi
    else
        log_error "Backup file not found. Cannot recover automatically."
    fi
}

# Error handling
trap 'recover' ERR

# Help function
show_help() {
    cat << EOF
Terraform AWS ECR Migration Script
Migrates from count-based to for_each-based resource patterns

Usage: $0 [module_name]

Arguments:
  module_name    Name of the ECR module in your terraform configuration
                 Default: "ecr"

Examples:
  $0                    # Migrate module named "ecr"
  $0 my_ecr_module      # Migrate module named "my_ecr_module"
  $0 app1_registry      # Migrate module named "app1_registry"

Prerequisites:
  - Terraform >= 1.0
  - AWS Provider >= 5.0
  - Existing terraform state with terraform-aws-ecr module

Notes:
  - Creates automatic state backup before migration
  - Only migrates resources that exist in current state
  - Safe to run multiple times (idempotent)
  - Provides recovery mechanism on failure

For more information, see: MIGRATION.md
EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    "")
        main
        ;;
    *)
        main
        ;;
esac
