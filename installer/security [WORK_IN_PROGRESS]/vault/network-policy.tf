resource "kubernetes_network_policy" "vault" {
  metadata {
    name      = "vault"
    namespace = var.namespace
  }
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "vault"
      }
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.namespace
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 8200
      }
    }
    egress {
      ports { 
        port = 53 
        protocol = "UDP" 
        } # DNS
    }
    policy_types = ["Ingress", "Egress"]
  }
}