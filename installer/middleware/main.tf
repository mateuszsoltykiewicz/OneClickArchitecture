module "qdrant" {
  source = "./modules/qdrant"

  namespace           = var.namespace
  cluster_name        = "qdrant-cluster-${var.environment}"
  replicas            = 2
  s3_snapshot_bucket  = "qdrant-snapshots-${var.environment}"
  create_s3_bucket    = true
  storage_class       = "gp3"
  persistence_size    = "20Gi"
  oidc_provider_arn   = var.oidc_provider_arn
  environment         = var.environment

  tags = {
    Environment = var.environment
    Component   = "QDrant"
  }
}