resource "aws_iam_policy" "vault" {
  name        = "vault-auto-unseal"
  description = "Vault KMS permissions"
  policy      = data.aws_iam_policy_document.vault.json
}