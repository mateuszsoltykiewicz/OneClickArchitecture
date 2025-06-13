# ------------------------------------------------------------------------------
# IAM Policy Document: S3 Access
# Allows Get, Put, and List actions on all S3 buckets and objects.
# Use this for service accounts or roles that need to read/write to S3.
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = ["*"] # Consider restricting to specific buckets for tighter security
  }
}

# ------------------------------------------------------------------------------
# IAM Policy Document: ECR Pull Access
# Allows actions necessary for pulling images from Amazon ECR.
# Use this for service accounts or nodes that need to pull container images.
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "ecr_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"] # Consider restricting to specific ECR repositories if possible
  }
}

# ------------------------------------------------------------------------------
# IAM Policy Document: Custom Node Policy
# Allows describing EC2 instances and Auto Scaling groups.
# Useful for custom node group automation or monitoring.
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "custom_node" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "autoscaling:DescribeAutoScalingGroups"
    ]
    resources = ["*"]
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - For production, restrict "resources" to specific ARNs (buckets, repos, etc.) instead of "*".
# - Attach these policies to roles using aws_iam_policy and aws_iam_role_policy_attachment.
# - Always use least privilege: only grant actions and resources that are truly required.
# ------------------------------------------------------------------------------
