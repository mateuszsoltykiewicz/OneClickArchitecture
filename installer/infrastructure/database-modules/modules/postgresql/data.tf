# ------------------------------------------------------------------------------
# Data Source: AWS VPC
# Selects the VPC based on tags for Name, Environment, DisasterRecoveryRole, and AwsRegion.
# This ensures the correct VPC is selected for the deployment.
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
# Data Source: AWS Subnets
# Selects subnets within the selected VPC, filtered by Tier and Purpose tags.
# The filters use lists derived from the subnets_filter variable, allowing flexible subnet selection.
# ------------------------------------------------------------------------------

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]  # Only subnets in the selected VPC
  }

  filter {
    name   = "tag:Tier"
    # Gather all 'tier' values from the subnets_filter variable (e.g., ["private", "public"])
    values = [for tier_filter in var.subnets_filter : tier_filter.tier]
  }

  filter {
    name   = "tag:Purpose"
    # Gather all 'purpose' values from the subnets_filter variable (e.g., ["db", "app"])
    values = [for purpose_filter in var.subnets_filter : purpose_filter.purpose]
  }
}

# ------------------------------------------------------------------------------
# Data Source: AWS Route53 Zone
# Conditionally selects a private Route53 zone for the environment and owner.
# The count is set to 1 only if var.route53 is true, otherwise this data block is skipped.
# ------------------------------------------------------------------------------

data "aws_route53_zone" "selected" {
  count = try(var.route53, false) != false ? 1 : 0  # Only create if Route53 is enabled

  name         = "${var.environment}.${lower(var.owner)}"  # DNS zone name, e.g., "prod.acme"
  private_zone = true  # Only select private zones
}
