terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = var.region }

resource "aws_ecr_repository" "app" {
  name = var.repo_name
  image_scanning_configuration { scan_on_push = true }
  lifecycle_policy {
    policy = jsonencode({
      rules = [{
        rulePriority = 1,
        description  = "Expire untagged after 7 days",
        selection    = { tagStatus = "untagged", countType = "sinceImagePushed", countNumber = 7, countUnit = "days" },
        action       = { type = "expire" }
      }]
    })
  }
}

output "repository_url" { value = aws_ecr_repository.app.repository_url }
