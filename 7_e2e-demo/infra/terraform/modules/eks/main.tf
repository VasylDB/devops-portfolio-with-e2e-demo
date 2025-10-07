terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = var.region }

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.cluster_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [var.cluster_role_attachment_arns]
}

resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

output "cluster_name" { value = aws_eks_cluster.this.name }
