terraform {
  backend "s3" {
    bucket = "tfstate-007660001995-eu-west-2"
    key    = "module-hours-of-operation/playground/terraform.tfstate"
    region = "eu-west-2"
  }
}
