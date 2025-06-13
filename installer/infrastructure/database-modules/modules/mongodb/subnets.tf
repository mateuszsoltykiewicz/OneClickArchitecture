# ------------------------------------------------------------------------------
# Resource: AWS DocumentDB Subnet Group
# Specifies which subnets the DocumentDB cluster can use for deployment.
# Ensures high availability by spreading instances across multiple AZs.
# ------------------------------------------------------------------------------

resource "aws_docdb_subnet_group" "this" {
  name       = "dbsubnet${var.long_cluster_name}"  # Unique subnet group name per cluster

  # List of subnet IDs to include in the group, typically from filtered subnets
  subnet_ids = data.aws_subnets.selected.ids

  # Optional: Add a description for clarity in the AWS Console
  description = "Subnet group for DocumentDB cluster ${var.long_cluster_name}"

  # Optional: Add tags for tracking and management (recommended)
  tags = {
    Name        = "dbsubnet${var.long_cluster_name}"
    Environment = var.environment
    VPCName     = var.vpc_name
    Owner       = var.owner
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure subnets span multiple Availability Zones for high availability.
# - Use descriptive names and tags for easier management and cost allocation.
# ------------------------------------------------------------------------------
