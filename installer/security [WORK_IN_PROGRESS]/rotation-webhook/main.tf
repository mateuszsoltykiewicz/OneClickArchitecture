# modules/webhook/main.tf
resource "kubernetes_deployment" "webhook" {
  metadata {
    name      = "rotation-webhook"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    template {
      metadata {
        labels = {
          app = "rotation-webhook"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.webhook.metadata[0].name
        
        container {
          name  = "webhook"
          image = "ghcr.io/myorg/rotation-webhook:1.0.0"
          
          port {
            container_port = 8080
          }
          
          env {
            name = "VAULT_ADDR"
            value = var.vault_address
          }
        }
      }
    }
  }
}