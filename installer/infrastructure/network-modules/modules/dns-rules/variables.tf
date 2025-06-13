# ------------------------------------------------------------------------------
# Route53 Resolver Rule Variables
# ------------------------------------------------------------------------------

variable "resolver_outbound_id" {
  type        = string
  description = "ID of the outbound Route53 resolver endpoint (used for forwarding rules). Typically an output from the resolver endpoint module."
}

variable "resolver_inbound_ips" {
  type        = list(string)
  description = "List of IP addresses for inbound resolver endpoints in the destination VPC(s). Used as target IPs for forwarding rules."
}

# ------------------------------------------------------------------------------
# Environment, Tagging, and Ownership
# ------------------------------------------------------------------------------

variable "dr_role" {
  type        = string
  description = "Disaster recovery role (e.g., primary, secondary, standby)."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources. Use for cost allocation, automation, and ownership tracking."
  default     = {}
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment (e.g., eu-central-1)."
}

# ------------------------------------------------------------------------------
# Transit Destination Configuration
# Each entry describes a VPC to which DNS queries will be forwarded.
# ------------------------------------------------------------------------------

variable "transit_destinations" {
  type = list(object({
    dest_vpc_name    = string   # Unique identifier for the destination VPC (used as map key)
    dest_cidr_block  = string   # CIDR block of the destination VPC (for documentation/rules)
    dest_environment = string   # Environment tag of the destination (e.g., prod, dev)
    dest_azs         = list(string) # List of AZs in the destination VPC (for documentation/HA)
  }))
  default = []
  description = <<-EOT
    List of destination VPCs for DNS forwarding.
    Each object should specify:
      - dest_vpc_name: Unique name for the destination VPC
      - dest_cidr_block: CIDR block of the destination VPC
      - dest_environment: Environment of the destination (e.g., prod)
      - dest_azs: List of AZs in the destination VPC
  EOT
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure resolver_inbound_ips contains at least two IPs from different AZs for HA.
# - dest_vpc_name must be unique for each destination to avoid rule conflicts.
# - Use clear, consistent naming for environments and VPCs.
# - Document any cross-account or cross-region requirements for DNS forwarding.
# ------------------------------------------------------------------------------
