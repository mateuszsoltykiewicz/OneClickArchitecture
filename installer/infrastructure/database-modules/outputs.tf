output "vpc_database_endpoints" {
  description = "Map of database endpoints grouped by VPC"
  value = {
    for vpc_name in distinct(concat(
      keys(module.elasticache),
      keys(module.postgresql),
      keys(module.mongodb)
    )) : vpc_name => {
      elasticache = try({
        endpoint                = module.elasticache[vpc_name].redis_endpoint
        configuration_endpoint  = module.elasticache[vpc_name].redis_configuration_endpoint
      }, null)
      
      postgresql = try(module.postgresql[vpc_name].aurora_writer_endpoint, null)
      
      mongodb    = try(module.mongodb[vpc_name].docdb_endpoint, null)
    }
  }
}