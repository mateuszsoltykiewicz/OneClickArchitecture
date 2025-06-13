# ------------------------------------------------------------------------------
# VPC and Environment Variables
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "VPC ID to which the Internet Gateway (IGW) will be attached."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC (used for tagging and resource identification)."
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g., dev, staging, prod)."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment (e.g., eu-central-1)."
}

# ------------------------------------------------------------------------------
# Resource Control and Tagging
# ------------------------------------------------------------------------------

variable "create_igw" {
  type        = bool
  description = "Whether to create an Internet Gateway (true/false)."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the IGW resource."
  default     = {}
}

# ------------------------------------------------------------------------------
# Ownership and Disaster Recovery
# ------------------------------------------------------------------------------

variable "owner" {
  type        = string
  description = "Owner of the setup or responsible team."
}

variable "dr_role" {
  type        = string
  description = "Disaster recovery role (e.g., active, passive, primary, secondary)."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use descriptive and consistent variable names for clarity.
# - Use the `tags` variable to apply organization-wide tags for cost allocation and automation.
# - Set `create_igw = false` by default to avoid accidental IGW creation in private-only architectures.
# - Document required and optional variables in your module README.
# ------------------------------------------------------------------------------
