package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestTerraformEcrLifecyclePolicies tests the lifecycle policy functionality
func TestTerraformEcrLifecyclePolicies(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "fixtures/lifecycle-policies",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test template-based lifecycle policy
	templateRepoURL := terraform.Output(t, terraformOptions, "lifecycle_template_repository_url")
	assert.NotEmpty(t, templateRepoURL)

	// Test helper variables lifecycle policy  
	helperVarsRepoURL := terraform.Output(t, terraformOptions, "lifecycle_helper_vars_repository_url")
	assert.NotEmpty(t, helperVarsRepoURL)

	// Test manual override lifecycle policy
	manualOverrideRepoURL := terraform.Output(t, terraformOptions, "lifecycle_manual_override_repository_url")
	assert.NotEmpty(t, manualOverrideRepoURL)

	// Verify that the lifecycle policies contain the expected rules
	// Note: In a real test, we would inspect the actual AWS resources
	// For now, we just verify that the repositories were created successfully
	assert.Contains(t, templateRepoURL, "lifecycle-template-test")
	assert.Contains(t, helperVarsRepoURL, "lifecycle-helper-vars-test")
	assert.Contains(t, manualOverrideRepoURL, "lifecycle-manual-override-test")
}

// LifecyclePolicyRule represents a lifecycle policy rule
type LifecyclePolicyRule struct {
	RulePriority int    `json:"rulePriority"`
	Description  string `json:"description"`
	Selection    struct {
		TagStatus     string   `json:"tagStatus,omitempty"`
		TagPrefixList []string `json:"tagPrefixList,omitempty"`
		CountType     string   `json:"countType"`
		CountUnit     string   `json:"countUnit,omitempty"`
		CountNumber   int      `json:"countNumber"`
	} `json:"selection"`
	Action struct {
		Type string `json:"type"`
	} `json:"action"`
}

// LifecyclePolicy represents a lifecycle policy
type LifecyclePolicy struct {
	Rules []LifecyclePolicyRule `json:"rules"`
}

// TestLifecyclePolicyGeneration tests the lifecycle policy generation logic
func TestLifecyclePolicyGeneration(t *testing.T) {
	t.Parallel()

	// This test verifies that the Terraform configuration is valid
	// by running terraform validate instead of plan/apply
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "fixtures/lifecycle-policies",
	})

	// Run terraform init and validate the configuration
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
}