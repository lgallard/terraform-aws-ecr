terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
  }
}

module "ecr_test" {
  source = "./"
  name   = "test-repo"
}
