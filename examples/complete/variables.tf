variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Additional tags to add to all resources"
  type        = map(string)
  default     = {}
}
