# Elasticache (Redis) Module Configuration
# Creates Elasticache clusters based on database_config entries filtered by "elasticache" type
module "elasticache" {
  source = "./modules/elasticache"

  # Iterate over database_config entries and create map of Elasticache clusters
  # using local_short_cluster_name as unique key
  for_each = { for elasticache in var.database_config : elasticache.local_short_cluster_name => elasticache if elasticache.local_type == "elasticache" }

  # Cluster identification and networking
  vpc_name            = each.value.local_long_vpc_name
  long_cluster_name   = each.value.local_long_cluster_name
  short_cluster_name  = each.value.local_short_cluster_name

  # Elasticache-specific configuration with fallback to null if not specified
  node_type                  = try(each.value.elasticache_attributes.specific_node_type, null)
  engine_version             = try(each.value.elasticache_attributes.specific_engine_version, null)
  mw                         = try(each.value.elasticache_attributes.specific_maintenance_window, null)
  apply_immediately          = try(each.value.elasticache_attributes.specific_apply_immediately, null)
  at_rest_encryption_enabled = try(each.value.elasticache_attributes.specific_at_rest_encryption_enabled, null)
  auth_token_update_strategy = try(each.value.elasticache_attributes.specific_auth_token_update_strategy, null)
  auto_minor_version_upgrade = try(each.value.elasticache_attributes.specific_auto_minor_version_upgrade, null)
  multi_az_enabled           = try(each.value.elasticache_attributes.specific_multi_az_enabled, null)
  transit_encryption_enabled = try(each.value.elasticache_attributes.specific_transit_encryption_enabled, null)
  subnets_filter             = try(each.value.elasticache_attributes.subnets_filter, null)

  # Common infrastructure configuration
  route53                 = var.route53
  aws_region              = var.aws_region
  disaster_recovery_role  = var.disaster_recovery_role
  owner                   = var.owner
  environment             = var.environment
}

# PostgreSQL (RDS) Module Configuration
# Creates PostgreSQL RDS instances based on database_config entries filtered by "postgresql" type
module "postgresql" {
  source = "./modules/postgresql"

  # Iterate over database_config entries and create map of PostgreSQL clusters
  for_each = { for postgresql in var.database_config : postgresql.local_short_cluster_name => postgresql if postgresql.local_type == "postgresql" }

  # Cluster identification and networking
  vpc_name           = each.value.local_long_vpc_name
  short_cluster_name = each.value.local_short_cluster_name
  long_cluster_name  = each.value.local_long_cluster_name

  # PostgreSQL-specific configuration with fallback to null
  engine_version              = try(each.value.postgresql_attributes.specific_engine_version, null)
  instances                   = try(each.value.postgresql_attributes.specific_instances, null)
  instance_class              = try(each.value.postgresql_attributes.specific_instance_class, null)
  username                    = try(each.value.postgresql_attributes.specific_username, null)
  storage_encrypted           = try(each.value.postgresql_attributes.specific_storage_encrypted, null)
  apply_immediately           = try(each.value.postgresql_attributes.specific_apply_immediately, null)
  skip_final_snapshot         = try(each.value.postgresql_attributes.specific_skip_final_snapshot, null)
  allow_major_version_upgrade = try(each.value.postgresql_attributes.specific_allow_major_version_upgrade, null)
  ca_certificate_identifier   = try(each.value.postgresql_attributes.specific_ca_certificate_identifier, null)
  allocated_storage           = try(each.value.postgresql_attributes.specific_allocated_storage, null)
  deletion_protection         = try(each.value.postgresql_attributes.specific_deletion_protection, null)
  storage_type                = try(each.value.postgresql_attributes.specific_storage_type, null)
  subnets_filter              = try(each.value.postgresql_attributes.subnets_filter, null)

  # Common infrastructure configuration
  route53                 = var.route53
  aws_region              = var.aws_region
  disaster_recovery_role  = var.disaster_recovery_role
  owner                   = var.owner
  environment             = var.environment
}

# MongoDB (DocumentDB) Module Configuration
# Creates MongoDB clusters based on database_config entries filtered by "mongodb" type
module "mongodb" {
  source = "./modules/mongodb"

  # Iterate over database_config entries and create map of MongoDB clusters
  for_each = { for mongodb in var.database_config : mongodb.local_short_cluster_name => mongodb if mongodb.local_type == "mongodb" }

  # Cluster identification and networking
  vpc_name           = each.value.local_long_vpc_name
  short_cluster_name = each.value.local_short_cluster_name
  long_cluster_name  = each.value.local_long_cluster_name

  # MongoDB-specific configuration with fallback to null
  cluster_size        = try(each.value.mongodb_attributes.specific_cluster_size, null)
  instance_class      = try(each.value.mongodb_attributes.specific_instance_class, null)
  username            = try(each.value.mongodb_attributes.specific_username, null)
  skip_final_snapshot = try(each.value.mongodb_attributes.specific_skip_final_snapshot, null)
  apply_immediately   = try(each.value.mongodb_attributes.specific_apply_immediately, null)
  deletion_protection = try(each.value.mongodb_attributes.specific_deletion_protection, null)
  mw                  = try(each.value.mongodb_attributes.specific_maintenance_window, null)
  storage_encrypted   = try(each.value.mongodb_attributes.specific_storage_encrypted, null)
  storage_type        = try(each.value.mongodb_attributes.specific_storage_type, null)
  subnets_filter      = try(each.value.mongodb_attributes.subnets_filter, null)

  # Common infrastructure configuration
  route53                 = var.route53
  aws_region              = var.aws_region
  disaster_recovery_role  = var.disaster_recovery_role
  owner                   = var.owner
  environment             = var.environment
}
