terraform {
  backend "s3" {
    bucket = "e2e-demo-tfstate"
    key    = "staging/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "e2e-demo-tflock"
    encrypt = true
  }
}
