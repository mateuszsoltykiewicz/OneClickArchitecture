# ------------------------------------------------------------------------------
# Data Source: Select the VPC by Tags
# Filters VPCs based on custom tags to ensure the correct environment and role.
# ------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]  # Match VPCs with the given Name tag
  }
  filter {
    name   = "tag:Environment"
    values = [var.environment]  # Match VPCs with the given Environment tag (e.g., dev, prod)
  }
  filter {
    name   = "tag:DisasterRecoveryRole"
    values = [var.disaster_recovery_role]  # Match VPCs with the given DisasterRecoveryRole tag
  }
  filter {
    name   = "tag:AwsRegion"
    values = [var.aws_region]  # Match VPCs with the given AwsRegion tag
  }
}

# ------------------------------------------------------------------------------
# Data Source: Select Subnets in the Chosen VPC
# Filters subnets by VPC ID and tags for Tier and Purpose.
# Uses list comprehensions to collect all relevant values from the subnets_filter variable.
# ------------------------------------------------------------------------------

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]  # Only subnets in the selected VPC
  }

  filter {
    name   = "tag:Tier"
    # Collect all 'tier' values from the subnets_filter variable (e.g., ["private", "public"])
    values = [for tier_filter in var.subnets_filter : tier_filter.tier]
  }

  filter {
    name   = "tag:Purpose"
    # Collect all 'purpose' values from the subnets_filter variable (e.g., ["db", "app"])
    values = [for purpose_filter in var.subnets_filter : purpose_filter.purpose]
  }
}

# ------------------------------------------------------------------------------
# Data Source: Select Private Route53 Zone (Conditional)
# Only queries for a Route53 zone if var.route53 is true.
# The zone name is constructed from the environment and owner variables.
# ------------------------------------------------------------------------------

data "aws_route53_zone" "selected" {
  count        = try(var.route53, false) != false ? 1 : 0  # Only create if Route53 is enabled
  name         = "${var.environment}.${lower(var.owner)}"  # DNS zone name, e.g., "prod.acme"
  private_zone = true                                      # Only select private zones
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure your VPC and subnet tags are consistent and unique for accurate filtering.
# - Use specific 'tier' and 'purpose' values in subnets_filter for fine-grained subnet selection.
# - If you expect multiple matching VPCs or subnets, use additional filters or validation.
# ------------------------------------------------------------------------------
