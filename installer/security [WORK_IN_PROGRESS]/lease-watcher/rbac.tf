resource "kubernetes_service_account" "watcher" {
  metadata {
    name      = "vault-lease-watcher"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "watcher" {
  metadata {
    name = "vault-lease-watcher"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "watcher" {
  metadata {
    name = "vault-lease-watcher"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.watcher.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.watcher.metadata[0].name
    namespace = var.namespace
  }
}