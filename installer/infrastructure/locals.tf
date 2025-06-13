locals {
  # Load configuration from YAML files. Tries module-local file first, then a shared architecture path.
  config = try(
    yamldecode(file("${path.module}/configuration.yaml")),
    yamldecode(file("../../configuration/architecture/${var.environment}/configuration.yaml"))
  )

  # Extract top-level configuration sections for easier reference.
  network    = try(local.config.networking, null)
  database   = try(local.config.database, null)
  kubernetes = try(local.config.kubernetes, null)

  # ----------------------------------------------------------------------------
  # DATABASE CONFIG
  # ----------------------------------------------------------------------------
  # Builds a list of database configs, one per database entry in the YAML.
  # - Names and tags are composed using global config values for uniqueness.
  # - Each supported DB type (mongodb, postgresql, elasticache) has its own attribute map,
  #   with nulls if not present.
  # - Uses try() for all optional attributes for robustness.
  # - Subnet filters for DBs are extracted if present.
  database_config = try(length(local.database), 0) > 0 ? [
    for database in local.database : {
      local_short_cluster_name = database.db_name
      local_long_cluster_name  = "${database.db_name}-${var.environment}-${var.owner}-${var.disaster_recovery_role}"
      local_environment        = var.environment
      local_long_vpc_name      = "${database.vpc_name}-${var.environment}-${var.owner}-${var.disaster_recovery_role}-${var.aws_region}"
      local_type               = database.db_type

      # MongoDB attributes (null if not present)
      mongodb_attributes = try(database.mongodb_attributes, null) != null ? {
        specific_cluster_size        = try(database.mongodb_attributes.cluster_size, null)
        specific_instance_class      = try(database.mongodb_attributes.instance_class, null)
        specific_username            = try(database.mongodb_attributes.username, null)
        specific_skip_final_snapshot = try(database.mongodb_attributes.skip_final_snapshot, null)
        specific_apply_immediately   = try(database.mongodb_attributes.apply_immediately, null)
        specific_deletion_protection = try(database.mongodb_attributes.deletion_protection, null)
        specific_mw                  = try(database.mongodb_attributes.maintenance_window, null)
        specific_storage_encrypted   = try(database.mongodb_attributes.storage_encrypted, null)
        specific_storage_type        = try(database.mongodb_attributes.storage_type, null)
        subnets_filter               = try(database.postgresql_attributes.subnets_filter, null)
      } : null

      # PostgreSQL attributes (null if not present)
      postgresql_attributes = try(database.postgresql_attributes, null) != null ? {
        engine_version                       = try(database.postgresql_attributes.engine_version, null)
        specific_instances                   = try(database.postgresql_attributes.instances, null)
        specific_instance_class              = try(database.postgresql_attributes.instance_class, null)
        specific_username                    = try(database.postgresql_attributes.username, null)
        specific_storage_encrypted           = try(database.postgresql_attributes.storage_encrypted, null)
        specific_apply_immediately           = try(database.postgresql_attributes.apply_immediately, null)
        specific_skip_final_snapshot         = try(database.postgresql_attributes.skip_final_snapshot, null)
        specific_allow_major_version_upgrade = try(database.postgresql_attributes.allow_major_version_upgrade, null)
        specific_ca_certificate_identifier   = try(database.postgresql_attributes.ca_certificate_identifier, null)
        specific_database_name               = try(database.postgresql_attributes.database_name, null)
        specific_allocated_storage           = try(database.postgresql_attributes.allocated_storage, null)
        specific_deletion_protection         = try(database.postgresql_attributes.deletion_protection, null)
        specific_storage_type                = try(database.postgresql_attributes.storage_type, null)
        subnets_filter                       = try(database.postgresql_attributes.subnets_filter, null)
      } : null

      # ElastiCache attributes (null if not present)
      elasticache_attributes = try(database.elasticache_attributes, null) != null ? {
        specific_node_type                  = try(database.elasticache_attributes.node_type, null)
        specific_engine_version             = try(database.elasticache_attributes.engine_version, null)
        specific_mw                         = try(database.elasticache_attributes.maintenance_window, null)
        specific_apply_immediately          = try(database.elasticache_attributes.apply_immediately, null)
        specific_at_rest_encryption_enabled = try(database.elasticache_attributes.at_rest_encryption_enabled, null)
        specific_auth_token_update_strategy = try(database.elasticache_attributes.auth_token_update_strategy, null)
        specific_auto_minor_version_upgrade = try(database.elasticache_attributes.auto_minor_version_upgrade, null)
        specific_multi_az_enabled           = try(database.elasticache_attributes.multi_az_enabled, null)
        specific_transit_encryption_enabled = try(database.elasticache_attributes.transit_encryption_enabled, null)
        subnets_filter                      = try(database.elasticache_attributes.subnets_filter, null)
      } : null
    }
  ] : null

  # ----------------------------------------------------------------------------
  # KUBERNETES CONFIG
  # ----------------------------------------------------------------------------
  # Builds a list of Kubernetes cluster configs.
  # - Names are composed for uniqueness across environments/owners/regions.
  # - All optional fields are wrapped in try() for robustness.
  # - Node groups are mapped by name, with all possible node group attributes.
  kubernetes_config = local.kubernetes != null ? [
    for kubernetes in local.kubernetes : {
      local_long_cluster_name  = "${kubernetes.cluster_name}-${kubernetes.vpc_name}-${var.environment}-${var.owner}-${var.disaster_recovery_role}-${var.aws_region}"
      local_short_cluster_name = kubernetes.cluster_name
      local_environment        = var.environment
      local_long_vpc_name      = "${kubernetes.vpc_name}-${var.environment}-${var.owner}-${var.disaster_recovery_role}-${var.aws_region}"

      addons = try(kubernetes.addons, null)
      route53 = try(kubernetes.route53, null)
      subnets_filter = try(kubernetes.subnets_filter, null)
      control_plane_subnets_filter = try(kubernetes.control_plane_subnets_filter, null)

      cluster_attributes = try(kubernetes.cluster_attributes, null) != null ? {
        cluster_version                 = try(kubernetes.cluster_attributes.cluster_version, null)
        cluster_endpoint_public_access  = try(kubernetes.cluster_attributes.cluster_endpoint_public_access, null)
        cluster_endpoint_private_access = try(kubernetes.cluster_attributes.cluster_endpoint_private_access, null)
      } : null

      security = try(kubernetes.security, null) != null ? {
        enable_security_groups_for_pods      = try(kubernetes.security.enable_security_groups_for_pods, null)
        cluster_endpoint_public_access       = try(kubernetes.security.cluster_endpoint_public_access, null)
        cluster_endpoint_private_access      = try(kubernetes.security.cluster_endpoint_private_access, null)
        cluster_endpoint_public_access_cidrs = try(kubernetes.cluster_endpoint_public_access_cidrs, null)
        authentication_mode                  = try(kubernetes.security.authentication_mode, null)
      } : null

      instance_types = try(kubernetes.instance_types, null)

      # Node groups as a map keyed by node group name
      node_groups = try(kubernetes.node_groups, null) != null ? {
        for ng in try(kubernetes.node_groups, {}) : ng.node_group_name => {
          node_name = {
            subnet_tags                 = try(ng.subnet_tags, null)
            ami_type                    = try(ng.ami_type, null)
            capacity_type               = try(ng.capacity_type, null)
            instance_types              = try(ng.instance_types, null)
            disk_size                   = try(ng.disk_size, null)
            use_custom_launch_template  = try(ng.use_custom_launch_template, null)
            volume_type                 = try(ng.volume_type, null)
            min_size                    = try(ng.min_size, null)
            max_size                    = try(ng.max_size, null)
            desired_size                = try(ng.desired_size, null)
            labels                      = try(ng.labels, null)
          }
        }
      } : null
    }
  ] : null

  # ----------------------------------------------------------------------------
  # NETWORK CONFIG
  # ----------------------------------------------------------------------------
  # Builds a list of VPC configs, one per VPC in the YAML.
  # - VPC names are composed for uniqueness.
  # - Subnets are expanded across all AZs, with names and CIDRs generated per AZ.
  # - Each VPC can reference its associated Kubernetes cluster by long name.
  # - Transit destinations are resolved by matching VPC names in the network list.
  network_config = local.network != null ? [
    for vpc in local.network : {
      vpc_name              = "${vpc.vpc_name}-${var.environment}-${var.owner}-${var.disaster_recovery_role}-${var.aws_region}"
      cidr_block            = vpc.cidr_block
      environment           = var.environment
      azs                   = vpc.azs
      vpc_endpoints_enable  = try(vpc.vpc_endpoints_enable, true)

      # Find associated Kubernetes cluster name for this VPC (if any)
      long_cluster_name = try(
        [for k in local.kubernetes_config : k.local_long_cluster_name
          if k.local_long_vpc_name == "${vpc.vpc_name}-${var.environment}-${var.owner}-${var.disaster_recovery_role}-${var.aws_region}"
        ][0],
        null
      )

      # Expand subnets for each AZ, generating unique names and CIDRs
      subnets = try(vpc.subnets, null) != null ? flatten([
        for subnet in vpc.subnets : [
          for idx, az in vpc.azs : {
            name       = "${vpc.vpc_name}-${var.environment}-${subnet.purpose}-${subnet.tier}-${az}-${var.owner}-${var.disaster_recovery_role}"
            cidr_block = cidrsubnet(vpc.cidr_block, 4, index(vpc.subnets, subnet) * length(vpc.azs) + idx)
            purpose    = subnet.purpose
            tier       = subnet.tier
            az         = az
          }
        ]
      ]) : null
      
      # Build transit destinations by looking up referenced VPCs in the network list
      transit_destinations = length(try(vpc.transit_destinations, [])) > 0 ? [
        for dest in vpc.transit_destinations : {
          dest_vpc_name    = [for v in local.network : "${v.vpc_name}-${v.environment}-${var.owner}-${var.disaster_recovery_role}-${var.aws_region}" if v.vpc_name == dest.vpc_name][0]
          dest_cidr_block  = [for v in local.network : v.cidr_block if v.vpc_name == dest.vpc_name][0]
          dest_environment = [for v in local.network : v.environment if v.vpc_name == dest.vpc_name][0]
          dest_azs         = [for v in local.network : v.azs if v.vpc_name == dest.vpc_name][0]
        }
      ] : null

      
    }
  ] : null

  # Current environment config
  environment = var.environment
  env_config  = local.config.global

  # DNS
  domain_name = "${local.environment}.${local.env_config.domain_root}"


  # --------------------------------------------------------------------------
  # IDEAS FOR IMPROVEMENT (do not implement, just notes)
  # --------------------------------------------------------------------------
  # - Consider schema validation for the loaded YAML to catch errors early.
  # - You could extract common tag logic to a local for reuse in all blocks.
  # - For subnet CIDR allocation, consider using a more robust IPAM strategy
  #   if your VPCs/subnets grow in number.
  # - If you have many clusters or VPCs, consider using maps keyed by name
  #   for O(1) lookups instead of lists and for-comprehensions.
  # - Add error handling/logging for missing/duplicate resources in the YAML.
  # - For very large configs, you might want to split YAMLs by environment or resource type.
  # - Consider supporting additional database types or cloud services by extending the attribute maps.
  # - For multi-region deployments, add region awareness to all name generators and lookups.
  # - Document the expected YAML structure in your repository for onboarding and maintenance.
}
