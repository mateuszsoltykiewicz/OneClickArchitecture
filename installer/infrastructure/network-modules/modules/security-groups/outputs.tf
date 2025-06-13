# ------------------------------------------------------------------------------
# Output: Private Security Group ID
# Returns the ID of the private security group (for internal/cross-VPC communication).
# ------------------------------------------------------------------------------
output "private_security_group_id" {
  value       = try(aws_security_group.private[0].id, null)
  description = "ID of the private security group for internal or cross-VPC communication."
}

# ------------------------------------------------------------------------------
# Output: Internet Security Group ID
# Returns the ID of the internet-facing (public) security group.
# ------------------------------------------------------------------------------
output "internet_security_group_id" {
  value       = try(aws_security_group.public[0].id, null)
  description = "ID of the internet-facing (public) security group."
}

# ------------------------------------------------------------------------------
# Output: Endpoint Security Group ID
# Returns the ID of the security group used for VPC endpoints.
# ------------------------------------------------------------------------------
output "endpoint_security_group_id" {
  value       = try(aws_security_group.endpoints[0].id, null)
  description = "ID of the security group for VPC endpoints."
}

# ------------------------------------------------------------------------------
# Output: DNS Security Group ID
# Returns the ID of the security group used for DNS resolver endpoints or DNS traffic.
# ------------------------------------------------------------------------------
output "dns_security_group_id" {
  value       = try(aws_security_group.dns[0].id, null)
  description = "ID of the security group for DNS resolver endpoints or DNS traffic."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use try() and [0] to safely handle cases where the security group is not created (count = 0).
# - These outputs are typically referenced by other modules or resources for network configuration.
# - Add descriptions for clarity and better documentation in Terraform output.
# ------------------------------------------------------------------------------
