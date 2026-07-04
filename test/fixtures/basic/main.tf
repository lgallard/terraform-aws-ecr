provider "aws" {
  region = var.region
}

module "ecr" {
  source = "../../../"

  name                 = var.name
  scan_on_push         = true
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
  image_tag_mutability_exclusion_filters = [
    {
      filter = "latest"
    }
  ]
  force_delete = true # Set to true for tests to ensure clean teardown

  tags = {
    Environment = "test"
    Terraform   = "true"
    Test        = "true"
  }
}
