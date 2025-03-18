# Example demonstrating repository protection
module "ecr" {
  source = "../.."

  name                 = "ecr-repo-protected"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false # Prevent accidental deletion of images
  prevent_destroy      = true  # Protect repository from being destroyed via Terraform
  encryption_type      = "KMS" # Enable encryption

  image_scanning_configuration = {
    scan_on_push = true # Enable security scanning
  }

  # Repository policy that prevents deletion
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDelete"
        Effect = "Deny"
        Principal = {
          AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
        Action = [
          "ecr:DeleteRepository",
          "ecr:DeleteRepositoryPolicy"
        ]
      },
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      }
    ]
  })

  # Tags
  tags = {
    Name        = "ecr-repo-protected"
    Environment = "production"
    Protected   = "true"
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# Get AWS account ID for policy ARNs
data "aws_caller_identity" "current" {}
