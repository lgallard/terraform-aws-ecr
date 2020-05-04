module "ecr" {

  source = "git::https://github.com/lgallard/terraform-aws-ecr.git"

  name         = "ecr-repo-dev"
  scan_on_push = true

  # Tags
  tags = {
    Owner       = "DevOps team"
    Environment = "dev"
    Terraform   = true
  }

}
