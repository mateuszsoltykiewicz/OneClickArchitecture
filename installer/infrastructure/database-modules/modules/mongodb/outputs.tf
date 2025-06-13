# ------------------------------------------------------------------------------
# Output: DocumentDB Cluster Endpoint
# Exposes the primary endpoint for the DocumentDB cluster.
# Applications should use this endpoint to connect to the DocumentDB cluster.
# ------------------------------------------------------------------------------

output "docdb_endpoint" {
  value = {
    (var.vpc_name) = {
      docdb_endpoint = aws_docdb_cluster.this.endpoint
    }
  }
  description = "The primary endpoint for the DocumentDB cluster. Use this for application connections."
}
