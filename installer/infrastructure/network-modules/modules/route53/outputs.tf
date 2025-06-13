# ------------------------------------------------------------------------------
# Output: Route53 Private Zone ID
# Returns the ID of the created private Route53 hosted zone.
# ------------------------------------------------------------------------------
output "route53zone_id" {
  value       = aws_route53_zone.private.id
  description = "The ID of the private Route53 hosted zone."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use this output as an input to modules or resources that need to create records or associations in this zone.
# - For multi-zone or multi-environment setups, consider outputting a map of zone IDs keyed by environment or owner.
# ------------------------------------------------------------------------------
