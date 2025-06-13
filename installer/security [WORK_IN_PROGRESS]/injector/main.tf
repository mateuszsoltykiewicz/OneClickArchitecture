# modules/application/main.tf
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"               = "true"
          "vault.hashicorp.com/role"                       = var.vault_role
          "vault.hashicorp.com/agent-inject-secret-db.env" = var.vault_secret_path
          "vault.hashicorp.com/agent-inject-template-db.env" = <<-EOT
            {{- with secret "${var.vault_secret_path}" -}}
            export DB_USER="{{ .Data.username }}"
            export DB_PASS="{{ .Data.password }}"
            {{- end }}
          EOT
        }
      }

      spec {
        service_account_name = var.service_account_name

        container {
          name  = var.name
          image = var.image

          command = ["/bin/sh", "-c"]
          args    = ["source /vault/secrets/db.env && exec ${var.entrypoint}"]
        }
      }
    }
  }
}
