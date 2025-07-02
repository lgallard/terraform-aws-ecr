package test

import (
	"encoding/json"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestTerraformEcrLifecyclePolicies tests the lifecycle policy functionality
func TestTerraformEcrLifecyclePolicies(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "fixtures/lifecycle-policies",
		TerraformBinary: "terraform", // Explicitly use terraform binary
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

// TestTerraformEcrLifecyclePolicyHelperVariables tests specific helper variable configurations
func TestTerraformEcrLifecyclePolicyHelperVariables(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "fixtures/lifecycle-policies-helper-vars",
		TerraformBinary: "terraform", // Explicitly use terraform binary
		Vars: map[string]interface{}{
			"lifecycle_expire_untagged_after_days": 14,
			"lifecycle_keep_latest_n_images":      25,
			"lifecycle_expire_tagged_after_days":  60,
			"lifecycle_tag_prefixes_to_keep":      []string{"v", "release"},
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Test that repository was created with helper variables
	repoURL := terraform.Output(t, terraformOptions, "repository_url")
	assert.NotEmpty(t, repoURL)
	assert.Contains(t, repoURL, "helper-vars-test")

	// Verify the lifecycle policy was generated correctly
	lifecyclePolicyJSON := terraform.Output(t, terraformOptions, "lifecycle_policy_json")
	assert.NotEmpty(t, lifecyclePolicyJSON)

	var policy LifecyclePolicy
	err := json.Unmarshal([]byte(lifecyclePolicyJSON), &policy)
	assert.NoError(t, err)

	// Verify the generated policy has the expected rules
	assert.Len(t, policy.Rules, 3, "Should have 3 lifecycle rules")

	// Check rule 1: Expire untagged images after 14 days
	untaggedRule := policy.Rules[0]
	assert.Equal(t, 1, untaggedRule.RulePriority)
	assert.Equal(t, "untagged", untaggedRule.Selection.TagStatus)
	assert.Equal(t, "sinceImagePushed", untaggedRule.Selection.CountType)
	assert.Equal(t, "days", untaggedRule.Selection.CountUnit)
	assert.Equal(t, 14, untaggedRule.Selection.CountNumber)

	// Check rule 2: Keep latest 25 images with tag prefixes
	keepLatestRule := policy.Rules[1]
	assert.Equal(t, 2, keepLatestRule.RulePriority)
	assert.Equal(t, "tagged", keepLatestRule.Selection.TagStatus)
	assert.Equal(t, "imageCountMoreThan", keepLatestRule.Selection.CountType)
	assert.Equal(t, 25, keepLatestRule.Selection.CountNumber)
	assert.Contains(t, keepLatestRule.Selection.TagPrefixList, "v")
	assert.Contains(t, keepLatestRule.Selection.TagPrefixList, "release")

	// Check rule 3: Expire tagged images after 60 days
	taggedRule := policy.Rules[2]
	assert.Equal(t, 3, taggedRule.RulePriority)
	assert.Equal(t, "any", taggedRule.Selection.TagStatus)
	assert.Equal(t, "sinceImagePushed", taggedRule.Selection.CountType)
	assert.Equal(t, "days", taggedRule.Selection.CountUnit)
	assert.Equal(t, 60, taggedRule.Selection.CountNumber)
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
		TerraformDir:    "fixtures/lifecycle-policies",
		TerraformBinary: "terraform", // Explicitly use terraform binary
	})

	// Run terraform init and validate the configuration
	terraform.Init(t, terraformOptions)
	terraform.Validate(t, terraformOptions)
}

// TestLifecyclePolicyTemplates tests all predefined templates
func TestLifecyclePolicyTemplates(t *testing.T) {
	templates := []string{"development", "production", "cost_optimization", "compliance"}

	for _, template := range templates {
		t.Run(template, func(t *testing.T) {
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "test/fixtures/lifecycle-policies-templates")

			terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
				TerraformDir:    terraformDir,
				TerraformBinary: "terraform", // Explicitly use terraform binary
				Vars: map[string]interface{}{
					"template_name": template,
				},
			})

			defer terraform.Destroy(t, terraformOptions)

			terraform.InitAndApply(t, terraformOptions)

			// Verify repository was created with template
			repoURL := terraform.Output(t, terraformOptions, "repository_url")
			assert.NotEmpty(t, repoURL)
			assert.Contains(t, repoURL, template)

			// Verify lifecycle policy was applied
			lifecyclePolicyJSON := terraform.Output(t, terraformOptions, "lifecycle_policy_json")
			assert.NotEmpty(t, lifecyclePolicyJSON)

			var policy LifecyclePolicy
			err := json.Unmarshal([]byte(lifecyclePolicyJSON), &policy)
			assert.NoError(t, err)
			assert.Greater(t, len(policy.Rules), 0, "Template should generate at least one rule")
		})
	}
}
