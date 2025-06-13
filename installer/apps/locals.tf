locals {
  config = try(
  yamldecode(file("${path.module}/configuration.yaml")),
  yamldecode(file("../../configuration/infrastructure/${var.environment}/configuration.yaml"))
  )

  aws_region              = var.aws_region
  owner                   = var.owner
  disaster_recovery_role  = var.disaster_recovery_role
  environment             = var.environment
}