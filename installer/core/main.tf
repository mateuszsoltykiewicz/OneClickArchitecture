module "alb_controller" {
  source              = "./modules/alb-controller"

  cluster_name        = var.cluster_name
  aws_region          = var.aws_region
  vpc_id              = var.vpc_id
  oidc_provider_arn   = var.oidc_provider_arn
  public_subnet_ids   = var.public_subnet_ids
  #private_subnet_ids  = var.private_subnet_ids
  tags                = var.tags
  environment         = var.environment

  depends_on = [ module.alb, module.acm ]
}

module "cert_manager" {
  source        = "./modules/cert-manager"

  cluster_name  = var.cluster_name
  
}

# module "cluster_issuer" {
#   source                  = "./modules/cluster-issuer"
#   name                    = "develop-issuer"
#   server                  = "https://acme-v02.api.letsencrypt.org/directory"
#   email                   = "m.soltykiewicz@digitalfirst.ai"
#   private_key_secret_name = "develop-issuer"
#   solver_type             = "dns01"
#   solver_config = {
#     route53 = {
#       region       = "eu-central-1"
#       hostedZoneID = "Z1234567890"
#     }
#   }
#   depends_on = [module.cert_manager]
# }


# module "karpenter" {
#   source                  = "./modules/karpenter"

#   cluster_name            = var.cluster_name
#   cluster_endpoint        = var.cluster_endpoint
#   karpenter_namespace     = "karpenter"
#   karpenter_chart_version = var.karpenter_chart_version
#   subnet_ids              = var.public_subnet_ids
#   security_group_ids      = var.node_security_group_ids
#   tags                    = var.tags
#   environment             = var.environment
#   oidc_provider_arn       = var.oidc_provider_arn
# }