output "repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr_monitoring.repository_name
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr_monitoring.repository_url
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr_monitoring.repository_arn
}

output "monitoring_status" {
  description = "Whether monitoring is enabled for the repository"
  value       = module.ecr_monitoring.monitoring_status
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for monitoring alerts"
  value       = module.ecr_monitoring.sns_topic_arn
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch alarms created for monitoring"
  value       = module.ecr_monitoring.cloudwatch_alarms
}
