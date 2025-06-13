# ------------------------------------------------------------------------------
# Resource: AWS ElastiCache Replication Group (Redis)
# Manages a Redis cluster with replication and high availability.
# ------------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "this" {
  # Redis replication group ID (must be <= 40 characters)
  replication_group_id = substr("replicationgroup-${var.long_cluster_name}", 0, 40)

  description    = "Redis cluster managed by Terraform"
  node_type      = var.node_type               # Instance type (e.g., cache.t3.medium)
  port           = 6379                        # Default Redis port
  engine         = "redis"
  engine_version = var.engine_version

  # Networking
  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  # Security
  at_rest_encryption_enabled = var.at_rest_encryption_enabled  # Enable encryption at rest
  transit_encryption_enabled = var.transit_encryption_enabled  # Enable encryption in transit

  # Auth token for Redis AUTH (should be securely generated)
  auth_token_update_strategy = var.auth_token_update_strategy
  auth_token                 = "dfaidfaidfaidfai" # Use random_password.db_password.result in production

  # High Availability and Maintenance
  automatic_failover_enabled = true                # Enable automatic failover (required for Multi-AZ)
  snapshot_retention_limit   = 5                   # Number of daily snapshots to retain
  maintenance_window         = var.mw              # Preferred maintenance window
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  multi_az_enabled = var.multi_az_enabled          # Enable multi-AZ for high availability

  # Cluster Sizing
  num_cache_clusters      = var.num_cache_clusters      # Number of cache clusters (deprecated for cluster mode enabled)
  num_node_groups         = var.num_node_groups         # Number of node groups (shards) for cluster mode
  replicas_per_node_group = var.replicas_per_node_group # Replicas per node group

  # Tagging for resource management and cost allocation
  tags = {
    Name                 = "replication-group-${var.long_cluster_name}"
    ShortName            = "replication-group-${var.short_cluster_name}"
    Environment          = var.environment
    AwsRegion            = var.aws_region
    DisasterRecoveryRole = var.disaster_recovery_role
    VPCName              = var.vpc_name
    Owner                = var.owner
    DBType               = "elasticache"
    Type                 = "Database"
  }
}

# ------------------------------------------------------------------------------
# Resource: (Optional) AWS ElastiCache Cluster
# For legacy/replica management in non-clustered Redis setups.
# ------------------------------------------------------------------------------

resource "aws_elasticache_cluster" "replica" {
  cluster_id           = var.long_cluster_name
  replication_group_id = aws_elasticache_replication_group.this.id

  tags = {
    Name                 = "cluster-${var.long_cluster_name}"
    ShortName            = "cluster-${var.short_cluster_name}"
    Environment          = var.environment
    AwsRegion            = var.aws_region
    DisasterRecoveryRole = var.disaster_recovery_role
    VPCName              = var.vpc_name
    Owner                = var.owner
    DBType               = "elasticache"
    Type                 = "Database"
  }
}

# ------------------------------------------------------------------------------
# Best Practices and Notes:
# - Use random_password for auth_token in production: random_password.db_password.result
# - For cluster mode (sharded Redis), set num_node_groups and replicas_per_node_group.
# - For non-cluster mode, use num_cache_clusters only (deprecated for cluster mode).
# - Always enable encryption at rest and in transit for production clusters.
# - Tag all resources for cost allocation, automation, and tracking.
# - The aws_elasticache_cluster resource is only needed for legacy, non-clustered Redis.
# ------------------------------------------------------------------------------
