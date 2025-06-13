# ------------------------------------------------------------------------------
# Core Cluster Metadata
# ------------------------------------------------------------------------------

variable "long_cluster_name" {
  type        = string
  description = "Long name of the EKS cluster (used for identification and tagging)"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  nullable    = false
}

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role (e.g., primary, secondary)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Add-on Configuration Objects
# Each add-on variable is an object with required/optional fields.
# These allow you to pass version and IAM role ARNs for IRSA where needed.
# ------------------------------------------------------------------------------

variable "coredns" {
  type = object({
    version  = optional(string) # CoreDNS add-on version (e.g., "v1.11.4-eksbuild.10")
    role_arn = optional(string) # IAM role ARN for CoreDNS service account (IRSA)
  })
  # No default: must be provided
}

variable "kube_proxy" {
  type = object({
    version = optional(string) # kube-proxy add-on version (e.g., "v1.32.3-eksbuild.7")
  })
  default = null # Optional: can be omitted if not needed
}

variable "vpc_cni" {
  type = object({
    version  = optional(string) # VPC CNI add-on version (e.g., "v1.19.4-eksbuild.1")
    role_arn = optional(string) # IAM role ARN for VPC CNI service account (IRSA)
  })
  default = null # Optional: can be omitted if not needed
}

variable "efs_csi_driver" {
  type = object({
    version  = optional(string) # EFS CSI driver version (e.g., "v2.1.7-eksbuild.1")
    role_arn = optional(string) # IAM role ARN for EFS CSI service account (IRSA)
  })
  default = null # Optional: can be omitted if not needed
}

variable "ebs_csi_driver" {
  type = object({
    version  = optional(string) # EFS CSI driver version (e.g., "v2.1.7-eksbuild.1")
    role_arn = optional(string) # IAM role ARN for EFS CSI service account (IRSA)
  })
  default = null # Optional: can be omitted if not needed
}

variable "s3_csi_driver" {
  type = object({
    version  = optional(string) # S3 CSI driver version (e.g., "v1.13.0-eksbuild.1")
    role_arn = optional(string) # IAM role ARN for S3 CSI service account (IRSA)
  })
  default = null # Optional: can be omitted if not needed
}

variable "pod_identity_agent" {
  type = object({
    version = optional(string) # Pod Identity Agent add-on version (e.g., "v1.3.5-eksbuild.2")
  })
  default = null # Optional: can be omitted if not needed
}

variable "snapshot_controller" {
  type = object({
    version = optional(string)
  })
  default = null # Optional: can be omitted if not needed
}

# ------------------------------------------------------------------------------
# Notes:
# - The use of optional() allows you to omit fields if not needed.
# - Default = null means you do not need to specify the add-on if you do not want to install it.
# - For IRSA-enabled add-ons, supply the appropriate role ARN.
# - These variables are designed for use with aws_eks_addon resources for flexible EKS add-on management.
# ------------------------------------------------------------------------------
