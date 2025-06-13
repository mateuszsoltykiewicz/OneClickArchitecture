resource "kubernetes_service_account" "webhook" {
  metadata {
    name      = "rotation-webhook"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "webhook" {
  metadata {
    name = "rotation-webhook"
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "webhook" {
  metadata {
    name = "rotation-webhook"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.webhook.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.webhook.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_service" "webhook" {
  metadata {
    name      = "rotation-webhook"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "rotation-webhook"
    }

    port {
      port        = 80
      target_port = 8080
    }
  }
}