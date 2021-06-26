
provider "aws" {
  region  = lookup(var.aws_region, terraform.workspace)
  profile = lookup(var.aws_account, terraform.workspace)
}

/*
terraform {
  backend "s3" {
    profile              = "xxx"
    encrypt              = true
    bucket               = "xxx"
    dynamodb_table       = "xxx"
    region               = "eu-central-1"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "member-api-test"
  }
}
*/
