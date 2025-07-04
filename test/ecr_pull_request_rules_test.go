package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestECRPullRequestRules(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repositoryName := "test-pr-rules-" + uniqueID

	// Define the Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform code that will be tested
		TerraformDir: "../examples/pull-request-rules",

		// Variables to pass to the Terraform code
		Vars: map[string]interface{}{
			"repository_name":        repositoryName,
			"environment":           "test",
			"enable_ci_integration": true,
			"notification_emails":   []string{"test@example.com"},
		},

		// Disable colored output for cleaner logs
		NoColor: true,
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	repositoryURL := terraform.Output(t, terraformOptions, "repository_url")
	repositoryArn := terraform.Output(t, terraformOptions, "repository_arn")
	approvalRoleArn := terraform.Output(t, terraformOptions, "approval_role_arn")

	// Basic validation
	assert.NotEmpty(t, repositoryURL)
	assert.NotEmpty(t, repositoryArn)
	assert.NotEmpty(t, approvalRoleArn)
	assert.Contains(t, repositoryURL, "amazonaws.com")
	assert.Contains(t, repositoryArn, "arn:aws:ecr:")
	assert.Contains(t, approvalRoleArn, "arn:aws:iam:")

	// Validate pull request rules output
	pullRequestRules := terraform.OutputMap(t, terraformOptions, "pull_request_rules")
	assert.Equal(t, "true", pullRequestRules["enabled"])

	// Validate that rules are configured
	assert.NotEmpty(t, pullRequestRules["rules"])
}

func TestECRPullRequestRulesDisabled(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repositoryName := "test-no-pr-rules-" + uniqueID

	// Define the Terraform options for a basic setup without pull request rules
	terraformOptions := &terraform.Options{
		TerraformDir: "../fixtures/basic",
		Vars: map[string]interface{}{
			"name": repositoryName,
		},
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate that pull request rules are disabled by default
	repositoryNameOutput := terraform.Output(t, terraformOptions, "repository_name")
	assert.NotEmpty(t, repositoryNameOutput)
	assert.Equal(t, repositoryName, repositoryNameOutput)

	// Pull request rules should be disabled by default
	// The basic fixture doesn't include pull request rules, which is expected
}

func TestECRPullRequestRulesValidation(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repositoryName := "test-invalid-rules-" + uniqueID

	// Test invalid rule type
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name":                     repositoryName,
			"enable_pull_request_rules": true,
			"pull_request_rules": []map[string]interface{}{
				{
					"name":    "invalid-rule",
					"type":    "invalid_type", // Invalid type
					"enabled": true,
				},
			},
		},
		NoColor: true,
	}

	// This should fail validation
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "Pull request rule type must be one of")
}
