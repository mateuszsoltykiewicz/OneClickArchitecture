# ------------------------------------------------------------------------------
# Route53 Resolver Endpoints (Inbound/Outbound)
# Creates DNS resolver endpoints for hybrid cloud DNS resolution scenarios.
# ------------------------------------------------------------------------------

resource "aws_route53_resolver_endpoint" "this" {
  for_each = {
    inbound  = "INBOUND"
    outbound = "OUTBOUND"
  }

  name               = substr("dns-${each.key}-${var.vpc_id}", 0, 64)  # Unique name within 64 chars
  direction          = each.value
  security_group_ids = [var.security_group_id]  # Security group controlling endpoint access

  # IP Address Configuration - one per AZ for HA
  dynamic "ip_address" {
    for_each = var.private_subnet_ids  # List of subnet IDs in different AZs
    content {
      subnet_id = ip_address.value
      # ip       = "10.0.0.5"  # Optional: Specify private IP if needed
    }
  }

  tags = merge(
    var.tags,  # Base tags from variables
    {
      "Name"      = "dns-${each.key}-${var.vpc_name}"
      "VpcName"   = var.vpc_name
      "VpcId"     = var.vpc_id
      "DRRole"    = var.dr_role
      "Owner"     = var.owner
      "Region"    = var.aws_region
      "Direction" = each.key
      # Removed Subnets tag due to potential length limits
    }
  )

  lifecycle {
    create_before_destroy = true  # Maintain availability during updates
    ignore_changes = [
      tags["CreatedDate"]  # If using automated tag management
    ]
  }
}

# ------------------------------------------------------------------------------
# Best Practices Implemented:
# 1. DRY Principle: Single resource block handling both endpoint types via for_each
# 2. Naming: Ensures names stay within AWS 64-character limit
# 3. Tagging: 
#    - Avoided potential 256-character tag value limit by removing Subnets tag
#    - Used merge() for consistent base tags + resource-specific tags
# 4. High Availability: Requires subnets in different AZs (enforced via variable validation)
# 5. Security: Explicit security group association
# 6. Lifecycle Management: create_before_destroy for zero-downtime updates
# ------------------------------------------------------------------------------
