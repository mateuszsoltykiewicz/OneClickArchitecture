data "aws_iam_policy_document" "vault" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [var.kms_key_arn]
  }
}