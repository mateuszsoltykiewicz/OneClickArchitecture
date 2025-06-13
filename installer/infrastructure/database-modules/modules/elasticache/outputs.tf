# ------------------------------------------------------------------------------
# Output: Redis Endpoint (ElastiCache Cluster)
# Exposes the Redis cluster endpoint address for application connectivity.
# This is typically used by clients to connect to the Redis cluster.
# ------------------------------------------------------------------------------

output "redis_configuration" {
  value = {
    (var.vpc_name) = {
      redis_endpoint                = aws_elasticache_cluster.replica.cluster_address
      redis_configuration_endpoint  = aws_elasticache_replication_group.this.configuration_endpoint_address
    }
  }
  description = "The primary endpoint for the DocumentDB cluster. Use this for application connections."
}

