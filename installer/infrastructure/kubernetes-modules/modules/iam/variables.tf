# ------------------------------------------------------------------------------
# EKS Cluster Naming Variables
# ------------------------------------------------------------------------------

variable "long_cluster_name" {
  type        = string
  description = "Long EKS cluster name (used for AWS resource naming and tagging)"
  nullable    = false
}

variable "short_cluster_name" {
  type        = string
  description = "Short name of the EKS cluster (used for concise tags, DNS, etc.)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# EKS OIDC Integration Variables
# ------------------------------------------------------------------------------

variable "cluster_oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider ARN (used for IRSA and service account trust policies)"
  nullable    = false
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL (used for IRSA trust policy conditions, e.g., https://oidc.eks.region.amazonaws.com/id/...)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Notes:
# - These variables are essential for configuring IAM Roles for Service Accounts (IRSA).
# - The OIDC provider ARN and issuer URL are outputs from the EKS module or AWS Console.
# ------------------------------------------------------------------------------
