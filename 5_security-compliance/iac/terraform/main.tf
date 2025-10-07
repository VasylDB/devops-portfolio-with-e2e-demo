terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Deliberately permissive bucket for demo (will trigger Checkov warnings)
resource "aws_s3_bucket" "public_assets" {
  bucket = "${var.project}-public-assets-demo"
  tags = {
    Project = var.project
    Environment = "demo"
  }
}

resource "aws_s3_bucket_public_access_block" "public_assets" {
  bucket                  = aws_s3_bucket.public_assets.id
  block_public_acls       = false   # bad on purpose for demo
  block_public_policy     = false   # bad on purpose for demo
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# A safer private bucket
resource "aws_s3_bucket" "private_data" {
  bucket = "${var.project}-private-data-demo"
  tags = {
    Project = var.project
    Environment = "demo"
  }
}

resource "aws_s3_bucket_public_access_block" "private_data" {
  bucket                  = aws_s3_bucket.private_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
