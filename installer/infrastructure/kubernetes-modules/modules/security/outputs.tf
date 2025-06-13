
# ------------------------------------------------------------------------------
# Output: EKS Node Security Group ID
# Returns the ID of the node (worker) security group (if created).
# ------------------------------------------------------------------------------
output "node_security_group_id" {
  value       = try(aws_security_group.node[0].id, null)
  description = "ID of the EKS node (worker) security group (or null if not created)"
}

# ------------------------------------------------------------------------------
# Output: EKS Control Plane Security Group ID
# Returns the ID of the control plane security group (if created).
# ------------------------------------------------------------------------------
output "control_plane_security_group_id" {
  value       = try(aws_security_group.control_plane[0].id, null)
  description = "ID of the EKS control plane security group (or null if not created)"
}

output "long_vpc_name" {
  value = var.long_vpc_name
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use these outputs in module calls or as inputs to other modules/resources.
# - The use of try() and [0] handles the case where count = 0 (SG not created).
# ------------------------------------------------------------------------------
