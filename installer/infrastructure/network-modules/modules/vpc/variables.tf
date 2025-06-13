# ------------------------------------------------------------------------------
# VPC Module Variables
# ------------------------------------------------------------------------------

variable "vpc_name" {
  type        = string
  description = "Name of the VPC (from YAML or higher-level configuration). Used for tagging and resource identification."
}

variable "cidr_block" {
  type        = string
  description = "Primary CIDR block for the VPC (e.g., 10.0.0.0/16). Ensure this does not overlap with other VPCs in your environment."
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g., eks, monitoring, dev, prod) for resource tagging and organization."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment and tagging (e.g., eu-central-1)."
}

variable "dr_role" {
  type        = string
  description = "Disaster recovery role for resource naming and tagging (e.g., active, passive)."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the VPC for cost allocation, automation, and ownership tracking."
  default     = {}
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team for resource tagging and accountability."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use descriptive and consistent variable names and descriptions for clarity.
# - Always provide a unique CIDR block for each VPC to avoid routing conflicts.
# - Use the 'tags' variable to enforce organization-wide tagging standards.
# - Document required and optional variables in your module README for easy onboarding.
# ------------------------------------------------------------------------------
