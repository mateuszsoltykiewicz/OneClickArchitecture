# modules/lease-watcher/main.tf
resource "kubernetes_deployment" "watcher" {
  metadata {
    name      = "vault-lease-watcher"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    template {
      metadata {
        labels = {
          app = "vault-lease-watcher"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.watcher.metadata[0].name
        
        container {
          name  = "watcher"
          image = "ghcr.io/myorg/lease-watcher:1.0.0"
          
          env {
            name  = "VAULT_ADDR"
            value = var.vault_address
          }
          
          env {
            name  = "WEBHOOK_URL"
            value = "http://rotation-webhook.${var.namespace}.svc.cluster.local"
          }
        }
      }
    }
  }
}
