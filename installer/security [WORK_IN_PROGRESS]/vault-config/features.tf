resource "vault_mount" "database" {
  path = "database"
  type = "database"
}