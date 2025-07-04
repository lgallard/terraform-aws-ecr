output "repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr_with_monitoring.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr_with_monitoring.repository_name
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr_with_monitoring.repository_arn
}

output "monitoring_status" {
  description = "Monitoring configuration status"
  value       = module.ecr_with_monitoring.monitoring_status
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.ecr_with_monitoring.sns_topic_arn
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarms created for monitoring"
  value       = module.ecr_with_monitoring.cloudwatch_alarms
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.ecr_dashboard.dashboard_name}"
}

output "security_status" {
  description = "Security configuration status"
  value       = module.ecr_with_monitoring.security_status
}

output "example_docker_commands" {
  description = "Example Docker commands for using the repository"
  value = {
    login = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.ecr_with_monitoring.repository_url}"
    build = "docker build -t ${module.ecr_with_monitoring.repository_name} ."
    tag   = "docker tag ${module.ecr_with_monitoring.repository_name}:latest ${module.ecr_with_monitoring.repository_url}:latest"
    push  = "docker push ${module.ecr_with_monitoring.repository_url}:latest"
    pull  = "docker pull ${module.ecr_with_monitoring.repository_url}:latest"
  }
}
