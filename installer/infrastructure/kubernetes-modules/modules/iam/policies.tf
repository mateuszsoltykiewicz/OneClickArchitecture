# ------------------------------------------------------------------------------
# Local configuration map for IAM policies
# ------------------------------------------------------------------------------
locals {
  iam_policies = {
    s3 = {
      name_prefix    = "s3-custom-policy"
      description    = "Grants access to specific S3 bucket for ${var.short_cluster_name}"
      policy_doc     = data.aws_iam_policy_document.s3_access.json
    }
    ecr = {
      name_prefix    = "ecr-pull-policy"
      description    = "Policy to allow pulling images from ECR"
      policy_doc     = data.aws_iam_policy_document.ecr_policy.json
    }
    custom_node = {
      name_prefix    = "eks-node-custom-policy"
      description    = "Custom policy for EKS worker nodes"
      policy_doc     = data.aws_iam_policy_document.custom_node.json
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Policies (DRY Version)
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "iam_policies" {
  for_each = { for k, policy in local.iam_policies : k => policy }

  name        = "${each.key}-policy-${var.long_cluster_name}"
  description = each.value.description
  policy      = each.value.policy_doc
}
