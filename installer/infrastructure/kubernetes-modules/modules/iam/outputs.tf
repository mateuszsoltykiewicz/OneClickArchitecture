# ------------------------------------------------------------------------------
# Consolidated IRSA Role ARNs Output
# Provides all IRSA role ARNs in a single map for easy reference
# ------------------------------------------------------------------------------
output "irsa_role_arns" {
  value = {
    coredns     = try(aws_iam_role.irsa_roles["coredns"].arn, null)
    vpc_cni     = try(aws_iam_role.irsa_roles["vpc_cni"].arn, null)
    efs_csi     = try(aws_iam_role.irsa_roles["efs_csi"].arn, null)
    s3_csi      = try(aws_iam_role.irsa_roles["s3_csi"].arn, null)
    pod_ecr_pull = try(aws_iam_role.irsa_roles["pod_ecr_pull"].arn, null)
  }
  description = "ARNs of all IRSA roles for EKS add-ons"
}

# ------------------------------------------------------------------------------
# Pod Identity Role ARN (separate from IRSA roles)
# ------------------------------------------------------------------------------
output "pod_identity_role_arn" {
  value       = try(aws_iam_role.pod_identity_role.arn, null)
  description = "ARN of the pod identity role"
}

# ------------------------------------------------------------------------------
# Individual Outputs (if needed for backwards compatibility)
# ------------------------------------------------------------------------------
output "vpc_cni_role_arn" {
  value = try(aws_iam_role.irsa_roles["vpc_cni"].arn, null)
}

output "coredns_role_arn" {
  value = try(aws_iam_role.irsa_roles["coredns"].arn, null)
}

output "efs_csi_role_arn" {
  value = try(aws_iam_role.irsa_roles["efs_csi"].arn, null)
}

output "s3_csi_role_arn" {
  value = try(aws_iam_role.irsa_roles["s3_csi"].arn, null)
}
