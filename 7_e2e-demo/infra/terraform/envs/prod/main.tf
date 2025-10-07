module "vpc" {
  source = "../../modules/vpc"
  name   = "e2e-prod"
  cidr   = var.cidr
  region = var.region
}

# Minimal IAM roles for EKS simplified (inline for brevity)
resource "aws_iam_role" "eks_cluster" {
  name = "e2e-prod-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="eks.amazonaws.com"}, Action="sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node" {
  name = "e2e-prod-eks-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="ec2.amazonaws.com"}, Action="sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

module "eks" {
  source = "../../modules/eks"
  name   = "e2e-prod-eks"
  region = var.region
  subnet_ids = module.vpc.public_subnet_ids
  cluster_role_arn = aws_iam_role.eks_cluster.arn
  cluster_role_attachment_arns = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy.arn
  ]
  node_role_arn = aws_iam_role.eks_node.arn
}

module "iam_roles" {
  source = "../../modules/iam-roles"
  name   = "e2e-prod"
  region = var.region
  github_owner = var.github_owner
  github_repo  = var.github_repo
}

module "ecr" {
  source   = "../../modules/ecr"
  region   = var.region
  repo_name = "service-api"
}

output "cluster_name" { value = module.eks.cluster_name }
output "gha_role_arn" { value = module.iam_roles.gha_role_arn }
output "ecr_url"      { value = module.ecr.repository_url }
output "vpc_id"       { value = module.vpc.vpc_id }
