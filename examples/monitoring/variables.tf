variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-app-with-monitoring"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-project"
}

variable "owner" {
  description = "Owner of the repository"
  type        = string
  default     = "platform-team"
}

variable "storage_threshold_gb" {
  description = "Storage threshold in GB for CloudWatch alarm"
  type        = number
  default     = 5
}

variable "api_calls_threshold" {
  description = "API calls threshold per minute for CloudWatch alarm"
  type        = number
  default     = 500
}

variable "security_findings_threshold" {
  description = "Security findings threshold for CloudWatch alarm"
  type        = number
  default     = 5
}

variable "notification_emails" {
  description = "List of email addresses for SNS notifications"
  type        = list(string)
  default     = []
  
  validation {
    condition = length(var.notification_emails) > 0
    error_message = "At least one notification email must be provided for this example."
  }
}