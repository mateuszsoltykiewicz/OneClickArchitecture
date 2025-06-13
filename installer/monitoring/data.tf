data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_route53_zone" "selected" {
  name         = local.domain_name
  private_zone = false
}

data "aws_vpc" "selected" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  
  filter {
    name   = "tag:Purpose"
    values = ["Kubernetes"]
  }
}

data "aws_security_groups" "node_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:DisasterRecoveryRole"
    values = [var.disaster_recovery_role]
  }

  filter {
    name = "tag:Owner"
    values = [var.owner]
  }

  filter {
    name = "tag:Environment"
    values = [var.environment]
  }

  filter {
    name = "tag:Name"
    values = ["eks-cluster-sg-develop-develop-develop-digitalfirstai-active-eu-central-1-1026017574", "develop-develop-develop-digitalfirstai-active-eu-central-1-cluster"]
  }
}
