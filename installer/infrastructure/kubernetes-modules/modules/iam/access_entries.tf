# ------------------------------------------------------------------------------
# Local variable: List of EKS admin users (just usernames, not full ARNs)
# ------------------------------------------------------------------------------
locals {
  eks_admin_users = [
    "m.soltykiewicz",
    "bartosz.pampuch",
    "patryk.loter",
    "patryk.najsarek"
  ]
}

# ------------------------------------------------------------------------------
# EKS Access Entries: One per admin user
# ------------------------------------------------------------------------------
resource "aws_eks_access_entry" "admin" {
  for_each      = toset(local.eks_admin_users)
  cluster_name  = var.long_cluster_name
  principal_arn = "arn:aws:iam::775292115464:user/${each.value}"
  type          = "STANDARD"
}

# ------------------------------------------------------------------------------
# EKS Access Policy Associations: Grant EKS admin policy to each user
# ------------------------------------------------------------------------------
resource "aws_eks_access_policy_association" "admin" {
  for_each      = toset(local.eks_admin_users)
  cluster_name  = var.long_cluster_name
  principal_arn = "arn:aws:iam::775292115464:user/${each.value}"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

# ------------------------------------------------------------------------------
# How to add/remove users:
# - Simply edit the local.eks_admin_users list above.
# - Terraform will add or remove access for those users accordingly.
# ------------------------------------------------------------------------------
