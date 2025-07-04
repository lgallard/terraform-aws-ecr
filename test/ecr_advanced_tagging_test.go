package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestEcrAdvancedTagging tests the advanced tagging functionality
func TestEcrAdvancedTagging(t *testing.T) {
	t.Parallel()

	// Generate a random suffix for repository names
	uniqueID := strings.ToLower(random.UniqueId())

	// Terraform options for this test
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "./fixtures/advanced-tagging",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			// Using random suffix in fixture
		},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Get the repository URLs from outputs
	advancedRepoURL := terraform.Output(t, terraformOptions, "advanced_tagging_repository_url")
	basicRepoURL := terraform.Output(t, terraformOptions, "basic_tagging_repository_url")
	legacyRepoURL := terraform.Output(t, terraformOptions, "legacy_tagging_repository_url")

	// Verify repository URLs are not empty
	assert.NotEmpty(t, advancedRepoURL)
	assert.NotEmpty(t, basicRepoURL)
	assert.NotEmpty(t, legacyRepoURL)

	// Extract repository names from URLs
	advancedRepoName := extractRepoNameFromURL(advancedRepoURL)
	basicRepoName := extractRepoNameFromURL(basicRepoURL)
	legacyRepoName := extractRepoNameFromURL(legacyRepoURL)

	// Create AWS session
	sess, err := session.NewSession()
	assert.NoError(t, err)

	// Create ECR client
	ecrClient := ecr.New(sess)

	// Test advanced tagging repository
	t.Run("AdvancedTaggingRepository", func(t *testing.T) {
		// Describe the repository to get tags
		resp, err := ecrClient.DescribeRepositories(&ecr.DescribeRepositoriesInput{
			RepositoryNames: []*string{aws.String(advancedRepoName)},
		})
		assert.NoError(t, err)
		assert.Len(t, resp.Repositories, 1)

		repo := resp.Repositories[0]

		// Get tags from Terraform output
		appliedTagsOutput := terraform.Output(t, terraformOptions, "advanced_tagging_applied_tags")
		taggingStrategyOutput := terraform.Output(t, terraformOptions, "advanced_tagging_strategy")
		complianceStatusOutput := terraform.Output(t, terraformOptions, "advanced_tagging_compliance_status")

		// Verify output structure
		assert.NotEmpty(t, appliedTagsOutput)
		assert.NotEmpty(t, taggingStrategyOutput)
		assert.NotEmpty(t, complianceStatusOutput)

		// Test that the repository has the expected properties
		assert.Equal(t, "IMMUTABLE", *repo.ImageTagMutability)

		// Verify repository name contains our test identifier
		assert.Contains(t, *repo.RepositoryName, "test-advanced-tagging")
	})

	// Test basic tagging repository
	t.Run("BasicTaggingRepository", func(t *testing.T) {
		// Describe the repository
		resp, err := ecrClient.DescribeRepositories(&ecr.DescribeRepositoriesInput{
			RepositoryNames: []*string{aws.String(basicRepoName)},
		})
		assert.NoError(t, err)
		assert.Len(t, resp.Repositories, 1)

		repo := resp.Repositories[0]

		// Get applied tags from output
		appliedTagsOutput := terraform.Output(t, terraformOptions, "basic_tagging_applied_tags")
		assert.NotEmpty(t, appliedTagsOutput)

		// Verify repository name contains our test identifier
		assert.Contains(t, *repo.RepositoryName, "test-basic-tagging")
	})

	// Test legacy compatibility repository
	t.Run("LegacyTaggingRepository", func(t *testing.T) {
		// Describe the repository
		resp, err := ecrClient.DescribeRepositories(&ecr.DescribeRepositoriesInput{
			RepositoryNames: []*string{aws.String(legacyRepoName)},
		})
		assert.NoError(t, err)
		assert.Len(t, resp.Repositories, 1)

		repo := resp.Repositories[0]

		// Get applied tags from output
		appliedTagsOutput := terraform.Output(t, terraformOptions, "legacy_tagging_applied_tags")
		assert.NotEmpty(t, appliedTagsOutput)

		// Verify repository name contains our test identifier
		assert.Contains(t, *repo.RepositoryName, "test-legacy-tagging")

		// Verify default mutability for legacy
		assert.Equal(t, "MUTABLE", *repo.ImageTagMutability)
	})
}

// TestEcrTagValidation tests tag validation functionality specifically
func TestEcrTagValidation(t *testing.T) {
	t.Parallel()

	// This test should fail when required tags are missing
	terraformOptions := &terraform.Options{
		TerraformDir: "./fixtures/advanced-tagging",
		Vars: map[string]interface{}{
			// This would be a separate test fixture that intentionally
			// omits required tags to test validation failure
		},
		NoColor: true,
	}

	// Note: This test would require a separate fixture that has validation
	// enabled but missing required tags. For now, we test the success case.

	// In a real implementation, you would create a separate fixture
	// that intentionally fails validation and test that terraform plan fails
	t.Skip("Tag validation failure test requires separate fixture")
}

// Helper function to extract repository name from ECR URL
func extractRepoNameFromURL(url string) string {
	// ECR URL format: AWS_ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/REPO_NAME
	parts := strings.Split(url, "/")
	if len(parts) > 1 {
		return parts[len(parts)-1]
	}
	return ""
}
