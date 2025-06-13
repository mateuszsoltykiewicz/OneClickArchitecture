resource "vault_database_secret_backend_connection" "this" {
  for_each = var.databases

  backend = vault_mount.database.path
  name    = each.key

  dynamic "postgresql" {
    for_each = each.value.type == "postgresql" ? [1] : []
    content {
      connection_url = "postgresql://${each.value.username}:${each.value.password}@${each.value.endpoint}"
    }
  }

  dynamic "mongodb" {
    for_each = each.value.type == "mongodb" ? [1] : []
    content {
      connection_url = "mongodb://${each.value.username}:${each.value.password}@${each.value.endpoint}"
    }
  }
}