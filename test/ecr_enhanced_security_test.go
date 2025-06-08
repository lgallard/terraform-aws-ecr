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

// TestEcrEnhancedSecurityBasic tests basic ECR repository creation with enhanced security features
func TestEcrEnhancedSecurityBasic(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("terratest-ecr-enhanced-%s", uniqueID)

	// Terraform options for this test
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "./fixtures/enhanced-security",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name": repoName,
			"enable_registry_scanning": false, // Test basic functionality first
			"enable_pull_through_cache": false,
			"enable_secret_scanning": false,
			"tags": map[string]string{
				"Test":        "EnhancedSecurity",
				"Environment": "Testing",
			},
		},

		// Explicitly use terraform binary
		TerraformBinary: "terraform",
	}

	// Clean up resources when the test is finished
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the repository information
	outputRepoName := terraform.Output(t, terraformOptions, "repository_name")
	outputRepoURL := terraform.Output(t, terraformOptions, "repository_url")
	outputRepoARN := terraform.Output(t, terraformOptions, "repository_arn")

	// Verify the repository was created with the correct name
	assert.Equal(t, repoName, outputRepoName)

	// Verify the repository URL format
	assert.True(t, strings.Contains(outputRepoURL, repoName))
	
	// Verify the ARN was created and contains the expected repository name
	assert.True(t, strings.Contains(outputRepoARN, repoName))

	// Use AWS SDK to verify the repository actually exists in AWS
	sess := session.Must(session.NewSession())
	ecrClient := ecr.New(sess)

	// Describe the repository
	describeResult, err := ecrClient.DescribeRepositories(&ecr.DescribeRepositoriesInput{
		RepositoryNames: []*string{aws.String(repoName)},
	})

	// Verify we can retrieve the repository
	assert.NoError(t, err)
	assert.Equal(t, 1, len(describeResult.Repositories))
	assert.Equal(t, repoName, *describeResult.Repositories[0].RepositoryName)
	
	// Verify image tag mutability setting (should be IMMUTABLE according to our fixture)
	assert.Equal(t, "IMMUTABLE", *describeResult.Repositories[0].ImageTagMutability)
	
	// Verify encryption configuration (should be KMS)
	assert.NotNil(t, describeResult.Repositories[0].EncryptionConfiguration)
	assert.Equal(t, "KMS", *describeResult.Repositories[0].EncryptionConfiguration.EncryptionType)
	
	// Verify scanning configuration (basic scanning should be enabled)
	assert.NotNil(t, describeResult.Repositories[0].ImageScanningConfiguration)
	assert.True(t, *describeResult.Repositories[0].ImageScanningConfiguration.ScanOnPush)

	// Get security status output and verify structure
	securityStatus := terraform.OutputMap(t, terraformOptions, "security_status")
	assert.NotNil(t, securityStatus)
	assert.Equal(t, "true", securityStatus["basic_scanning_enabled"])
	assert.Equal(t, "false", securityStatus["enhanced_scanning_enabled"])
	assert.Equal(t, "false", securityStatus["pull_through_cache_enabled"])
	assert.Equal(t, "KMS", securityStatus["encryption_type"])
	assert.Equal(t, "IMMUTABLE", securityStatus["image_tag_mutability"])
}

// TestEcrEnhancedSecurityWithRegistryScanning tests ECR with enhanced scanning enabled
// Note: This test is more expensive and requires Inspector to be available in the region
func TestEcrEnhancedSecurityWithRegistryScanning(t *testing.T) {
	t.Skip("Skipping enhanced scanning test - requires Inspector and may incur costs")

	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("terratest-ecr-enhanced-scan-%s", uniqueID)

	// Terraform options for this test
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "./fixtures/enhanced-security",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name": repoName,
			"enable_registry_scanning": true,
			"registry_scan_type": "ENHANCED",
			"enable_secret_scanning": true,
			"registry_scan_filters": []map[string]interface{}{
				{
					"name":   "PACKAGE_VULNERABILITY_SEVERITY",
					"values": []string{"HIGH", "CRITICAL"},
				},
			},
			"tags": map[string]string{
				"Test":        "EnhancedScanningTest",
				"Environment": "Testing",
			},
		},

		// Explicitly use terraform binary
		TerraformBinary: "terraform",
	}

	// Clean up resources when the test is finished
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Verify registry scanning configuration output
	scanningStatus := terraform.OutputMap(t, terraformOptions, "registry_scanning_status")
	assert.NotNil(t, scanningStatus)
	assert.Equal(t, "true", scanningStatus["enabled"])
	assert.Equal(t, "ENHANCED", scanningStatus["scan_type"])
	assert.Equal(t, "true", scanningStatus["secret_scanning_enabled"])
}