output "database_roles" {
  value = [for r in vault_database_secret_backend_role.this : r.name]
}