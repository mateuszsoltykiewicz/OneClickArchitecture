# ------------------------------------------------------------------------------
# Resource: Route53 Resolver Forward Rule
# Creates DNS forwarding rules to direct queries for specific domains to target resolvers.
# Typically used in hybrid cloud setups to resolve internal DNS names across networks.
# ------------------------------------------------------------------------------
resource "aws_route53_resolver_rule" "forward" {
  # Create one rule per destination in transit_destinations
  for_each = { for dest in var.transit_destinations : dest.dest_vpc_name => dest }

  # DNS domain to forward (e.g., "dev.acme" -> forwards *.dev.acme queries)
  domain_name = "${each.value.dest_environment}.${lower(var.owner)}"

  # Rule type (FORWARD for directing queries to specified IPs)
  rule_type = "FORWARD"

  # Outbound resolver endpoint to use for forwarding
  resolver_endpoint_id = var.resolver_outbound_id

  # Target DNS servers (typically inbound resolver IPs in another VPC)
  dynamic "target_ip" {
    for_each = var.resolver_inbound_ips
    content {
      ip   = target_ip.value  # IP address of target DNS server
      port = 53               # Standard DNS port
    }
  }

  # Tagging for resource management
  tags = merge(
    var.tags,  # Common tags from variables
    {
      Name                 = "dns-rule-${each.key}"                     # Rule identifier
      DomainName           = "${each.value.dest_environment}.${lower(var.owner)}"  # Full domain
      Owner                = var.owner                                  # Ownership tracking
      AwsRegion            = var.aws_region                             # Deployment region
      DisasterRecoveryRole = var.dr_role                                # DR classification
      DestEnvironment      = each.value.dest_environment                # Target environment
      Type                 = "ResolverRule"                             # Resource type
    }
  )
}

# ------------------------------------------------------------------------------
# Best Practices & Requirements:
# 1. Ensure resolver_outbound_id references a valid OUTBOUND resolver endpoint
# 2. resolver_inbound_ips should be IPs of INBOUND resolvers in the target VPC(s)
# 3. Security groups must allow UDP/53 traffic between resolver endpoints
# 4. Target domains must match the DNS zones configured in the target environments
# 5. Use distinct dest_vpc_name keys in transit_destinations to avoid rule conflicts
# 6. Domain names should follow your organization's DNS naming convention
# ------------------------------------------------------------------------------
