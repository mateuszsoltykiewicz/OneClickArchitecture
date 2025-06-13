# ------------------------------------------------------------------------------
# Resource: AWS RDS Cluster Instance
# Provisions one or more Aurora cluster instances based on the 'instances' variable.
# Each instance can have custom identifiers and instance classes.
# ------------------------------------------------------------------------------

resource "aws_rds_cluster_instance" "cluster_instances" {
  # Create one resource per entry in var.instances (or zero if var.instances is null/empty)
  count = length(coalesce(var.instances, []))

  # Unique identifier for the DB instance, combining the base identifier and short cluster name
  identifier = "${var.instances[count.index].identifier}-${var.short_cluster_name}"

  # Associate the instance with the parent RDS cluster
  cluster_identifier = aws_rds_cluster.aurora_clusters.id

  # Instance class (e.g., db.r5.large), taken from the input variable per instance
  instance_class = var.instances[count.index].instance_class

  # Engine type is taken from the cluster resource (e.g., aurora-postgresql)
  engine = aws_rds_cluster.aurora_clusters.engine

  # Promotion tier: 0 for the first instance (writer), 1 for all others (readers)
  promotion_tier = count.index == 0 ? 0 : 1

  # Resource tags for identification, cost allocation, and automation
  tags = {
    Name                 = "${var.instances[count.index].identifier}-${var.short_cluster_name}"  # Unique name for the instance
    LongClusterName      = var.long_cluster_name        # Full descriptive name for the cluster
    DatabaseName         = var.owner                   # Owner or database name (for tracking)
    Environment          = var.environment             # Environment (dev, staging, prod, etc.)
    VPCName              = var.vpc_name                # Name of the VPC
    DisasterRecoveryRole = var.disaster_recovery_role  # DR role for this resource
    ShortClusterName     = var.short_cluster_name      # Short name for the cluster
    AWSRegion            = var.aws_region              # AWS region
    Engine               = "aurora-postgresql"         # Database engine
    Owner                = var.owner                   # Owner (for tagging/auditing)
  }
}
