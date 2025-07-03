package test

import (
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/cloudwatch"
	"github.com/aws/aws-sdk-go/service/ecr"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestEcrMonitoring tests the ECR monitoring functionality
func TestEcrMonitoring(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("terratest-ecr-monitoring-%s", uniqueID)

	// Terraform options for this test
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "./fixtures/monitoring",

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

	// Run `terraform output` to get the outputs
	outputRepoName := terraform.Output(t, terraformOptions, "repository_name")
	outputRepoURL := terraform.Output(t, terraformOptions, "repository_url")
	outputRepoARN := terraform.Output(t, terraformOptions, "repository_arn")
	outputMonitoringStatus := terraform.Output(t, terraformOptions, "monitoring_status")
	outputSNSTopicArn := terraform.Output(t, terraformOptions, "sns_topic_arn")
	outputCloudWatchAlarms := terraform.Output(t, terraformOptions, "cloudwatch_alarms")

	// Verify the repository was created with the correct name
	assert.Equal(t, repoName, outputRepoName)
	assert.Contains(t, outputRepoURL, repoName)
	assert.Contains(t, outputRepoARN, repoName)

	// Verify monitoring status
	var monitoringStatus map[string]interface{}
	err := json.Unmarshal([]byte(outputMonitoringStatus), &monitoringStatus)
	require.NoError(t, err)
	assert.True(t, monitoringStatus["enabled"].(bool))
	assert.True(t, monitoringStatus["sns_topic_created"].(bool))
	assert.True(t, monitoringStatus["security_monitoring_enabled"].(bool))
	assert.Equal(t, float64(5), monitoringStatus["storage_threshold_gb"].(float64))
	assert.Equal(t, float64(500), monitoringStatus["api_calls_threshold"].(float64))
	assert.Equal(t, float64(3), monitoringStatus["security_findings_threshold"].(float64))

	// Verify SNS topic was created
	assert.NotEmpty(t, outputSNSTopicArn)
	assert.Contains(t, outputSNSTopicArn, "test-alerts")

	// Verify CloudWatch alarms were created
	var cloudWatchAlarms map[string]interface{}
	err = json.Unmarshal([]byte(outputCloudWatchAlarms), &cloudWatchAlarms)
	require.NoError(t, err)
	assert.Contains(t, cloudWatchAlarms, "storage_usage_alarm")
	assert.Contains(t, cloudWatchAlarms, "api_calls_alarm")
	assert.Contains(t, cloudWatchAlarms, "image_push_alarm")
	assert.Contains(t, cloudWatchAlarms, "image_pull_alarm")
	assert.Contains(t, cloudWatchAlarms, "security_findings_alarm")

	// Create AWS session for direct AWS API calls
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String("us-east-1"),
	}))

	// Test AWS ECR API to ensure repository exists
	ecrClient := ecr.New(sess)
	describeRepoInput := &ecr.DescribeRepositoriesInput{
		RepositoryNames: []*string{aws.String(repoName)},
	}

	describeRepoOutput, err := ecrClient.DescribeRepositories(describeRepoInput)
	require.NoError(t, err)
	require.Len(t, describeRepoOutput.Repositories, 1)

	repository := describeRepoOutput.Repositories[0]
	assert.Equal(t, repoName, *repository.RepositoryName)
	assert.Equal(t, "IMMUTABLE", *repository.ImageTagMutability)
	assert.True(t, *repository.ImageScanningConfiguration.ScanOnPush)

	// Test SNS topic exists
	snsClient := sns.New(sess)
	listTopicsOutput, err := snsClient.ListTopics(&sns.ListTopicsInput{})
	require.NoError(t, err)

	snsTopicExists := false
	for _, topic := range listTopicsOutput.Topics {
		if *topic.TopicArn == outputSNSTopicArn {
			snsTopicExists = true
			break
		}
	}
	assert.True(t, snsTopicExists, "SNS topic should exist")

	// Test CloudWatch alarms exist
	cloudWatchClient := cloudwatch.New(sess)
	
	// Get storage usage alarm
	storageAlarmName := fmt.Sprintf("%s-ecr-storage-usage", repoName)
	describeAlarmsInput := &cloudwatch.DescribeAlarmsInput{
		AlarmNames: []*string{aws.String(storageAlarmName)},
	}
	
	describeAlarmsOutput, err := cloudWatchClient.DescribeAlarms(describeAlarmsInput)
	require.NoError(t, err)
	require.Len(t, describeAlarmsOutput.MetricAlarms, 1)
	
	storageAlarm := describeAlarmsOutput.MetricAlarms[0]
	assert.Equal(t, storageAlarmName, *storageAlarm.AlarmName)
	assert.Equal(t, "AWS/ECR", *storageAlarm.Namespace)
	assert.Equal(t, "RepositorySizeInBytes", *storageAlarm.MetricName)
	assert.Equal(t, "GreaterThanThreshold", *storageAlarm.ComparisonOperator)
	assert.Equal(t, float64(5*1024*1024*1024), *storageAlarm.Threshold) // 5GB in bytes
	
	// Check alarm dimensions
	require.Len(t, storageAlarm.Dimensions, 1)
	assert.Equal(t, "RepositoryName", *storageAlarm.Dimensions[0].Name)
	assert.Equal(t, repoName, *storageAlarm.Dimensions[0].Value)

	// Test API calls alarm
	apiCallsAlarmName := fmt.Sprintf("%s-ecr-api-calls", repoName)
	describeAlarmsInput = &cloudwatch.DescribeAlarmsInput{
		AlarmNames: []*string{aws.String(apiCallsAlarmName)},
	}
	
	describeAlarmsOutput, err = cloudWatchClient.DescribeAlarms(describeAlarmsInput)
	require.NoError(t, err)
	require.Len(t, describeAlarmsOutput.MetricAlarms, 1)
	
	apiCallsAlarm := describeAlarmsOutput.MetricAlarms[0]
	assert.Equal(t, apiCallsAlarmName, *apiCallsAlarm.AlarmName)
	assert.Equal(t, "AWS/ECR", *apiCallsAlarm.Namespace)
	assert.Equal(t, "ApiCallCount", *apiCallsAlarm.MetricName)
	assert.Equal(t, float64(500), *apiCallsAlarm.Threshold)

	// Test security findings alarm
	securityAlarmName := fmt.Sprintf("%s-ecr-security-findings", repoName)
	describeAlarmsInput = &cloudwatch.DescribeAlarmsInput{
		AlarmNames: []*string{aws.String(securityAlarmName)},
	}
	
	describeAlarmsOutput, err = cloudWatchClient.DescribeAlarms(describeAlarmsInput)
	require.NoError(t, err)
	require.Len(t, describeAlarmsOutput.MetricAlarms, 1)
	
	securityAlarm := describeAlarmsOutput.MetricAlarms[0]
	assert.Equal(t, securityAlarmName, *securityAlarm.AlarmName)
	assert.Equal(t, "AWS/ECR", *securityAlarm.Namespace)
	assert.Equal(t, "HighSeverityVulnerabilityCount", *securityAlarm.MetricName)
	assert.Equal(t, float64(3), *securityAlarm.Threshold)

	// Verify all alarms have SNS topic configured as action
	for _, alarm := range []*cloudwatch.MetricAlarm{storageAlarm, apiCallsAlarm, securityAlarm} {
		assert.Contains(t, alarm.AlarmActions, &outputSNSTopicArn)
		assert.Contains(t, alarm.OKActions, &outputSNSTopicArn)
	}
}

// TestEcrMonitoringDisabled tests that monitoring resources are not created when disabled
func TestEcrMonitoringDisabled(t *testing.T) {
	t.Parallel()

	// Generate a random repository name to prevent collisions
	uniqueID := strings.ToLower(random.UniqueId())
	repoName := fmt.Sprintf("terratest-ecr-no-monitoring-%s", uniqueID)

	// Terraform options for this test
	terraformOptions := &terraform.Options{
		// Path to the Terraform code
		TerraformDir: "./fixtures/basic",

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

	// Run `terraform output` to get the outputs
	outputRepoName := terraform.Output(t, terraformOptions, "repository_name")
	outputMonitoringStatus := terraform.Output(t, terraformOptions, "monitoring_status")

	// Verify the repository was created with the correct name
	assert.Equal(t, repoName, outputRepoName)

	// Verify monitoring is disabled
	var monitoringStatus map[string]interface{}
	err := json.Unmarshal([]byte(outputMonitoringStatus), &monitoringStatus)
	require.NoError(t, err)
	assert.False(t, monitoringStatus["enabled"].(bool))
	assert.False(t, monitoringStatus["sns_topic_created"].(bool))
	assert.Nil(t, monitoringStatus["storage_threshold_gb"])
	assert.Nil(t, monitoringStatus["api_calls_threshold"])
	assert.Nil(t, monitoringStatus["security_findings_threshold"])

	// Create AWS session for direct AWS API calls
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String("us-east-1"),
	}))

	// Test CloudWatch alarms do not exist
	cloudWatchClient := cloudwatch.New(sess)
	
	// Check that no alarms exist for this repository
	alarmNames := []string{
		fmt.Sprintf("%s-ecr-storage-usage", repoName),
		fmt.Sprintf("%s-ecr-api-calls", repoName),
		fmt.Sprintf("%s-ecr-security-findings", repoName),
	}

	for _, alarmName := range alarmNames {
		describeAlarmsInput := &cloudwatch.DescribeAlarmsInput{
			AlarmNames: []*string{aws.String(alarmName)},
		}
		
		describeAlarmsOutput, err := cloudWatchClient.DescribeAlarms(describeAlarmsInput)
		require.NoError(t, err)
		assert.Len(t, describeAlarmsOutput.MetricAlarms, 0, "Alarm %s should not exist", alarmName)
	}
}