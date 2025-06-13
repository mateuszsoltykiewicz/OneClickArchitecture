locals {
  domain_name = "digitalfirstai.com"

  create_alertmanager_record = true
  create_grafana_record = true

  charts_configuration = {
    prometheus = {
      version = "73.1.0"
    }
    grafana = {
      version = "9.0.0"
    }
    loki = {
      version = "6.30.1"
    }
    fluentd = {
      version = "0.5.3"
    }
  }

  create_fluentd = true

  fluentd_configuration = {
    namespace = "logging"
  }

  create_loki = true

  loki_configuration = {
    namespace        = "logging"
    persistence_size = "50Gi"
    access_modes     = "ReadWriteOnce"
    requests = {
      requests_cpu    = "500m"
      requests_memory = "2Gi"
      limits_cpu      = "1000m"
      limits_memory   = "4Gi"
    }
  }

  create_grafana = true

  grafana_configuration = {
    namespace        = "monitoring"
    grafana_port     = 3000 
    persistence_size = "10Gi"
    requests = {
      requests_cpu    = "500m"
      requests_memory = "2Gi"
      limits_cpu      = "1000m"
      limits_memory   = "4Gi"
    }
  }

  create_prometheus = true

  prometheus_configuration = {
    namespace          = "monitoring"
    alertmanager_port  = 9093
    persistence_size   = "100Gi"
    requests = {
      requests_cpu    = "500m"
      requests_memory = "2Gi"
      limits_cpu      = "1000m"
      limits_memory   = "4Gi"
    }
  }

  create_alb = true

  create_storage_class = true

  storage_class_config = {
    namespace             = "logging"
    storage_provisioner   = "ebs.csi.aws.com"
    reclaim_policy        = "Retain"
    volume_binding_mode   = "Immediate"
    parameters = {
      type   = "ebs"
      fsType = "ext4"
    }
  }
}
