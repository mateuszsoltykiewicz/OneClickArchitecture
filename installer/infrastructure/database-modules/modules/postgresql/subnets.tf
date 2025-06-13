# ------------------------------------------------------------------------------
# Resource: DB Subnet Group for Aurora/PostgreSQL Cluster
# Specifies which subnets the RDS/Aurora cluster can use for deployment.
# Ensures high availability by spreading instances across multiple AZs.
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name       = "dbsubnet${var.long_cluster_name}"  # Unique subnet group name per cluster

  # List of subnet IDs to include in the group, typically from filtered subnets
  subnet_ids = data.aws_subnets.selected.ids

  # Optional: Add a description for clarity in the AWS Console
  description = "Subnet group for Aurora cluster ${var.long_cluster_name}"

  # Optional: Add tags for tracking and management (recommended)
  tags = {
    Name        = "dbsubnet${var.long_cluster_name}"
    Environment = var.environment
    VPCName     = var.vpc_name
    Owner       = var.owner
  }
}
