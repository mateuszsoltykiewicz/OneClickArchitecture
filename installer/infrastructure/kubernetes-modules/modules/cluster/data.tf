# ------------------------------------------------------------------------------
# Data Source: Select VPC by Tags
# Filters VPCs to select the correct one for the cluster, based on tags.
# ------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.long_vpc_name]  # VPC name tag, from input variable
  }
  filter {
    name   = "tag:Environment"
    values = [var.environment]    # Environment tag (e.g., dev, prod)
  }
  filter {
    name   = "tag:DisasterRecoveryRole"
    values = [var.disaster_recovery_role]  # DR role tag
  }
  filter {
    name   = "tag:AwsRegion"
    values = [var.aws_region]     # AWS region tag
  }
}

# ------------------------------------------------------------------------------
# Data Source: Select Subnets for Cluster Nodes
# Filters subnets in the selected VPC by Tier and Purpose tags.
# Used for worker/node group subnets.
# ------------------------------------------------------------------------------

data "aws_subnets" "cluster_subnets_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]  # Only subnets in the selected VPC
  }
  filter {
    name   = "tag:Tier"
    # Collect all 'tier' values from subnets_filter variable (e.g., ["private", "public"])
    values = [for tier_filter in var.subnets_filter : tier_filter.tier]
  }
  filter {
    name   = "tag:Purpose"
    # Collect all 'purpose' values from subnets_filter variable (e.g., ["app", "db"])
    values = [for purpose_filter in var.subnets_filter : purpose_filter.purpose]
  }
}

# ------------------------------------------------------------------------------
# Data Source: Select Subnets for Control Plane
# Filters subnets in the selected VPC by Tier and Purpose tags.
# Used for EKS control plane subnets (if you want to isolate control plane networking).
# ------------------------------------------------------------------------------

data "aws_subnets" "control_plane_subnets_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]  # Only subnets in the selected VPC
  }
  filter {
    name   = "tag:Tier"
    # Collect all 'tier' values from control_plane_subnets_filter variable
    values = [for tier_filter in var.control_plane_subnets_filter : tier_filter.tier]
  }
  filter {
    name   = "tag:Purpose"
    # Collect all 'purpose' values from control_plane_subnets_filter variable
    values = [for purpose_filter in var.control_plane_subnets_filter : purpose_filter.purpose]
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure your VPC and subnet tags are unique and consistent for accurate filtering.
# - Use specific 'tier' and 'purpose' values for fine-grained subnet selection.
# - If multiple VPCs or subnets could match, add more filters or use data validation.
# - Use outputs or locals to access subnet IDs for use in module or resource definitions.
# ------------------------------------------------------------------------------
