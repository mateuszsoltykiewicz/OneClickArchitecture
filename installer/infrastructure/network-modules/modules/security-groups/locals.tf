# ========================
# Local Values
# ========================
locals {
  standard_tags = {
    VpcName              = var.vpc_name
    VpcId                = var.vpc_id
    DisasterRecoveryRole = var.dr_role
    Environment          = var.environment
    AwsRegion            = var.aws_region
    Owner                = var.owner
  }

  dns_cidr_blocks = try(
    [for dest in var.transit_destinations : dest.dest_cidr_block],
    [data.aws_vpc.selected.cidr_block]
  )
}