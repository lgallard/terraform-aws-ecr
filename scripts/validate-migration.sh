#!/bin/bash

# Migration Validation Script: Count to For_Each Pattern Migration
# terraform-aws-ecr module v0.27.x -> v0.28.x+
#
# This script validates a successful migration from count-based to for_each-based
# resources in the terraform-aws-ecr module.
#
# Usage: ./validate-migration.sh [module_name]
# Example: ./validate-migration.sh my_ecr_module

set -e

# Configuration
MODULE_NAME="${1:-ecr}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((FAILED_CHECKS++))
}

log_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
    ((TOTAL_CHECKS++))
}

# Check if resource exists in state
resource_exists() {
    terraform state list | grep -q "^$1$" 2>/dev/null
}

# Check for old count-based resources (should not exist after migration)
check_old_resources() {
    local resource_type="$1"
    local description="$2"
    
    log_check "Checking for old $description resources..."
    
    local old_resources=$(terraform state list | grep "$resource_type\[" || true)
    
    if [[ -z "$old_resources" ]]; then
        log_success "No old $description resources found"
    else
        log_error "Found old $description resources that should have been migrated:"
        echo "$old_resources" | sed 's/^/  /'
    fi
}

# Check for new for_each-based resources
check_new_resources() {
    local resource_pattern="$1"
    local description="$2"
    local expected_count="$3"
    
    log_check "Checking for new $description resources..."
    
    local new_resources=$(terraform state list | grep "$resource_pattern" || true)
    local actual_count=$(echo "$new_resources" | grep -v '^$' | wc -l)
    
    if [[ $actual_count -gt 0 ]]; then
        log_success "Found $actual_count new $description resource(s)"
        if [[ -n "$expected_count" && $actual_count -ne $expected_count ]]; then
            log_warning "Expected $expected_count resources, found $actual_count"
        fi
        echo "$new_resources" | sed 's/^/  /'
    else
        log_warning "No new $description resources found (may be disabled in configuration)"
    fi
}

# Validate terraform configuration
validate_terraform() {
    log_check "Validating Terraform configuration..."
    
    if terraform validate > /dev/null 2>&1; then
        log_success "Terraform configuration is valid"
    else
        log_error "Terraform configuration validation failed"
        terraform validate
    fi
}

# Check terraform plan
check_terraform_plan() {
    log_check "Checking Terraform plan for unexpected changes..."
    
    local plan_output=$(terraform plan -detailed-exitcode 2>&1)
    local exit_code=$?
    
    case $exit_code in
        0)
            log_success "No changes detected - migration successful!"
            ;;
        1)
            log_error "Terraform plan failed"
            echo "$plan_output"
            ;;
        2)
            log_warning "Terraform plan shows changes (may be expected for version updates)"
            log_info "Run 'terraform plan' to review the changes"
            ;;
    esac
}

# Main validation function
main() {
    log_info "Starting migration validation for terraform-aws-ecr module"
    log_info "Module name: $MODULE_NAME"
    log_info "Timestamp: $(date)"
    
    # Prerequisites check
    log_info "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform not found. Please install Terraform."
        exit 1
    fi
    
    if ! terraform state list > /dev/null 2>&1; then
        log_error "No Terraform state found. Ensure you're in the correct directory."
        exit 1
    fi
    
    # Validate Terraform configuration
    validate_terraform
    
    # Check for old count-based resources (should be gone)
    log_info "Checking for old count-based resources..."
    
    check_old_resources "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.repository_storage_usage\[" "storage usage alarm"
    check_old_resources "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.api_call_volume\[" "API call volume alarm"
    check_old_resources "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.image_push_count\[" "image push count alarm"
    check_old_resources "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.image_pull_count\[" "image pull count alarm"
    check_old_resources "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.security_findings\[" "security findings alarm"
    check_old_resources "module\.${MODULE_NAME}\.aws_sns_topic\.ecr_monitoring\[" "SNS topic"
    check_old_resources "module\.${MODULE_NAME}\.aws_sns_topic_subscription\.ecr_monitoring_email\[" "SNS subscription"
    check_old_resources "module\.${MODULE_NAME}\.module\.kms\[" "KMS module"
    check_old_resources "module\.${MODULE_NAME}\.aws_cloudwatch_log_group\.ecr_logs\[" "CloudWatch log group"
    check_old_resources "module\.${MODULE_NAME}\.aws_iam_role\.ecr_logging\[" "IAM logging role"
    check_old_resources "module\.${MODULE_NAME}\.aws_ecr_replication_configuration\.replication\[" "replication configuration"
    check_old_resources "module\.${MODULE_NAME}\.aws_ecr_registry_scanning_configuration\.scanning\[" "registry scanning configuration"
    check_old_resources "module\.${MODULE_NAME}\.module\.pull_through_cache\[" "pull-through cache module"
    
    # Check for new for_each-based resources
    log_info "Checking for new for_each-based resources..."
    
    check_new_resources "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.monitoring\[" "CloudWatch alarms" "5"
    check_new_resources "module\.${MODULE_NAME}\.aws_sns_topic\.ecr_monitoring\[" "SNS topics" "1"
    check_new_resources "module\.${MODULE_NAME}\.aws_sns_topic_subscription\.ecr_monitoring_email\[" "SNS subscriptions"
    check_new_resources "module\.${MODULE_NAME}\.module\.kms\[" "KMS modules" "1"
    check_new_resources "module\.${MODULE_NAME}\.aws_cloudwatch_log_group\.ecr_logs\[" "CloudWatch log groups" "1"
    check_new_resources "module\.${MODULE_NAME}\.aws_iam_role\.ecr_logging\[" "IAM logging roles" "1"
    check_new_resources "module\.${MODULE_NAME}\.aws_ecr_replication_configuration\.replication\[" "replication configurations" "1"
    check_new_resources "module\.${MODULE_NAME}\.aws_ecr_registry_scanning_configuration\.scanning\[" "registry scanning configurations" "1"
    check_new_resources "module\.${MODULE_NAME}\.module\.pull_through_cache\[" "pull-through cache modules" "1"
    
    # Check resource addressing patterns
    log_info "Validating resource addressing patterns..."
    
    # Check CloudWatch alarms use correct keys
    local alarm_resources=$(terraform state list | grep "module\.${MODULE_NAME}\.aws_cloudwatch_metric_alarm\.monitoring\[" || true)
    if [[ -n "$alarm_resources" ]]; then
        log_check "Checking CloudWatch alarm keys..."
        local expected_keys=("storage_usage" "api_call_volume" "image_push_count" "image_pull_count" "security_findings")
        for key in "${expected_keys[@]}"; do
            if echo "$alarm_resources" | grep -q "\"$key\""; then
                log_success "Found alarm with key: $key"
            else
                log_warning "Missing alarm with key: $key (may be disabled)"
            fi
        done
    fi
    
    # Check SNS topic uses correct key
    if resource_exists "module.${MODULE_NAME}.aws_sns_topic.ecr_monitoring[\"ecr_monitoring\"]"; then
        log_success "SNS topic uses correct for_each key: ecr_monitoring"
    fi
    
    # Check module keys
    local module_keys=("kms" "cache")
    for key in "${module_keys[@]}"; do
        local kms_resource="module.${MODULE_NAME}.module.kms[\"$key\"]"
        local cache_resource="module.${MODULE_NAME}.module.pull_through_cache[\"$key\"]"
        
        if resource_exists "$kms_resource"; then
            log_success "KMS module uses correct for_each key: $key"
        fi
        
        if resource_exists "$cache_resource"; then
            log_success "Pull-through cache module uses correct for_each key: $key"
        fi
    done
    
    # Final terraform plan check
    check_terraform_plan
    
    # Summary
    log_info "Validation Summary:"
    log_info "- Total checks: $TOTAL_CHECKS"
    log_success "- Passed: $PASSED_CHECKS"
    log_error "- Failed: $FAILED_CHECKS"
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        log_success "🎉 Migration validation completed successfully!"
        log_info "Your terraform-aws-ecr module has been successfully migrated to for_each patterns."
    else
        log_error "❌ Migration validation found issues!"
        log_info "Please review the failed checks above and ensure all state migrations completed."
        log_info "You may need to run additional 'terraform state mv' commands."
        exit 1
    fi
    
    # Additional recommendations
    echo
    log_info "Post-migration recommendations:"
    log_info "1. Update your module version to 0.28.x+ in your configuration"
    log_info "2. Run 'terraform plan' to review any version-related changes"
    log_info "3. Consider the new configurable monitoring thresholds:"
    log_info "   - monitoring_threshold_image_push (default: 10)"
    log_info "   - monitoring_threshold_image_pull (default: 100)"
    log_info "4. Review the MIGRATION.md guide for additional configuration options"
}

# Help function
show_help() {
    cat << EOF
Terraform AWS ECR Migration Validation Script
Validates successful migration from count-based to for_each-based patterns

Usage: $0 [module_name]

Arguments:
  module_name    Name of the ECR module in your terraform configuration
                 Default: "ecr"

Examples:
  $0                    # Validate module named "ecr"
  $0 my_ecr_module      # Validate module named "my_ecr_module"
  $0 app1_registry      # Validate module named "app1_registry"

What this script checks:
  ✓ No old count-based resources remain
  ✓ New for_each-based resources exist
  ✓ Correct resource addressing patterns
  ✓ Terraform configuration validation
  ✓ Terraform plan shows expected results

Prerequisites:
  - Terraform >= 1.0
  - Completed migration using migrate-to-foreach.sh or manual commands
  - Current working directory contains terraform configuration

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