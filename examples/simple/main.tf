module "ecr" {

  source = "git::https://github.com/lgallard/terraform-aws-ecr.git"

  name = "ecr-repo-dev"

  # Tags
  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
  }

}
