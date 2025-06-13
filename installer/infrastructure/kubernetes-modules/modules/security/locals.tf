locals {
  base_tags = {
    Environment          = var.environment
    Owner                = var.owner
    DisasterRecoveryRole = var.disaster_recovery_role
    AWSRegion            = var.aws_region
    VPCName              = var.long_vpc_name
    ClusterName          = var.long_cluster_name
  }
}