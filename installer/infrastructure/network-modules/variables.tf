# ------------------------------------------------------------------------------
# Core Network Configuration
# ------------------------------------------------------------------------------

variable "network_config" {
  description = <<-EOT
    List of VPCs to create, including subnets and transit destinations.
    Each object defines a VPC, its CIDR, environment, AZs, and optional subnets and transit destinations.

    - vpc_name: Unique name for the VPC.
    - cidr_block: Primary CIDR block for the VPC (e.g., 10.0.0.0/16).
    - environment: Environment tag (e.g., dev, prod).
    - azs: List of Availability Zones for subnet distribution.
    - enable_vpc_endpoints: (Optional) Whether to create VPC endpoints (default: true).
    - long_kubernetes_cluster_name: (Optional) Used for EKS subnet tagging and discovery.
    - subnets: (Optional) List of subnet objects for this VPC.
      - name: (Optional) Subnet name.
      - cidr_block: (Optional) Subnet CIDR block.
      - az: (Optional) Availability Zone for the subnet.
      - purpose: (Optional) Purpose tag (e.g., Kubernetes, Database).
      - tier: (Optional) Tier tag (e.g., Public, Private).
    - transit_destinations: (Optional) List of destination VPCs for TGW/DNS rules.
      - dest_vpc_name: Name of the destination VPC.
      - dest_cidr_block: CIDR block of the destination VPC.
      - dest_environment: Environment of the destination VPC.
      - dest_azs: List of AZs in the destination VPC.
  EOT
  type = list(object({
    vpc_name              = string
    cidr_block            = string
    environment           = string
    long_cluster_name     = optional(string, null)
    azs                   = list(string)
    enable_vpc_endpoints  = optional(bool, false)
    subnets = optional(list(object({
      name       = optional(string, null)
      cidr_block = optional(string, null)
      az         = optional(string, null)
      purpose    = optional(string, null)
      tier       = optional(string, null)
    })), [])
    transit_destinations = optional(list(object({
      dest_vpc_name    = string
      dest_cidr_block  = string
      dest_environment = string
      dest_azs         = list(string)
    })), [])
  }))
}

# ------------------------------------------------------------------------------
# AWS Region
# ------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "AWS region to create the VPCs and resources in (e.g., eu-central-1)."
}

# ------------------------------------------------------------------------------
# Disaster Recovery Role
# ------------------------------------------------------------------------------

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster Recovery Role for VPCs (e.g., active, passive)."
}

# ------------------------------------------------------------------------------
# Transit Gateway ASN
# ------------------------------------------------------------------------------

variable "amazon_side_asn" {
  type        = number
  description = "Amazon side ASN for the transit gateway (must be unique in your AWS Org)."
  default     = 64512
}

# ------------------------------------------------------------------------------
# Owner Tag
# ------------------------------------------------------------------------------

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team for resource tagging."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use unique CIDR blocks for each VPC to avoid routing conflicts.
# - Define subnets and AZs explicitly for high availability and clear architecture.
# - Use the 'enable_vpc_endpoints' flag to control endpoint creation per VPC.
# - Use 'long_kubernetes_cluster_name' for EKS auto-discovery if deploying Kubernetes.
# - Document variable structure in your README for easy onboarding and maintenance.
# ------------------------------------------------------------------------------
