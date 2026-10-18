terraform {
  backend "s3" {
    bucket       = "terraform-aws-infra-state-devsanghavi-119"
    key          = "terraform-aws-infra/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
