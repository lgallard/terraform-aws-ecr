output "repository_name" {
  value = module.ecr_monitoring.repository_name
}

output "repository_url" {
  value = module.ecr_monitoring.repository_url
}

output "repository_arn" {
  value = module.ecr_monitoring.repository_arn
}

output "monitoring_status" {
  value = module.ecr_monitoring.monitoring_status
}

output "sns_topic_arn" {
  value = module.ecr_monitoring.sns_topic_arn
}

output "cloudwatch_alarms" {
  value = module.ecr_monitoring.cloudwatch_alarms
}