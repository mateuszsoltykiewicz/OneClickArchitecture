# ------------------------------------------------------------------------------
# Output: EKS Control Plane Endpoint
# Provides the API server endpoint for the EKS cluster.
# ------------------------------------------------------------------------------
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

# ------------------------------------------------------------------------------
# Output: OIDC Issuer URL (Sensitive)
# URL used for IAM Roles for Service Accounts (IRSA) integration.
# Marked as sensitive to avoid accidental exposure.
# ------------------------------------------------------------------------------
output "cluster_oidc_issuer_url" {
  value     = module.eks.cluster_oidc_issuer_url
  sensitive = true
}

# ------------------------------------------------------------------------------
# Output: OIDC Provider ARN (Sensitive)
# The ARN of the OIDC provider for the EKS cluster, needed for IRSA.
# Marked as sensitive for security.
# ------------------------------------------------------------------------------
output "oidc_provider_arn" {
  value     = module.eks.oidc_provider_arn
  sensitive = true
}

# ------------------------------------------------------------------------------
# Output: Short Cluster Name
# The concise, human-friendly name for the cluster (used in DNS, tags, etc.).
# ------------------------------------------------------------------------------
output "short_cluster_name" {
  value = var.short_cluster_name
}

# ------------------------------------------------------------------------------
# Output: Long Cluster Name
# The full, unique name for the cluster as created in AWS.
# ------------------------------------------------------------------------------
output "long_cluster_name" {
  value = module.eks.cluster_name
}

# ------------------------------------------------------------------------------
# Output: Environment
# The environment (e.g., dev, staging, prod) for this cluster deployment.
# ------------------------------------------------------------------------------
output "environment" {
  value = var.environment
}

# ------------------------------------------------------------------------------
# Output: Owner
# The owner or team responsible for this cluster.
# ------------------------------------------------------------------------------
output "owner" {
  value = var.owner
}

# ------------------------------------------------------------------------------
# Output: Disaster Recovery Role
# The disaster recovery role classification for this cluster (e.g., primary, secondary).
# ------------------------------------------------------------------------------
output "disaster_recovery_role" {
  value = var.disaster_recovery_role
}

# ------------------------------------------------------------------------------
# Output: Cluster Certificate Authority Data
# The base64-encoded certificate authority data for the cluster, used to authenticate kubectl.
# ------------------------------------------------------------------------------
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "vpc_name" {
  value = var.long_vpc_name
}

# ------------------------------------------------------------------------------
# Notes:
# - Sensitive outputs (OIDC) are marked for security.
# - These outputs can be used for automation, CI/CD, or integration with other modules.
# - cluster_certificate_authority_data is needed for kubeconfig generation.
# ------------------------------------------------------------------------------
