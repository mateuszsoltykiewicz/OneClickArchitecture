# Main configuration variable for all database clusters.
# This is a list of objects, each representing a database cluster and its configuration.
variable "database_config" {
  type = list(object({
    # Short, unique name for the cluster (used as a key)
    local_short_cluster_name = string
    # Long, descriptive cluster name
    local_long_cluster_name  = string
    # Name of the VPC where the cluster will be deployed
    local_long_vpc_name      = string
    # Type of database (e.g., "mongodb", "postgresql", "elasticache")
    local_type               = string

    # MongoDB-specific configuration block (optional, only for MongoDB clusters)
    mongodb_attributes = optional(object({
      specific_cluster_size        = optional(number, null)   # Number of nodes in the cluster
      specific_instance_class      = optional(string, null)   # Instance type (e.g., db.r5.large)
      specific_username            = optional(string, null)   # Admin username
      specific_db_type             = optional(string, null)   # Database type (e.g., "replicaSet")
      specific_skip_final_snapshot = optional(bool, null)     # Skip final snapshot on deletion
      specific_apply_immediately   = optional(bool, null)     # Apply changes immediately
      specific_deletion_protection = optional(bool, null)     # Enable deletion protection
      specific_mw                  = optional(string, null)   # Maintenance window
      specific_storage_encrypted   = optional(bool, null)     # Enable storage encryption
      specific_storage_type        = optional(bool, null)     # Storage type (e.g., "gp2")
      # List of subnet filters (e.g., to select subnets by tier and purpose)
      subnets_filter = optional(list(object({
        tier    = string
        purpose = string
      })), null)
    }), null)

    # PostgreSQL-specific configuration block (optional, only for PostgreSQL clusters)
    postgresql_attributes = optional(object({
      specific_engine_version = optional(string, null)        # Engine version (e.g., "13.7")
      specific_instance_class = optional(string, null)        # Instance class (e.g., db.t3.medium)
      # List of instance definitions (identifier and class)
      specific_instances = optional(list(object({
        identifier     = string
        instance_class = string
      })), null)
      specific_username                    = optional(string, null) # Admin username
      specific_storage_encrypted           = optional(bool, null)   # Enable storage encryption
      specific_apply_immediately           = optional(bool, null)   # Apply changes immediately
      specific_skip_final_snapshot         = optional(bool, null)   # Skip final snapshot on deletion
      specific_allow_major_version_upgrade = optional(bool, null)   # Allow major version upgrades
      specific_ca_certificate_identifier   = optional(string, null) # CA certificate identifier
      specific_database_name               = optional(string, null) # Initial database name
      specific_allocated_storage           = optional(bool, null)   # Amount of storage allocated
      specific_deletion_protection         = optional(bool, null)   # Enable deletion protection
      specific_storage_type                = optional(string, null) # Storage type (e.g., "gp2")
      # List of subnet filters (e.g., to select subnets by tier and purpose)
      subnets_filter = optional(list(object({
        tier    = string
        purpose = string
      })), null)
    }), null)

    # Elasticache-specific configuration block (optional, only for Elasticache clusters)
    elasticache_attributes = optional(object({
      specific_node_type                  = optional(string, null)  # Node type (e.g., cache.t3.medium)
      specific_engine_version             = optional(string, null)  # Engine version (e.g., "6.x")
      specific_mw                         = optional(string, null)  # Maintenance window
      specific_apply_immediately          = optional(bool, null)    # Apply changes immediately
      specific_at_rest_encryption_enabled = optional(bool, null)    # Enable at-rest encryption
      specific_auth_token_update_strategy = optional(string, null)  # Auth token update strategy
      specific_auto_minor_version_upgrade = optional(bool, null)    # Enable auto minor version upgrade
      specific_multi_az_enabled           = optional(bool, null)    # Enable Multi-AZ deployment
      transit_encryption_enabled          = optional(bool, null)    # Enable in-transit encryption
      # List of subnet filters (e.g., to select subnets by tier and purpose)
      subnets_filter = optional(list(object({
        tier    = string
        purpose = string
      })), null)
    }), null)
  }))
}

# Role to be used for disaster recovery scenarios
variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role"
}

# AWS region where resources will be deployed
variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "environment" {
  type = string
}

# Name of the owner of this setup (for tagging, auditing, etc.)
variable "owner" {
  type        = string
  description = "Name of the setup owner"
}

# Whether to create Route53 DNS records for the resources
variable "route53" {
  type        = bool
  default     = false
  nullable    = false
}
