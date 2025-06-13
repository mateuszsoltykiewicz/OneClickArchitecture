
# ------------------------------------------------------------------------------
# Output: Resolver Endpoint IPs by Direction
# Returns lists of IP addresses filtered by resolver endpoint direction.
# ------------------------------------------------------------------------------
output "resolver_inbound_ips" {
  value = compact([
    for ep in aws_route53_resolver_endpoint.this : 
    ep.ip_address[*].ip if ep.tags["Direction"] == "inbound"
  ])
  description = "IP addresses for INBOUND resolver endpoints."
}

output "resolver_outbound_ips" {
  value = compact([
    for ep in aws_route53_resolver_endpoint.this : 
    ep.ip_address[*].ip if ep.tags["Direction"] == "outbound"
  ])
  description = "IP addresses for OUTBOUND resolver endpoints."
}


# ------------------------------------------------------------------------------
# Output: Outbound Resolver Endpoint ID
# Returns the resource ID of the outbound resolver endpoint.
# ------------------------------------------------------------------------------
output "resolver_inbound_id" {
  value = try([for ep in aws_route53_resolver_endpoint.this : ep.id if ep.tags["Direction"] == "inbound"], null)
  description = "ID(s) of the inbound Route53 resolver endpoint(s)."
}

output "resolver_outbound_id" {
  value = try([for ep in aws_route53_resolver_endpoint.this : ep.id if ep.tags["Direction"] == "outbound"], null)
  description = "ID(s) of the outbound Route53 resolver endpoint(s)."
}


# ------------------------------------------------------------------------------
# (Recommended) Output: All Resolver Endpoints as a Map (for DRY, scalable code)
# If you use the refactored for_each pattern in main.tf, add this:
# ------------------------------------------------------------------------------
# output "resolver_endpoint_ips" {
#   value = {
#     for k, ep in aws_route53_resolver_endpoint.this : k => [for ip in ep.ip_address : ip.ip]
#   }
#   description = "Map of resolver endpoint IP addresses by direction (inbound/outbound)."
# }
#
# output "resolver_endpoint_ids" {
#   value = {
#     for k, ep in aws_route53_resolver_endpoint.this : k => ep.id
#   }
#   description = "Map of resolver endpoint IDs by direction (inbound/outbound)."
# }
# ------------------------------------------------------------------------------
