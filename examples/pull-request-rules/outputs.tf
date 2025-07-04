# ----------------------------------------------------------
# Example Outputs for Pull Request Rules
# ----------------------------------------------------------

output "repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr_with_pr_rules.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr_with_pr_rules.repository_arn
}

output "pull_request_rules" {
  description = "Pull request rules configuration"
  value       = module.ecr_with_pr_rules.pull_request_rules
}

output "notification_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = var.notification_topic_arn != null ? var.notification_topic_arn : try(aws_sns_topic.ecr_notifications[0].arn, null)
}

output "approval_role_arn" {
  description = "ARN of the ECR approval role"
  value       = aws_iam_role.ecr_approval_role.arn
}

output "example_docker_commands" {
  description = "Example Docker commands for working with the repository"
  value = {
    login = "aws ecr get-login-password --region ${data.aws_region.current.id} | docker login --username AWS --password-stdin ${module.ecr_with_pr_rules.repository_url}"
    build = "docker build -t ${module.ecr_with_pr_rules.repository_name}:latest ."
    tag   = "docker tag ${module.ecr_with_pr_rules.repository_name}:latest ${module.ecr_with_pr_rules.repository_url}:latest"
    push  = "docker push ${module.ecr_with_pr_rules.repository_url}:latest"
  }
}

output "example_approval_workflow" {
  description = "Example workflow for approving images"
  value = {
    description = "To approve an image for production use:"
    steps = [
      "1. Push image to ECR repository",
      "2. Wait for security scan completion",
      "3. Review scan results and approve if acceptable",
      "4. Tag image with ApprovalStatus=approved",
      "5. Image is now available for production use"
    ]
    tag_command = "aws ecr put-image --repository-name ${module.ecr_with_pr_rules.repository_name} --image-tag <image-tag> --tag-list Key=ApprovalStatus,Value=approved"
  }
}
