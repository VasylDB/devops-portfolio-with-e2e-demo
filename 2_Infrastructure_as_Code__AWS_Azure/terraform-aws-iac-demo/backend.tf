terraform {
  backend "s3" {
    bucket = "vbdubenchuk-terraform-state-bucket"
    key = "iac-demo/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}