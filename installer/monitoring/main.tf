module "storage" {
  source               = "./modules/storage"
  count                = local.create_storage_class ? 1 : 0
  storage_class_name   = "${var.environment}-${local.storage_class_config.namespace}"
  tags                 = var.tags
}

module "alb" {
  source = "./modules/alb"
  count  = local.create_alb ? 1 : 0

  environment     = var.environment
  namespace       = local.grafana_configuration.namespace
  dr_role         = var.disaster_recovery_role
  aws_region      = var.aws_region
  owner           = var.owner

  domain_name           = local.domain_name
  route53_zone_id       = data.aws_route53_zone.selected.id
  vpc_id                = data.aws_vpc.selected.id
  security_group_ids    = toset(data.aws_security_groups.node_sg.ids)
  subnet_ids            = toset(data.aws_subnets.public.ids)

  create_alertmanager_record  = local.create_alertmanager_record
  create_grafana_record       = local.create_grafana_record

  tags = var.tags
}

module "prometheus" {
  source  = "./modules/prometheus"
  count   = local.create_prometheus ? 1 : 0

  environment     = var.environment
  namespace       = local.prometheus_configuration.namespace
  dr_role         = var.disaster_recovery_role
  aws_region      = var.aws_region
  owner           = var.owner

  lb_arn         = try(module.alb[0].alb_arn, null)

  host_name           = try(module.alb[0].alertmanager_hostname, null)
  route53_zone_id     = module.alb[0].route53_zone_id
  vpc_id              = data.aws_vpc.selected.id
  alertmanager_port   = local.prometheus_configuration.alertmanager_port

  storage_class_name  = try(module.storage[0].storage_class_name, null) != null ? module.storage[0].storage_class_name : null
  persistent_size     = local.prometheus_configuration.persistence_size
  access_modes        = try(local.prometheus_configuration.access_modes, null)

  requests_cpu        = try(local.prometheus_configuration.requests.requests_cpu, null)
  requests_memory     = try(local.prometheus_configuration.requests.requests_memory, null)
  limits_cpu          = try(local.prometheus_configuration.requests.limits_cpu, null)
  limits_memory       = try(local.prometheus_configuration.requests.limits_memory, null)

  chart_version       = local.charts_configuration.prometheus.version

  tags        = var.tags
  depends_on  = [module.alb, module.storage]
}

module "grafana" {
  source  = "./modules/grafana"
  count   = local.create_grafana ? 1 : 0

  environment     = var.environment
  namespace       = local.grafana_configuration.namespace
  dr_role         = var.disaster_recovery_role
  aws_region      = var.aws_region
  owner           = var.owner

  lb_arn         = try(module.alb[0].alb_arn, null)

  grafana_port        = local.grafana_configuration.grafana_port
  route53_zone_id     = module.alb[0].route53_zone_id
  host_name           = try(module.alb[0].grafana_hostname, null)
  vpc_id              = data.aws_vpc.selected.id

  storage_class_name  = try(module.storage[0].storage_class_name, null) != null ? module.storage[0].storage_class_name : null
  persistent_size     = local.grafana_configuration.persistence_size
  access_modes        = try(local.grafana_configuration.access_modes, null)

  requests_cpu        = try(local.grafana_configuration.requests.requests_cpu, null)
  requests_memory     = try(local.grafana_configuration.requests.requests_memory, null)
  limits_cpu          = try(local.grafana_configuration.requests.limits_cpu, null)
  limits_memory       = try(local.grafana_configuration.requests.limits_memory, null)

  chart_version       = local.charts_configuration.grafana.version

  tags        = var.tags
  depends_on  = [module.storage, module.alb]
}

module "loki" {
  source  = "./modules/loki"
  count   = local.create_loki ? 1 : 0

  environment     = var.environment
  namespace       = local.loki_configuration.namespace
  dr_role         = var.disaster_recovery_role
  aws_region      = var.aws_region
  owner           = var.owner

  oidc_provider_arn   = data.aws_iam_openid_connect_provider.this.arn

  storage_class_name  = try(module.storage[0].storage_class_name, null) != null ? module.storage[0].storage_class_name : null
  persistent_size     = local.loki_configuration.persistence_size
  access_modes        = try(local.loki_configuration.access_modes, null)

  requests_cpu        = try(local.loki_configuration.requests.requests_cpu, null)
  requests_memory     = try(local.loki_configuration.requests.requests_memory, null)
  limits_cpu          = try(local.loki_configuration.requests.limits_cpu, null)
  limits_memory       = try(local.loki_configuration.requests.limits_memory, null)

  chart_version       = local.charts_configuration.loki.version

  tags        = var.tags
  depends_on  = [module.alb, module.storage]
}

module "logging" {
  source  = "./modules/logging"
  count   = local.create_fluentd ? 1 : 0

  environment     = var.environment
  namespace       = local.fluentd_configuration.namespace
  dr_role         = var.disaster_recovery_role
  aws_region      = var.aws_region
  owner           = var.owner

  loki_bucket_arn   = module.loki[0].loki_bucket_arn
  loki_irsa_arn     = module.loki[0].loki_irsa_arn
  oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn

  chart_version = local.charts_configuration.fluentd.version

  tags        = var.tags
  depends_on  = [module.loki, module.alb, module.storage]
}
