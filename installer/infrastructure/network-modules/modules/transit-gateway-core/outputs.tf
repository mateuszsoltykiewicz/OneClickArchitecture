# ------------------------------------------------------------------------------
# Output: Transit Gateway ID
# Returns the ID of the created Transit Gateway (TGW).
# ------------------------------------------------------------------------------
output "transit_gateway_id" {
  value       = try(aws_ec2_transit_gateway.this.id, null)
  description = "The ID of the Transit Gateway (TGW)."
}

# ------------------------------------------------------------------------------
# Output: Transit Gateway ARN
# Returns the ARN of the created Transit Gateway (TGW).
# ------------------------------------------------------------------------------
output "transit_gateway_arn" {
  value       = try(aws_ec2_transit_gateway.this.arn, null)
  description = "The ARN of the Transit Gateway (TGW)."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use try() to avoid errors if the resource is not created.
# - These outputs are commonly used as inputs to VPC attachment modules or for cross-account sharing.
# - Descriptions make outputs self-documenting for module consumers and in `terraform output`.
# ------------------------------------------------------------------------------
