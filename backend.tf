terraform {
  backend "s3" {
    bucket       = "terraform-aws-infra-state-devsanghavi-119"
    key          = "terraform-aws-infra/terraform.tfstate"
    region       = "us-east-1"
    profile      = "cloudmentor-admin"
    encrypt      = true
    use_lockfile = true
  }
}
