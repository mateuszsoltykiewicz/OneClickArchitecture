# ------------------------------------------------------------------------------
# Core Naming and Environment Variables
# ------------------------------------------------------------------------------

variable "long_cluster_name" {
  type        = string
  description = "Long name of the EKS Cluster (used for resource naming and tagging)"
  nullable    = false
}

variable "long_vpc_name" {
  type        = string
  description = "Long name of the VPC (used to select the correct VPC by tag)"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
  nullable    = false
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team"
  nullable    = false
}

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role (e.g., primary, secondary)"
  nullable    = false
}

variable "aws_region" {
  type        = string
  description = "AWS Region for resource deployment (e.g., eu-central-1)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Security Group Creation Control
# ------------------------------------------------------------------------------

variable "create_security_group" {
  type        = bool
  description = "Whether to create security groups for the EKS cluster and nodes"
  default     = true
  nullable    = false
}

# ------------------------------------------------------------------------------
# Common Tags for All Resources
# ------------------------------------------------------------------------------

# In security/variables.tf
variable "tags" {
  type    = map(string)
  default = {}
}


# ------------------------------------------------------------------------------
# Notes:
# - These variables are typically used for tagging, resource selection, and conditional logic in modules.
# - 'create_security_group' allows you to skip SG creation if you want to use existing security groups.
# ------------------------------------------------------------------------------
