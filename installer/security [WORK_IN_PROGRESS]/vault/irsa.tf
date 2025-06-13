module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.0"

  role_name = "vault-auto-unseal"
  role_policy_arns = [aws_iam_policy.vault.arn]

  oidc_providers = [{
    provider_arn               = var.oidc_provider_arn
    namespace_service_accounts = ["${var.namespace}:vault"]
  }]
}