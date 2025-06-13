# ------------------------------------------------------------------------------
# Variables for Private Route53 Hosted Zone Module
# ------------------------------------------------------------------------------

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod). Used for DNS zone naming and tagging."
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team. Used for DNS zone naming and tagging."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with the Route53 private zone for internal DNS resolution."
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources are deployed (e.g., eu-central-1)."
}

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role for the environment (e.g., primary, secondary)."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use descriptive variable names and comments for easy collaboration.
# - Ensure 'environment' and 'owner' are consistent across your infrastructure for clear DNS naming.
# - Always associate the private zone with the correct VPC to ensure resolvability.
# ------------------------------------------------------------------------------
