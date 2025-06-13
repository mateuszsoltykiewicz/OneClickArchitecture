resource "vault_database_secret_backend_role" "this" {
  for_each = var.databases

  backend             = vault_mount.database.path
  name                = "${each.key}-role"
  db_name             = vault_database_secret_backend_connection.this[each.key].name
  creation_statements = each.value.statements
  default_ttl         = each.value.rotation
  max_ttl             = each.value.rotation * 2
}