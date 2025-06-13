# ------------------------------------------------------------------------------
# Output: VPC Endpoint IDs Map
# Returns a map of VPC endpoint resource keys to their IDs.
# ------------------------------------------------------------------------------
output "vpc_endpoint_ids" {
  value       = try({ for k, ep in aws_vpc_endpoint.this : k => ep.id }, null)
  description = "Map of VPC endpoint resource keys to their IDs (keyed by <service_type>-<service_name>)."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - This output is useful for referencing specific endpoint IDs in other modules or outputs.
# - The map key format is <service_type>-<service_name>, matching the for_each key in the resource.
# - Using try() ensures the output is null if no endpoints are created, avoiding errors in downstream modules.
# - Consider outputting additional attributes (e.g., DNS names, ARNs) if needed for integration.
# ------------------------------------------------------------------------------
