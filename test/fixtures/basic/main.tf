provider "aws" {
  region = var.region
}

module "ecr" {
  source = "../../../"

  name                 = var.name
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true # Set to true for tests to ensure clean teardown

  tags = {
    Environment = "test"
    Terraform   = "true"
    Test        = "true"
  }
}