resource "helm_release" "apps" {
  for_each = toset(var.apps)  # Convert list to set for iteration

  name       = each.value
  chart      = "../helm-charts/${each.value}"  # Path to local chart directory
  namespace  = var.namespace
  create_namespace = true

  set {
    name = "namespace.name"
    value = var.namespace
  }

  values = file()
}