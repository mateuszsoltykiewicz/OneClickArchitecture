# ------------------------------------------------------------------------------
# VPC and Networking Variables
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where Route53 resolver endpoints will be created."
}

variable "vpc_name" {
  type        = string
  description = "The name tag of the VPC. Used for tagging and resource identification."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC. (Useful for documentation or validation.)"
}

variable "private_azs" {
  type        = list(string)
  description = "List of private subnet IDs across different AZs for resolver endpoints. One subnet per AZ is recommended for high availability."
}

# Required Variable Additions/Changes:
variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs across AZs for resolver endpoints"
  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 subnets in different AZs required for HA."
  }
}

# ------------------------------------------------------------------------------
# Security & Access Variables
# ------------------------------------------------------------------------------

variable "security_group_id" {
  type        = string
  description = "Security group ID to associate with the resolver endpoints for network access control."
}

# ------------------------------------------------------------------------------
# Tagging & Ownership Variables
# ------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources. Use for cost allocation, automation, and ownership tracking."
  default     = {}
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team."
}

variable "dr_role" {
  type        = string
  description = "Disaster recovery role (e.g., primary, secondary, standby)."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment (e.g., eu-central-1)."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure private_azs contains subnet IDs, not AZ names.
# - Use descriptive and consistent tagging for all resources.
# - If you want to enforce at least 2 subnets for HA, add a validation block:
#   validation {
#     condition     = length(var.private_azs) >= 2
#     error_message = "At least 2 private subnets (in different AZs) are required for resolver endpoint HA."
#   }
# ------------------------------------------------------------------------------
