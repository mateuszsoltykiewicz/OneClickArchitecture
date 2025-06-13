# ------------------------------------------------------------------------------
# Core Cluster and Environment Variables
# ------------------------------------------------------------------------------

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role (e.g., primary, secondary, standby)"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
  nullable    = false
}

variable "route53" {
  type        = bool
  description = "Whether to create Route53 DNS records for resources"
  default     = false
  nullable    = false
}

variable "short_cluster_name" {
  type        = string
  description = "Short, unique name for the cluster (used in DNS and tags)"
  nullable    = false
}

variable "long_cluster_name" {
  type        = string
  description = "Full descriptive name for the cluster (used as identifier)"
  nullable    = false
}

variable "aws_region" {
  type        = string
  description = "AWS Region where resources will be deployed"
  nullable    = false
}

variable "owner" {
  type        = string
  description = "Name of the setup owner (for tagging and auditing)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Database Engine and Security Variables
# ------------------------------------------------------------------------------

variable "username" {
  type        = string
  description = "Master username for the database"
  default     = "dfai"
  nullable    = false
}

variable "storage_encrypted" {
  type        = bool
  description = "Whether storage shall be encrypted or not (true or false)"
  default     = false
  nullable    = false
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately (true) or during the next maintenance window (false)"
  default     = true
  nullable    = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether to skip the final snapshot when deleting the database (true or false)"
  default     = true
  nullable    = false
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Whether to allow major upgrades for the database engine"
  default     = false
  nullable    = false
}

variable "deletion_protection" {
  type        = bool
  description = "Enable or disable deletion protection for the cluster"
  default     = false
  nullable    = false
}

variable "ca_certificate_identifier" {
  type        = string
  description = "Identifier for the CA certificate used for SSL connections"
  default     = null
}

# ------------------------------------------------------------------------------
# Network and Storage Variables
# ------------------------------------------------------------------------------

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to deploy resources into"
  nullable    = false
}

variable "subnets_filter" {
  type = list(object({
    tier    = string
    purpose = string
  }))
  description = "Filter for selecting subnets by tier and purpose"
  default = [
    {
      tier    = "*"
      purpose = "Database"
    }
  ]
  nullable = false
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the cluster"
  default     = ["eu-central-1a", "eu-central-1b"]
  nullable    = false
}

# ------------------------------------------------------------------------------
# Cluster Instance and Storage Configuration
# ------------------------------------------------------------------------------

variable "instance_class" {
  type        = string
  description = "Default instance class for the RDS cluster (used if not specified per instance)"
  default     = "db.t4g.medium"
}

variable "instances" {
  type = list(object({
    identifier     = string
    instance_class = string
  }))
  description = "List of cluster instances (writer/reader) with their identifiers and classes"
  default = [
    {
      identifier     = "writer"
      instance_class = "db.t4g.medium"
    },
    {
      identifier     = "reader"
      instance_class = "db.t4g.medium"
    }
  ]
  nullable = false
}

variable "allocated_storage" {
  type        = number
  description = "Amount of storage to be allocated to DB (in GB)"
  default     = 10
  nullable    = false
}

variable "storage_type" {
  type        = string
  description = "Storage type for RDS (e.g., gp2, io1, io2)"
  default     = "io2"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Database Engine Version and Type
# ------------------------------------------------------------------------------

variable "engine_version" {
  type        = string
  description = "Cluster engine version of Postgres Aurora"
  default     = "16.6"
  nullable    = false
}

variable "db_type" {
  type        = string
  description = "Type of the database (e.g., PostgreSQL, MySQL)"
  default     = "PostgreSQL"
  nullable    = false
}
