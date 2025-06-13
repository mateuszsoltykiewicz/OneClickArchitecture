# ------------------------------------------------------------------------------
# Transit Gateway VPC Attachment Variables
# ------------------------------------------------------------------------------

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to attach to the Transit Gateway (typically one per AZ for high availability)."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to attach to the Transit Gateway."
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC (used for tagging and identification)."
}

variable "dr_role" {
  type        = string
  description = "Disaster recovery role for resource naming and tagging (e.g., active, passive)."
}

variable "aws_region" {
  type        = string
  description = "AWS region for resource tagging (e.g., eu-central-1)."
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the TGW VPC attachment for cost allocation, automation, and ownership tracking."
  default     = {}
}

variable "transit_gateway_id" {
  type        = string
  description = "ID of the Transit Gateway (TGW) to which the VPC will be attached."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Provide at least one subnet ID per AZ for high availability.
# - Use consistent and descriptive tagging for all resources.
# - Document required and optional variables in your module README for easy onboarding.
# ------------------------------------------------------------------------------
