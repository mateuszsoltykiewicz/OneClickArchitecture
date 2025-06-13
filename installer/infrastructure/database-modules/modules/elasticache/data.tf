# ------------------------------------------------------------------------------
# Data Source: Select VPC by Tags
# Filters VPCs based on tags to ensure correct environment and DR role.
# ------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]  # Match VPC by Name tag
  }
  filter {
    name   = "tag:Environment"
    values = [var.environment]  # Filter by environment (e.g., dev, prod)
  }
  filter {
    name   = "tag:DisasterRecoveryRole"
    values = [var.disaster_recovery_role]  # Filter by DR role (e.g., primary, secondary)
  }
  filter {
    name   = "tag:AwsRegion"
    values = [var.aws_region]  # Filter by AWS region tag
  }
}

# ------------------------------------------------------------------------------
# Data Source: Select Subnets in the Chosen VPC
# Filters subnets by VPC ID and tags for Tier and Purpose.
# Uses list comprehensions to collect all relevant values from subnets_filter.
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
# - Ensure your VPC and subnet tags are unique and consistent for accurate filtering.
# - Use specific 'tier' and 'purpose' values in subnets_filter for fine-grained subnet selection.
# - If multiple VPCs or subnets could match, add more filters or use data validation.
# ------------------------------------------------------------------------------
