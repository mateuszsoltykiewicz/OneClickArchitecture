# ------------------------------------------------------------------------------
# Resource: AWS DocumentDB Cluster Instance
# Provisions one or more DocumentDB instances as part of a cluster.
# ------------------------------------------------------------------------------

resource "aws_docdb_cluster_instance" "this" {
  # Number of instances to create, based on the cluster_size variable
  count = var.cluster_size

  # Unique identifier for each instance
  # Note: If you want unique names per instance, append count.index to the identifier
  identifier = "instance-${var.long_cluster_name}-${count.index + 1}"

  # The cluster this instance belongs to
  cluster_identifier = aws_docdb_cluster.this.id

  # Instance class (e.g., db.r5.large)
  instance_class = var.instance_class

  # Tags for resource identification and management
  tags = {
    Name = "instance-${var.long_cluster_name}-${count.index + 1}"
    # Add more tags as needed for environment, owner, etc.
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - The identifier should be unique per instance. Appending count.index ensures this.
# - Add additional tags (e.g., Environment, Owner, ClusterName) for better resource tracking.
# - Ensure var.cluster_size is set to the desired number of instances (minimum 1 for production).
# ------------------------------------------------------------------------------
