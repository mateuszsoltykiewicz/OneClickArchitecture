# ------------------------------------------------------------------------------
# Transit Gateway Core Configuration
# ------------------------------------------------------------------------------

variable "amazon_side_asn" {
  type        = number
  description = "Private ASN (Autonomous System Number) for the Transit Gateway. Must be unique within your AWS environment. Used for BGP peering."
}

# ------------------------------------------------------------------------------
# Tagging and Metadata
# ------------------------------------------------------------------------------

variable "dr_role" {
  type        = string
  description = "Disaster recovery role for resource naming and tagging (e.g., active, passive)."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource tagging and identification (e.g., eu-central-1)."
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team (used for tagging and resource tracking)."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the Transit Gateway for cost allocation, automation, and ownership tracking."
  default     = {}
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use a unique ASN for each TGW in your AWS Organization to avoid BGP conflicts.
# - Use descriptive and consistent tagging for all resources.
# - Document required and optional variables in your module README for easy onboarding.
# ------------------------------------------------------------------------------
