# ------------------------------------------------------------------------------
# Output: Long VPC Name
# Returns the VPC name for the specified VPC module instance.
# ------------------------------------------------------------------------------
output "long_vpc_name" {
  value = {
    for k, mod in module.vpcs : k => mod.vpc_name
  }
  description = "The name of the VPCs."
}

# ------------------------------------------------------------------------------
# Output: Endpoints Subnet IDs
# Returns a list of endpoint subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "endpoint_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.endpoint_subnet_ids
  }
  description = "List of endpoint subnet IDs."
}

# ------------------------------------------------------------------------------
# Output: Transit Subnet IDs
# Returns a list of transit subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "transit_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.transit_subnet_ids
  }
  description = "List of transit subnet IDs."
}

# ------------------------------------------------------------------------------
# Output: Private Subnet IDs
# Returns a list of private subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "private_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.private_subnet_ids
  }
  description = "List of private subnet IDs."
}

# ------------------------------------------------------------------------------
# Output: Public Subnet IDs
# Returns a list of public subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "public_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.public_subnet_ids
  }
  description = "List of public subnet IDs."
}


# ------------------------------------------------------------------------------
# Output: Database Subnet IDs
# Returns a list of database subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "database_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.database_subnet_ids
  }
  description = "List of database subnet IDs."
}

# ------------------------------------------------------------------------------
# Output: Kubernetes public Subnet IDs
# Returns a list of kubernetes public subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "kubernetes_private_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.kubernetes_private_subnet_ids
  }
  description = "List of kubernetes private subnet IDs."
}

output "network_config" {
  description = "Combined networking configuration grouped by VPC"
  value = tomap({
    for vpc_key, vpc_mod in module.vpcs : 
    vpc_mod.vpc_id => {
      vpc_id                          = vpc_mod.vpc_id
      public_subnet_ids               = try(module.subnets.public_subnet_id[vpc_key], [])
      private_subnet_ids              = try(module.subnets.private_subnet_id[vpc_key], [])
      database_subnet_ids             = try(module.subnets.database_subnet_id[vpc_key], [])
      transit_subnet_ids              = try(module.subnets.transit_subnet_id[vpc_key], [])
      endpoint_subnet_ids             = try(module.subnets.endpoint_subnet_id[vpc_key], [])
      kubernetes_public_subnet_ids    = try(module.subnets.kubernetes_public_subnet_id[vpc_key], [])
      kubernetes_private_subnet_ids   = try(module.subnets.kubernetes_private_subnet_id[vpc_key], [])
    }
  })
}


# ------------------------------------------------------------------------------
# Output: Kubernetes private Subnet IDs
# Returns a list of kubernetes private subnet IDs for the specified VPC.
# ------------------------------------------------------------------------------
output "kubernetes_public_subnet_id" {
  value = {
    for k, mod in module.subnets : k => mod.kubernetes_public_subnet_ids
  }
  description = "List of kubernetes public subnet IDs."
}


# ------------------------------------------------------------------------------
# Best Practices:
# - Use descriptive output names and add descriptions for clarity.
# - Reference the correct module key for each VPC/environment.
# - For multi-VPC or dynamic environments, consider outputting all values as a map keyed by VPC name:
#     output "all_private_subnet_ids" {
#       value = { for k, mod in module.subnets : k => mod.private_subnet_ids }
#     }
# - This approach is scalable and future-proof for multi-environment setups.
# ------------------------------------------------------------------------------
