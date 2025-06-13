provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.infrastructure.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.role_arn
    session_name = "${var.disaster_recovery_role}-${var.environment}-bucket-${var.aws_region}-${var.owner}"
  }
}