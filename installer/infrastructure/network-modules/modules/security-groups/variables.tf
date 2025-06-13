# ------------------------------------------------------------------------------
# Core VPC and Environment Variables
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group creation."
}

variable "vpc_name" {
  type        = string
  description = "VPC name for resource tagging and identification."
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g., dev, staging, prod)."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment (e.g., eu-central-1)."
}

variable "dr_role" {
  type        = string
  description = "Disaster recovery role for resource naming and tagging (e.g., primary, secondary)."
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team."
}

# ------------------------------------------------------------------------------
# Tagging
# ------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources. Use for cost allocation, automation, and ownership tracking."
  default     = {}
}

# ------------------------------------------------------------------------------
# Transit Destinations Configuration
# Used for cross-VPC or hybrid network security group rules.
# ------------------------------------------------------------------------------

variable "transit_destinations" {
  type = list(object({
    dest_vpc_name    = string   # Unique name for the destination VPC
    dest_cidr_block  = string   # CIDR block of the destination VPC
    dest_environment = string   # Environment tag of the destination (e.g., prod)
    dest_azs         = list(string) # List of AZs in the destination VPC
  }))
  description = "Transit destinations for security group rules. Used for cross-VPC or hybrid network scenarios."
  default     = []
}

# ------------------------------------------------------------------------------
# Feature Toggles for Security Groups
# Enable/disable creation of specific security groups for modular deployments.
# ------------------------------------------------------------------------------

variable "enable_private_security_group" {
  type        = bool
  description = "Whether to create a private security group for internal/cross-VPC communication."
  default     = true
  nullable    = false
}

variable "enable_public_security_group" {
  type        = bool
  description = "Whether to create a public (internet-facing) security group."
  default     = true
  nullable    = false
}

variable "enable_vpc_endpoints" {
  type        = bool
  description = "Whether to create a security group for VPC endpoints."
  default     = true
  nullable    = false
}

variable "dns" {
  type        = bool
  description = "Whether to create a DNS security group."
  default     = false
}

variable "enable_dns_security_group" {
  type        = bool
  description = "Whether to create a DNS security group (legacy/compatibility toggle)."
  default     = true
  nullable    = false
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use feature toggles to control which security groups are created for each VPC/module instance.
# - Use the `transit_destinations` variable to automate secure cross-VPC or hybrid cloud networking.
# - Use clear, consistent tagging for all resources for cost allocation and compliance.
# - Document all variables and defaults in your module README for easy onboarding.
# ------------------------------------------------------------------------------
