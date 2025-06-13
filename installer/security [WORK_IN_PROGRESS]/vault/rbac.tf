resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.iam_role_arn
    }
  }
}

resource "kubernetes_cluster_role" "vault" {
  metadata {
    name = "vault-${var.namespace}"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "secrets", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "vault" {
  metadata {
    name = "vault-${var.namespace}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vault.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = var.namespace
  }
}