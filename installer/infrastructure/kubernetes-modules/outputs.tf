# ------------------------------------------------------------------------------
# Output: Long Cluster Names (Map)
# Returns a map of long cluster names keyed by cluster identifier.
# ------------------------------------------------------------------------------
output "long_cluster_name" {
  description = "Map of long, unique names for all EKS cluster instances."
  value = {
    for k, mod in module.cluster : k => mod.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# Output: Cluster Endpoints (Map)
# Returns a map of Kubernetes API endpoints keyed by cluster identifier.
# ------------------------------------------------------------------------------
output "cluster_endpoint" {
  description = "Map of Kubernetes API server endpoints for all EKS clusters."
  value = {
    for k, mod in module.cluster : k => mod.cluster_endpoint
  }
}

# ------------------------------------------------------------------------------
# Output: Cluster Certificate Authority Data (Map)
# Returns a map of base64-encoded CA data for all clusters.
# ------------------------------------------------------------------------------
output "cluster_certificate_authority_data" {
  description = "Map of base64-encoded certificate authority data for all EKS clusters."
  value = {
    for k, mod in module.cluster : k => mod.cluster_certificate_authority_data
  }
}

# ------------------------------------------------------------------------------
# Output: OIDC Provider ARNs (Map)
# Returns a map of OIDC provider ARNs for all clusters.
# ------------------------------------------------------------------------------
output "oidc_provider_arn" {
  description = "Map of OIDC provider ARNs for all EKS clusters (used for IRSA)."
  value = {
    for k, mod in module.cluster : k => mod.oidc_provider_arn
  }
}

# ------------------------------------------------------------------------------
# Output: node security group id (Map)
# Returns a map of node security group id for all clusters.
# ------------------------------------------------------------------------------
output "node_security_group_id" {
    value = {
    for k, mod in module.security : k => mod.node_security_group_id
  }
}

# ------------------------------------------------------------------------------
# Output: control plane security group id (Map)
# Returns a map of control plane security group id for all clusters.
# ------------------------------------------------------------------------------
output "control_plane_security_group_id" {
    value = {
    for k, mod in module.security : k => mod.control_plane_security_group_id
  }
}

output "vpc_name" {
    value = {
    for k, mod in module.cluster : k => mod.vpc_name
  } 
}


# ------------------------------------------------------------------------------
# Usage Tips:
# - Access any cluster's output with: terraform output cluster_endpoints["your-cluster-key"]
# - This pattern is future-proof and supports dynamic environments with many clusters.
# - You can still output a single cluster by referencing its key, e.g.:
#     output "my_cluster_endpoint" {
#       value = module.cluster["my-cluster-key"].cluster_endpoint
#     }
# ------------------------------------------------------------------------------
