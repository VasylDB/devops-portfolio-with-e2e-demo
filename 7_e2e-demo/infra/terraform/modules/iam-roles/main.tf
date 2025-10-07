terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = var.region }

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "gha_deploy" {
  name = "${var.name}-gha-deploy"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "gha_deploy_policy" {
  role = aws_iam_role.gha_deploy.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["eks:DescribeCluster"], Resource = "*" },
      { Effect = "Allow", Action = ["ecr:*"], Resource = "*" },
      { Effect = "Allow", Action = ["sts:GetCallerIdentity"], Resource = "*" },
      { Effect = "Allow", Action = ["iam:PassRole"], Resource = "*" }
    ]
  })
}

output "gha_role_arn" { value = aws_iam_role.gha_deploy.arn }
