# ----------------------------------------------------------
# Example Variables for Pull Request Rules
# ----------------------------------------------------------

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "example-pr-rules-repo"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for notifications. If not provided, a topic will be created."
  type        = string
  default     = null
}

variable "notification_emails" {
  description = "List of email addresses for notifications"
  type        = list(string)
  default     = []
}

variable "enable_ci_integration" {
  description = "Whether to enable CI integration pull request rule"
  type        = bool
  default     = true
}

variable "ci_webhook_url" {
  description = "Webhook URL for CI integration notifications"
  type        = string
  default     = null
}
