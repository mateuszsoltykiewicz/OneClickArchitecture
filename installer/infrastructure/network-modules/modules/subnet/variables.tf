# ------------------------------------------------------------------------------
# Core VPC Identification
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where subnets and associated resources will be created."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC (used in resource tagging and naming)."
}

variable "long_cluster_name" {
  type = string
  description = "Extended name of the EKS cluster"
}

# ------------------------------------------------------------------------------
# Disaster Recovery & Environment Metadata
# ------------------------------------------------------------------------------

variable "dr_role" {
  type        = string
  description = "Disaster recovery role (e.g., active, passive) for tagging and identification."
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g., dev, staging, prod) for resource tagging."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment and tagging (e.g., eu-central-1)."
}

variable "owner" {
  type        = string
  description = "Owner or responsible team for the setup (used in resource tagging)."
}

# ------------------------------------------------------------------------------
# Transit Gateway Integration
# ------------------------------------------------------------------------------

variable "transit_gateway_id" {
  type        = string
  description = "ID of the Transit Gateway for private subnet routes (optional, for hybrid/multi-VPC networking)."
}

variable "transit_gateway" {
  type        = bool
  description = "Whether a Transit Gateway is enabled and should be used for private subnet routing."
}

# ------------------------------------------------------------------------------
# Internet Gateway Integration
# ------------------------------------------------------------------------------

variable "internet_gateway_id" {
  type        = string
  description = "ID of the Internet Gateway for public subnet routes (optional)."
}

variable "internet_gateway" {
  type        = bool
  description = "Whether an Internet Gateway is enabled and should be used for public subnet routing."
}

# ------------------------------------------------------------------------------
# Subnet Configuration
# ------------------------------------------------------------------------------

variable "subnets" {
  type = list(object({
    name       = string   # Unique name for the subnet
    cidr_block = string   # CIDR block for the subnet
    purpose    = string   # Purpose (e.g., Kubernetes, Database, Transit)
    tier       = string   # Tier (e.g., Public, Private)
    az         = string   # Availability Zone (e.g., eu-central-1a)
  }))
  description = "List of subnet configurations (typically loaded from YAML or a higher-level variable)."
}

# ------------------------------------------------------------------------------
# Tagging
# ------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources for cost allocation, automation, and ownership tracking."
  default     = {}
}

# ------------------------------------------------------------------------------
# Kubernetes Cluster Integration
# ------------------------------------------------------------------------------

variable "long_kubernetes_cluster_name" {
  type        = string
  description = "Optional: Long name of the Kubernetes cluster for subnet tagging (enables Kubernetes auto-discovery)."
  default     = null
}

# ------------------------------------------------------------------------------
# Notes:
# - Ensure that 'subnets' are consistently tagged with 'tier' and 'purpose' for downstream filtering.
# - Set 'transit_gateway' and 'internet_gateway' to true only if those gateways are present and should be used.
# - 'long_kubernetes_cluster_name' enables Kubernetes to discover subnets automatically when using EKS.
# ------------------------------------------------------------------------------
