# ------------------------------------------------------------------------------
# EKS DNS Record Variables
# ------------------------------------------------------------------------------

variable "short_cluster_name" {
  type        = string
  description = "Shortened name of the EKS cluster (used as DNS record prefix)"
  nullable    = false
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint (API server DNS name, target for CNAME record)"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Name of the environment (e.g., dev, staging, prod; used for DNS zone selection)"
  nullable    = false
}

variable "owner" {
  type        = string
  description = "Name of the setup owner (used for DNS zone selection)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Notes:
# - These variables are typically used to automate DNS record creation for EKS clusters.
# - 'short_cluster_name' should be unique within the selected DNS zone.
# - 'cluster_endpoint' should be a DNS name (not an IP address) for CNAME records.
# ------------------------------------------------------------------------------
