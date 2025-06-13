# ------------------------------------------------------------------------------
# Data Source: Select Route53 Private Hosted Zone
# Looks up a private Route53 DNS zone based on environment and owner.
# This is commonly used for internal DNS records in multi-environment AWS setups.
# ------------------------------------------------------------------------------

data "aws_route53_zone" "selected" {
  # The DNS zone name is dynamically constructed from environment and owner variables.
  name         = "${var.environment}.${lower(var.owner)}"
  private_zone = true  # Only match private hosted zones (not public DNS)
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure the zone name matches the actual Route53 zone (e.g., "prod.acme" for prod/Acme).
# - Use this data source to get the zone ID for creating DNS records (e.g., aws_route53_record).
# - If there could be multiple zones with the same name, consider adding a VPC association filter for extra safety:
#   vpc_id = data.aws_vpc.selected.id
# ------------------------------------------------------------------------------
