# ------------------------------------------------------------------------------
# Output: Internet Gateway ID
# Returns the ID of the created Internet Gateway, or null if not created.
# ------------------------------------------------------------------------------
output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "The ID of the Internet Gateway created for the VPC (or null if not created)."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use try() and [0] to safely handle conditional creation (for_each or count).
# - Reference this output in route table or NAT Gateway modules to associate public subnets.
# - If you use for_each with a different key (e.g., ["igw"]), you can also use:
#     value = try(aws_internet_gateway.this["igw"].id, null)
# ------------------------------------------------------------------------------
