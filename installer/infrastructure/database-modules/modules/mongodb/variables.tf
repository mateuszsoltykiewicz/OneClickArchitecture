# ------------------------------------------------------------------------------
# Core Networking and Cluster Identification
# ------------------------------------------------------------------------------

variable "vpc_name" {
  type     = string
  nullable = false
  # Name of the VPC where resources will be deployed
}

variable "long_cluster_name" {
  type     = string
  nullable = false
  # Full/unique name for the cluster (used in resource names and tags)
}

variable "short_cluster_name" {
  type     = string
  nullable = false
  # Short identifier for the cluster (used for DNS and concise resource names)
}

variable "environment" {
  type     = string
  nullable = false
  # Environment name (e.g., dev, staging, prod)
}

variable "disaster_recovery_role" {
  type     = string
  nullable = false
  # Disaster recovery role (e.g., primary, secondary)
}

variable "aws_region" {
  type     = string
  nullable = false
  # AWS region for resource deployment
}

variable "owner" {
  type     = string
  nullable = false
  # Owner or team responsible for the infrastructure
}

# ------------------------------------------------------------------------------
# Database and Engine Configuration
# ------------------------------------------------------------------------------

variable "db_type" {
  type     = string
  default  = "mongodb"
  nullable = false
  # Database type (default: mongodb)
}

variable "engine_version" {
  type     = string
  default  = "5.0.0"
  nullable = false
  # Version of the database engine (default: 5.0.0)
}

variable "username" {
  type     = string
  default  = "dfai"
  nullable = false
  # Master username for the database
}

# ------------------------------------------------------------------------------
# Cluster Sizing and Instance Configuration
# ------------------------------------------------------------------------------

variable "cluster_size" {
  type     = number
  default  = 1
  nullable = false
  # Number of instances in the cluster (default: 1)
}

variable "instance_class" {
  type     = string
  default  = "db.t3.medium"
  nullable = false
  # Instance class/type for the database nodes (default: db.t3.medium)
}

# ------------------------------------------------------------------------------
# Maintenance, Security, and Operations
# ------------------------------------------------------------------------------

variable "skip_final_snapshot" {
  type     = bool
  default  = true
  nullable = false
  # Whether to skip the final snapshot when deleting the cluster (default: true)
}

variable "apply_immediately" {
  type     = bool
  default  = true
  nullable = false
  # Whether changes should be applied immediately (default: true)
}

variable "deletion_protection" {
  type     = bool
  default  = false
  nullable = false
  # Whether to enable deletion protection (default: false)
}

variable "mw" {
  type        = string
  description = "Maintenance window spec"
  default     = "sun:05:00-sun:09:00"
  nullable    = false
  # Preferred maintenance window (default: Sunday 05:00-09:00)
}

variable "storage_encrypted" {
  type     = bool
  default  = true
  nullable = false
  # Whether storage is encrypted (default: true)
}

variable "storage_type" {
  type     = string
  default  = "standard"
  nullable = false
  # Storage type for the database (default: standard)
}

# ------------------------------------------------------------------------------
# Subnet and Availability Zone Selection
# ------------------------------------------------------------------------------

variable "subnets_filter" {
  type = list(object({
    tier    = string
    purpose = string
  }))
  default = [
    {
      tier    = "*"
      purpose = "Database"
    }
  ]
  nullable = false
  # Filter for selecting subnets based on tier and purpose tags
}

variable "availability_zones" {
  type     = list(string)
  default  = ["eu-central-1a", "eu-central-1b"]
  nullable = false
  # List of availability zones for high availability (default: two AZs in eu-central-1)
}

# ------------------------------------------------------------------------------
# DNS/Route53 Integration
# ------------------------------------------------------------------------------

variable "route53" {
  type     = bool
  default  = false
  nullable = false
  # Whether to create Route53 DNS records (default: false)
}
