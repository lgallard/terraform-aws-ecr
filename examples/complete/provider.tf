provider "aws" {
  profile = "default"
  region  = "us-east-1"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
    }
  }
}
