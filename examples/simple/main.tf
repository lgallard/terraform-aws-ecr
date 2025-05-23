module "ecr" {
  source = "../../"

  name                 = var.name
  scan_on_push         = true        # Enable security scanning
  image_tag_mutability = "IMMUTABLE" # Prevent tag overwrites
  force_delete         = false       # Prevent accidental deletion

  encryption_type = "KMS" # Enable encryption

  # Tags
  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
    ManagedBy   = "Terraform"
    Project     = "ECR"
  }
}
