output "service_account_name" {
  value       = kubernetes_service_account.vault.metadata[0].name
  description = "Vault ServiceAccount name"
}

output "rbac_role_name" {
  value       = kubernetes_cluster_role.vault.metadata[0].name
  description = "ClusterRole name for Vault"
}
