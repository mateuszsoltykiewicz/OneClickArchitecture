module "middleware" {
  source = "./middleware-modules"

  aws_region              = local.aws_region
  disaster_recovery_role  = local.disaster_recovery_role
  environment             = local.environment
  owner                   = local.owner
  

  vpc_name                = var.vpc_name
  public_subnet_ids       = var.public_subnet_ids
  private_subnet_ids      = var.private_subnet_ids

  cluster_name            = var.cluster_name
  oidc_provider_arn       = var.oidc_provider_arn
  namespace               = var.namespace

  redis_endpoint          = var.redis_endpoint
  rds_endpoint            = var.rds_endpoint
  mongo_endpoint          = var.mongo_endpoint
}