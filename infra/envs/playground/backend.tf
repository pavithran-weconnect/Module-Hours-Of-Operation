terraform {
  backend "s3" {
    bucket         = "tfstate-007660001995-eu-west-2"
    key            = "connect/playground/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
