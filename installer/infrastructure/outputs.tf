output "clusters" {
  description = "Map of clusters with their details"
  value = {
    for mod in module.kubernetes : values(mod.long_cluster_name)[0] => {
      vpc_name                        = mod.vpc_name
      endpoint                        = mod.cluster_endpoint
      ca_certificate                  = mod.cluster_certificate_authority_data
      oidc_provider_arn               = mod.oidc_provider_arn
      node_security_group_id          = mod.node_security_group_id
      control_plane_security_group_id = mod.control_plane_security_group_id
    }
  }
}


output "network_config" {
  description = "Combined networking configuration grouped by VPC"
  value = {
    for k, mod in module.networking : k => mod
  }
}



output "primary_database_endpoints" {
  description = "Primary endpoints for Redis, MongoDB, and RDS grouped by VPC name"
  value = try({
    for vpc_name, dbs in module.database[0].vpc_database_endpoints : vpc_name => {
      redis_configuration_endpoint  = try(values(dbs.elasticache)[1], null)
      redis_endpoint                = try(values(dbs.elasticache)[0], null)
      mongodb_endpoint              = try(values(dbs.mongodb)[0], null)
      rds_endpoint                  = try(values(dbs.postgresql)[0], null)
    }
  }, {})
}
