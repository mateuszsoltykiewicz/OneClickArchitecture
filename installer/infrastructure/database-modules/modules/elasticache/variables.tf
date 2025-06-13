# ------------------------------------------------------------------------------
# Networking and Environment Variables
# ------------------------------------------------------------------------------

variable "vpc_name" {
  description = "VPC name"
  type        = string
  nullable    = false
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  nullable    = false
}

variable "disaster_recovery_role" {
  description = "Disaster recovery role (e.g., primary, secondary)"
  type        = string
  nullable    = false
}

variable "aws_region" {
  description = "AWS region (e.g., eu-central-1)"
  type        = string
  nullable    = false
}

# ------------------------------------------------------------------------------
# Cluster Naming Variables
# ------------------------------------------------------------------------------

variable "short_cluster_name" {
  description = "Short Name of the ElastiCache cluster (used for DNS, tags)"
  type        = string
  nullable    = false
}

variable "long_cluster_name" {
  description = "Full Name of the ElastiCache cluster (used for identifiers, tags)"
  type        = string
  nullable    = false
}

# ------------------------------------------------------------------------------
# ElastiCache Engine and Sizing Variables
# ------------------------------------------------------------------------------

variable "node_type" {
  description = "Node type for the ElastiCache cluster (e.g., cache.t4g.micro)"
  type        = string
  default     = "cache.t4g.micro"
  nullable    = false
}

variable "engine_version" {
  description = "Engine version for the ElastiCache cluster (e.g., 7.1)"
  type        = string
  default     = "7.1"
  nullable    = false
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (for non-cluster mode)"
  type        = number
  default     = 2
  nullable    = false
}

variable "num_node_groups" {
  type        = number
  description = "Number of node groups (for cluster mode)"
  default     = null
}

variable "replicas_per_node_group" {
  type        = number
  description = "Number of replicas per node group (for cluster mode)"
  default     = null
}

# ------------------------------------------------------------------------------
# Owner and Authentication
# ------------------------------------------------------------------------------

variable "owner" {
  type        = string
  description = "Name of the setup owner"
  nullable    = false
}

variable "username" {
  type        = string
  description = "Username for Redis AUTH (if required)"
  default     = "dfai"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Maintenance and Operational Settings
# ------------------------------------------------------------------------------

variable "mw" {
  type        = string
  description = "Maintenance window spec (e.g., sun:05:00-sun:09:00)"
  default     = "sun:05:00-sun:09:00"
  nullable    = false
}

variable "apply_immediately" {
  type        = bool
  description = "Whether to apply changes immediately"
  default     = true
  nullable    = false
}

variable "at_rest_encryption_enabled" {
  type        = bool
  description = "Enable encryption at rest"
  default     = true
  nullable    = false
}

variable "auth_token_update_strategy" {
  type        = string
  description = "Auth token update strategy (e.g., SET, ROTATE)"
  default     = "SET"
  nullable    = false
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Enable automatic minor version upgrades"
  default     = true
  nullable    = false
}

variable "multi_az_enabled" {
  type        = bool
  description = "Enable Multi-AZ for high availability"
  default     = false
  nullable    = false
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable encryption in transit (TLS)"
  default     = true
  nullable    = false
}

# ------------------------------------------------------------------------------
# Subnet and DNS Integration
# ------------------------------------------------------------------------------

variable "subnets_filter" {
  type = list(object({
    tier    = string
    purpose = string
  }))
  description = "Filter for selecting subnets based on tier and purpose tags"
  default = [
    {
      tier    = "*"
      purpose = "Database"
    }
  ]
  nullable = false
}

variable "route53" {
  type        = bool
  description = "Whether to create Route53 DNS records"
  default     = false
  nullable    = false
}
