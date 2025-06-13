# ------------------------------------------------------------------------------
# Output: Aurora Writer Endpoint
# Exposes the primary (writer) endpoint of the Aurora PostgreSQL cluster.
# This endpoint should be used by applications for all write operations.
# ------------------------------------------------------------------------------

output "aurora_writer_endpoint" {
  value = {
    (var.vpc_name) = {
      rds_endpoint = aws_rds_cluster.aurora_clusters.endpoint}
  }
  description = "The writer endpoint for the Aurora PostgreSQL cluster. Use this for all write connections."
}
