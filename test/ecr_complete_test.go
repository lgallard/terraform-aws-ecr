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

// TestEcrCompleteRepository tests the creation of an ECR repository with all features enabled
func TestEcrCompleteRepository(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("terratest-ecr-complete-%s", uniqueID)

	// Terraform options for this test
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "./fixtures/complete",

		// Variables to pass to Terraform
		Vars: map[string]interface{}{
			"name": repoName,
		},

		// Explicitly use terraform binary
		TerraformBinary: "terraform",
	}

	// Clean up resources when the test is finished
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the repository name and URL
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

	// Verify repository policy exists
	policyResult, err := ecrClient.GetRepositoryPolicy(&ecr.GetRepositoryPolicyInput{
		RepositoryName: aws.String(repoName),
	})

	// The policy should exist
	assert.NoError(t, err)
	assert.NotNil(t, policyResult.PolicyText)
	assert.True(t, strings.Contains(*policyResult.PolicyText, "TestPolicy"))

	// Verify lifecycle policy exists
	lifecyclePolicyResult, err := ecrClient.GetLifecyclePolicy(&ecr.GetLifecyclePolicyInput{
		RepositoryName: aws.String(repoName),
	})

	// The lifecycle policy should exist
	assert.NoError(t, err)
	assert.NotNil(t, lifecyclePolicyResult.LifecyclePolicyText)
	assert.True(t, strings.Contains(*lifecyclePolicyResult.LifecyclePolicyText, "imageCountMoreThan"))
}
