data "aws_eks_cluster" "cluster" {
  name = local.config.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.config.cluster_name
}