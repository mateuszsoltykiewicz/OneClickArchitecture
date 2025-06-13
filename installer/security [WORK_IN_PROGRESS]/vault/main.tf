resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
    labels = {
      "pod-security.kubernetes.io/enforce" = "baseline"
    }
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.28.0"
  namespace  = kubernetes_namespace.this.metadata[0].name

  values = [<<EOT
server:
  serviceAccount:
    create: false
    name: vault
  ha:
    enabled: false
  standalone:
    config: |
      seal "awskms" {
        region    = "${var.aws_region}"
        kms_key_id = "${var.kms_key_arn}"
      }
  dataStorage:
    enabled: true
    size: 1Gi
    storageClass: "${var.storage_class}"
  securityContext:
    runAsNonRoot: true
    runAsUser: 100
  EOT
  ]

  depends_on = [kubernetes_namespace.this]
}