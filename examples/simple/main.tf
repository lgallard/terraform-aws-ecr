module "ecr" {

  source = "lgallard/ecr/aws"

  name = "ecr-repo-dev"

  # Tags
  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
  }

}
