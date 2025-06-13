      # ------------------------------------------------------------------------------
# Core VPC Endpoint Variables
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "VPC ID where the endpoints will be created."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC (used for tagging and resource identification)."
}

variable "aws_region" {
  type        = string
  description = "AWS Region for endpoint creation (e.g., eu-central-1)."
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g., dev, staging, prod) for resource tagging."
}

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role (e.g., active, passive) for resource tagging."
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all VPC endpoints for cost allocation, automation, and ownership tracking."
  default     = {}
}

# ------------------------------------------------------------------------------
# VPC Endpoint Definitions
# ------------------------------------------------------------------------------

variable "vpc_endpoints" {
  type = list(object({
    service_name = string              # AWS service short name (e.g., "s3", "ec2", "eks")
    service_type = string              # Endpoint type: "Gateway" or "Interface"
    policy       = string              
  }))
  description = <<-EOT
    List of VPC endpoints to create.
    - service_name: Short AWS service name (e.g., "s3", "ecr.dkr", "ec2").
    - service_type: "Gateway" or "Interface".
    - policy: "policy to be applied for the endpoint"
    Example:
      [
        { service_name = "s3", service_type = "Gateway" },
        { service_name = "ec2", service_type = "Interface" }
      ]
  EOT
  default = [
    { service_name = "s3",                service_type = "Gateway",   policy = null },
    { service_name = "ecr.dkr",           service_type = "Interface", policy = null },
    { service_name = "ecr.api",           service_type = "Interface", policy = null },
    { service_name = "eks",               service_type = "Interface", policy = null },
    { service_name = "ec2",               service_type = "Interface", policy = null },
    { service_name = "sts",               service_type = "Interface", policy = null },
    { service_name = "elasticfilesystem", service_type = "Interface", policy = null },
    { service_name = "rds",               service_type = "Interface", policy = null },
    { service_name = "elasticache",       service_type = "Interface", policy = null }
  ]
  nullable = false
}

# ------------------------------------------------------------------------------
# Networking and Security
# ------------------------------------------------------------------------------

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for interface endpoints (must be in the same AZs as the VPC)."
  default     = []
}

variable "route_table_ids" {
  type        = list(string)
  description = "List of route table IDs for gateway endpoints (e.g., for S3)."
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with interface endpoints."
  nullable    = false
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure subnet_ids and security_group_ids are provided for interface endpoints.
# - Ensure route_table_ids are provided for gateway endpoints.
# - Use clear and consistent service_name and service_type values.
# - Use the tags variable for consistent organization-wide tagging.
# - Document required and optional variables in your module README for easy onboarding.
# ------------------------------------------------------------------------------
