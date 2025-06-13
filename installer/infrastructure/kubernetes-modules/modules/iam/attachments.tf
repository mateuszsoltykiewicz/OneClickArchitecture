# ------------------------------------------------------------------------------
# Attach AmazonEKS_CNI_Policy to CoreDNS IRSA Role
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "coredns_policy" {
  for_each    = { for role in aws_iam_role.irsa_roles : role.name => role if strcontains(role.name, "coredns-irsa") }
  
  role        = each.key
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on  = [aws_iam_role.irsa_roles]
}

# ------------------------------------------------------------------------------
# Attach AmazonEKS_CNI_Policy to VPC CNI IRSA Role
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "vpc_cni_policy" {
  for_each    = { for role in aws_iam_role.irsa_roles : role.name => role if strcontains(role.name, "vpc-cni-irsa") }
  
  role       = each.key
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on = [aws_iam_role.irsa_roles]
}

# ------------------------------------------------------------------------------
# Attach AmazonEFSCSIDriverPolicy to EFS CSI IRSA Role
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "efs_csi_policy" {
  for_each    = { for role in aws_iam_role.irsa_roles : role.name => role if strcontains(role.name, "efs-csi-irsa") }

  role       = each.key
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  depends_on = [aws_iam_role.irsa_roles]
}

# ------------------------------------------------------------------------------
# Attach Custom S3 Policy to S3 CSI IRSA Role
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "s3_csi_policy" {
  for_each    = { for role in aws_iam_role.irsa_roles : role.name => role if strcontains(role.name, "s3-csi-driver-irsa") }

  role       = each.key
  policy_arn = aws_iam_policy.iam_policies["s3"].arn
  depends_on = [aws_iam_role.irsa_roles, aws_iam_policy.iam_policies]
}

# ------------------------------------------------------------------------------
# Attach AmazonS3ReadOnlyAccess to Pod Identity Agent Role
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.pod_identity_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  depends_on = [aws_iam_role.pod_identity_role]
}

# ------------------------------------------------------------------------------
# Attach Custom ECR Pull Policy to Pod ECR Pull Role
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  for_each    = { for role in aws_iam_role.irsa_roles : role.name => role if strcontains(role.name, "pod-ecr-pull-irsa") }

  role       = each.key
  policy_arn = aws_iam_policy.iam_policies["ecr"].arn
  depends_on = [aws_iam_role.irsa_roles, aws_iam_policy.iam_policies]
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use explicit resource blocks for unique role/policy combinations.
# - Use for_each/map if you have many similar roles/policies to attach.
# - Always use depends_on when IAM policies or roles are created in the same plan.
# - Use descriptive resource names for clarity and maintainability.
# ------------------------------------------------------------------------------
