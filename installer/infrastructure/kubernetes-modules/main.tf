# ------------------------------------------------------------------------------
# Security Module: Creates security groups for EKS components
# ------------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  # Iterate over clusters defined in kubernetes_config
  for_each = { for cluster in var.kubernetes_config : cluster.local_long_cluster_name => cluster }

  # Cluster/VPC Identification
  long_cluster_name = each.key                   # Unique cluster identifier
  long_vpc_name     = each.value.local_long_vpc_name  # VPC name from config
  environment       = each.value.local_environment    # Environment tag value

  # Security Group Control
  create_security_group = true  # Always create security groups for these clusters

  # Resource Tagging
  owner                  = var.owner
  disaster_recovery_role = var.disaster_recovery_role
  aws_region             = var.aws_region  # WARNING: Should likely be var.aws_region
  tags                   = {}
}

# ------------------------------------------------------------------------------
# Cluster Module: Creates EKS cluster and node groups
# ------------------------------------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  # Use same cluster iteration pattern as security module
  for_each = { for cluster in var.kubernetes_config : cluster.local_long_cluster_name => cluster }

  # Cluster Identification
  short_cluster_name = each.value.local_short_cluster_name  # DNS-friendly name
  long_cluster_name  = each.value.local_long_cluster_name   # Full resource name
  long_vpc_name      = each.value.local_long_vpc_name       # VPC reference
  environment        = each.value.local_environment         # Environment tag

  # Network Configuration
  subnets_filter               = each.value.subnets_filter               # Worker node subnets
  control_plane_subnets_filter = each.value.control_plane_subnets_filter # Control plane subnets

  # Cluster Configuration
  cluster_attributes = each.value.cluster_attributes  # Version, IRSA config
  security           = each.value.security            # API access controls
  instance_types     = each.value.instance_types      # Node instance types

  # Security Integration
  cluster_security_group_id       = try(module.security[each.key].cluster_security_group_id, [])
  node_security_group_id          = try(module.security[each.key].node_security_group_id, null)
  control_plane_security_group_id = try(module.security[each.key].control_plane_security_group_id, null)

  # Resource Tagging
  disaster_recovery_role = var.disaster_recovery_role
  aws_region             = var.aws_region
  owner                  = var.owner

  # Explicit dependency chain
  depends_on = [module.security]
}

# ------------------------------------------------------------------------------
# DNS Module: Creates Route53 records for cluster endpoints (conditional)
# ------------------------------------------------------------------------------
module "route53" {
  source = "./modules/route53"

  # Only create records for clusters with route53 enabled
  for_each = { for cluster in var.kubernetes_config : cluster.local_long_cluster_name => cluster if cluster.route53 }

  # DNS Configuration
  short_cluster_name = module.cluster[each.key].short_cluster_name  # Subdomain prefix
  cluster_endpoint   = module.cluster[each.key].cluster_endpoint    # EKS API endpoint

  # Tagging Inheritance
  environment = module.cluster[each.key].environment
  owner       = module.cluster[each.key].owner

  # Cluster must exist first
  depends_on = [module.cluster]
}

# ------------------------------------------------------------------------------
# IAM Module: Creates IAM roles and policies for cluster components
# ------------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  for_each = { for cluster in var.kubernetes_config : cluster.local_long_cluster_name => cluster }

  # Cluster Identification
  long_cluster_name  = module.cluster[each.key].long_cluster_name
  short_cluster_name = module.cluster[each.key].short_cluster_name

  # OIDC Configuration
  cluster_oidc_provider_arn = module.cluster[each.key].oidc_provider_arn  # IRSA foundation
  cluster_oidc_issuer_url   = module.cluster[each.key].cluster_oidc_issuer_url

  # Cluster must be created first
  depends_on = [module.cluster]
}

# ------------------------------------------------------------------------------
# Addons Module: Manages essential EKS addons with IAM integration
# ------------------------------------------------------------------------------
module "aws_addons" {
  source = "./modules/aws-addons"

  for_each = { for cluster in var.kubernetes_config : cluster.local_long_cluster_name => cluster }

  # Cluster Metadata
  long_cluster_name      = module.cluster[each.key].long_cluster_name
  environment            = module.cluster[each.key].environment
  disaster_recovery_role = module.cluster[each.key].disaster_recovery_role

  # Addon Configuration
  coredns = {
    version  = "v1.11.4-eksbuild.10"
    role_arn = module.iam[each.key].coredns_role_arn  # IRSA role from IAM module
  }

  kube_proxy = {
    version = "v1.32.3-eksbuild.7"  # No role needed
  }

  vpc_cni = {
    version  = "v1.19.4-eksbuild.1"
    role_arn = module.iam[each.key].vpc_cni_role_arn
  }

  efs_csi_driver = {
    version  = "v2.1.7-eksbuild.1"
    role_arn = module.iam[each.key].efs_csi_role_arn
  }

  ebs_csi_driver = {
    version  = "v1.44.0-eksbuild.1"
    role_arn = module.iam[each.key].ebs_csi_role_arn
  }

  s3_csi_driver = {
    version  = "v1.13.0-eksbuild.1"
    role_arn = module.iam[each.key].s3_csi_role_arn
  }

  pod_identity_agent = {
    version  = "v1.3.5-eksbuild.2"
    role_arn = module.iam[each.key].pod_identity_role_arn
  }

  snapshot_controller = {
    version = "v8.2.0-eksbuild.1"
  }

  # Requires IAM roles to exist first
  depends_on = [module.iam, module.cluster]
}
