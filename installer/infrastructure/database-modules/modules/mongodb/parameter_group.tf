# ------------------------------------------------------------------------------
# Resource: AWS DocumentDB Cluster Parameter Group
# Creates a custom parameter group for the DocumentDB cluster.
# This example disables TLS (not recommended for production).
# ------------------------------------------------------------------------------

resource "aws_docdb_cluster_parameter_group" "custom_tls" {
  name        = "custom-params-${var.long_cluster_name}"         # Unique parameter group name
  family      = "docdb5.0"                                      # Parameter group family for DocumentDB 5.0
  description = "Custom parameter group with TLS disabled"       # Description for AWS Console

  # Parameter block: disables TLS for client connections
  parameter {
    name         = "tls"
    value        = "disabled"             # WARNING: Disables TLS encryption for client connections
    apply_method = "pending-reboot"       # Change takes effect after cluster reboot
  }

  # Tags for resource management and tracking
  tags = {
    Name                 = "custom-params-${var.long_cluster_name}"
    ShortName            = "custom-params-${var.short_cluster_name}"
    Environment          = var.environment
    AwsRegion            = var.aws_region
    DisasterRecoveryRole = var.disaster_recovery_role
    VPCName              = var.vpc_name
    Owner                = var.owner
    DBType               = var.db_type
    Type                 = "Database"
    Purpose              = "MongoDB"
  }
}

# ------------------------------------------------------------------------------
# Security Note:
# - Disabling TLS is NOT recommended for production environments.
# - For production, set `value = "enabled"` to enforce encrypted connections.
# - Always ensure your applications and clients support TLS before enabling.
# ------------------------------------------------------------------------------
