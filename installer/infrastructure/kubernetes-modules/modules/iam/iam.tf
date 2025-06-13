# ------------------------------------------------------------------------------
# Local configuration map for IAM roles
# ------------------------------------------------------------------------------
locals {
  irsa_roles = {
    coredns = {
      name_suffix    = "coredns-irsa"
      namespace      = "kube-system"
      service_account = "coredns"
    }
    vpc_cni = {
      name_suffix    = "vpc-cni-irsa"
      namespace      = "kube-system"
      service_account = "aws-node"
    }
    efs_csi = {
      name_suffix    = "efs-csi-irsa"
      namespace      = "kube-system"
      service_account = "efs-csi-controller-sa"
    }
    ebs_csi = {
      name_suffix    = "ebs-csi-irsa"
      namespace      = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
    s3_csi = {
      name_suffix    = "s3-csi-driver-irsa"
      namespace      = "kube-system"
      service_account = "s3-csi-driver-sa"
    }
    pod_ecr_pull = {
      name_suffix    = "pod-ecr-pull-irsa"
      namespace      = "default"
      service_account = "ecr-access"
    }
  }

  pod_identity_role = {
    name_suffix = "pod-identity-role"
    principal   = "pods.eks.amazonaws.com"
  }
}

# ------------------------------------------------------------------------------
# IAM Roles for IRSA (IAM Roles for Service Accounts)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "irsa_roles" {
  for_each = local.irsa_roles

  name = substr(
    "eks-${each.value.name_suffix}-${var.long_cluster_name}",
    0,
    64
  )

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
          }
        }
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# IAM Role for Pod Identity (EKS Pod Identity)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "pod_identity_role" {
  name = substr(
    "eks-${local.pod_identity_role.name_suffix}-${var.long_cluster_name}",
    0,
    64
  )

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = local.pod_identity_role.principal
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}
