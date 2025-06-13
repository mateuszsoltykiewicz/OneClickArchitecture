# ==============================================================================
# NETWORKING MODULE
# Deploys all networking resources (VPCs, subnets, gateways, TGW, etc.)
# Only runs if local.network_config is not null.
# ==============================================================================
module "networking" {
  source = "./network-modules"

  count = local.network_config != null ? 1 : 0  # Conditional creation based on loaded config

  disaster_recovery_role = var.disaster_recovery_role  # DR role (active/passive)
  aws_region             = var.aws_region              # AWS region for tagging/resources
  owner                  = var.owner                   # Owner for tagging

  network_config  = local.network_config                               # List of VPCs and related settings
  amazon_side_asn = try(local.config.global.amazon_side_asn, 64512)    # ASN for TGW (default 64512)
}

# ==============================================================================
# DATABASE MODULE
# Deploys all database resources (RDS, ElastiCache, etc.)
# Only runs if local.database_config is not null.
# ==============================================================================
module "database" {
  source = "./database-modules"

  count = local.database_config != null ? 1 : 0  # Conditional creation

  disaster_recovery_role  = var.disaster_recovery_role
  aws_region              = var.aws_region
  owner                   = var.owner
  environment             = var.environment

  database_config         = local.database_config        # List of database configurations

  depends_on              = [module.networking]               # Ensures networking is provisioned first
}

# ==============================================================================
# KUBERNETES MODULE
# Deploys all Kubernetes clusters and related resources.
# Only runs if local.kubernetes_config is not null.
# ==============================================================================
module "kubernetes" {
  source = "./kubernetes-modules"

  count = local.kubernetes_config != null ? 1 : 0  # Conditional creation

  disaster_recovery_role = var.disaster_recovery_role
  aws_region             = var.aws_region
  owner                  = var.owner

  kubernetes_config = local.kubernetes_config     # List of Kubernetes cluster configurations

  depends_on = [module.networking]               # Ensures networking is provisioned first
}


# ==============================================================================
# IDEAS FOR IMPROVEMENT (do not implement, just notes)
# ------------------------------------------------------------------------------
# - Consider using for_each instead of count for more flexibility if you ever want
#   to deploy multiple independent sets of networking, database, or Kubernetes stacks.
# - You could pass a global "tags" map to each module for more consistent tagging.
# - If you expect to add more top-level modules (e.g., monitoring, logging), 
#   keep this pattern for modular scalability.
# - For very large configs, consider splitting config loading and validation logic
#   into a dedicated module or external script for maintainability.
# - Add output blocks to expose key resources (VPC IDs, cluster endpoints, etc.)
#   from each module for cross-module references or documentation.
# - Consider variable validation or schema enforcement for the config locals
#   to catch errors early.
# - If you use workspaces or deploy to multiple environments, parameterize 
#   the config file path or allow overrides via variables.
# ==============================================================================
