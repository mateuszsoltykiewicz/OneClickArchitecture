#===================================================================================
# TRANSIT GATEWAY CORE
# Creates a regional Transit Gateway for multi-VPC connectivity (only if >1 VPC)
#===================================================================================
module "transit_gateway_core" {
  count  = length(var.network_config) > 1 ? 1 : 0  # Conditional creation for multi-VPC environments
  source = "./modules/transit-gateway-core"

  amazon_side_asn = var.amazon_side_asn  # Private ASN for BGP routing
  dr_role         = var.disaster_recovery_role
  aws_region      = var.aws_region
  owner           = var.owner
}

#===================================================================================
# VPCS
# Creates all VPCs defined in network_config with base networking
#===================================================================================
module "vpcs" {
  source = "./modules/vpc"
  for_each = { for vpc in var.network_config : vpc.vpc_name => vpc }  # One module instance per VPC

  vpc_name    = each.value.vpc_name
  cidr_block  = each.value.cidr_block
  environment = each.value.environment
  aws_region  = var.aws_region
  dr_role     = var.disaster_recovery_role
  owner       = var.owner

  depends_on = [module.transit_gateway_core]  # Ensure TGW exists before VPC creation
}

#===================================================================================
# INTERNET GATEWAYS
# Creates IGWs only for VPCs with public subnets
#===================================================================================
module "internet_gateway" {
  source = "./modules/internet-gateway"
  for_each = {  # Conditional creation filter
    for vpc in var.network_config : vpc.vpc_name => vpc
    if contains([for subnet in vpc.subnets : subnet.tier], "Public")  # Only VPCs with public subnets
  }

  vpc_id      = module.vpcs[each.key].vpc_id
  vpc_name    = module.vpcs[each.key].vpc_name
  create_igw  = true  # Explicit creation flag

  environment   = each.value.environment
  dr_role       = var.disaster_recovery_role
  aws_region    = var.aws_region
  owner         = var.owner

  depends_on = [module.vpcs]  # Requires VPCs first
}

#===================================================================================
# SECURITY GROUPS
# Creates security groups for each VPC with conditional rules
#===================================================================================
module "security_groups" {
  source    = "./modules/security-groups"
  for_each  = { for vpc in var.network_config : vpc.vpc_name => vpc }  # One per VPC

  vpc_id    = module.vpcs[each.key].vpc_id
  # Conditional security group creation:
  dns                           = length(var.network_config) > 1 ? true : false  # DNS SG for multi-VPC
  enable_public_security_group  = contains([for subnet in each.value.subnets : subnet.tier], "Public")
  enable_private_security_group = contains([for subnet in each.value.subnets : subnet.tier], "Private")
  enable_vpc_endpoints          = contains([for subnet in each.value.subnets : subnet.tier], "Private")

  transit_destinations = try(each.value.transit_destinations, null)
  vpc_name             = each.key
  environment          = each.value.environment
  dr_role              = var.disaster_recovery_role
  aws_region           = var.aws_region
  owner                = var.owner

  depends_on = [module.vpcs]
}

#===================================================================================
# ROUTE53 PRIVATE ZONES
# Creates private DNS zones for multi-VPC environments
#===================================================================================
module "route53" {
  source    = "./modules/route53"
  for_each  = length(var.network_config) > 1 ? { for vpc in var.network_config : vpc.vpc_name => vpc } : {}  # Only for multi-VPC

  vpc_id                  = module.vpcs[each.key].vpc_id
  environment             = each.value.environment
  aws_region              = var.aws_region
  disaster_recovery_role  = var.disaster_recovery_role
  owner                   = var.owner

  depends_on = [module.vpcs]
}

#===================================================================================
# SUBNETS & ROUTING
# Creates all subnets and route tables with advanced routing
#===================================================================================
module "subnets" {
  source    = "./modules/subnet"
  for_each  = { for vpc in var.network_config : vpc.vpc_name => vpc }  # One per VPC

  vpc_id   = module.vpcs[each.key].vpc_id
  vpc_name = module.vpcs[each.key].vpc_name
  # Gateway configuration:
  internet_gateway_id = try(module.internet_gateway[each.key].internet_gateway_id, null)
  transit_gateway_id  = try(module.transit_gateway_core[0].transit_gateway_id, null)
  # Conditional features:
  internet_gateway    = try(module.internet_gateway[each.key].internet_gateway_id, false) != false ? true : false
  transit_gateway     = length(var.network_config) > 1  # TGW routing only in multi-VPC

  long_cluster_name   = each.value.long_cluster_name

  environment = each.value.environment
  subnets     = each.value.subnets  # Subnet configurations from YAML
  dr_role     = var.disaster_recovery_role
  aws_region  = var.aws_region
  owner       = var.owner

  depends_on = [module.vpcs,
                module.internet_gateway,
                module.transit_gateway_core]
}

#===================================================================================
# TRANSIT GATEWAY ATTACHMENTS
# Connects VPCs to Transit Gateway (multi-VPC only)
#===================================================================================
module "transit_gateway_attachments" {
  source    = "./modules/transit-gateway-attachments"
  for_each  = length(var.network_config) > 1 ? { for vpc in var.network_config : vpc.vpc_name => vpc } : {}  # Multi-VPC only

  vpc_name           = module.vpcs[each.key].vpc_name
  transit_gateway_id = module.transit_gateway_core[0].transit_gateway_id
  subnet_ids         = module.subnets[each.key].transit_subnet_ids  # Dedicated transit subnets
  vpc_id             = module.subnets[each.key].vpc_id

  dr_role    = var.disaster_recovery_role
  aws_region = var.aws_region
  owner      = var.owner

  depends_on = [module.subnets, module.transit_gateway_core, module.vpcs]
}

#===================================================================================
# DNS ENDPOINTS
# Creates Route53 Resolver endpoints for hybrid/multi-cloud DNS (multi-VPC only)
#===================================================================================
module "dns_endpoints" {
  source    = "./modules/dns-endpoints"
  for_each  = length(var.network_config) > 1 ? { for vpc in var.network_config : vpc.vpc_name => vpc } : {}  # Multi-VPC only

  vpc_id              = module.vpcs[each.key].vpc_id
  private_azs         = module.subnets[each.key].transit_subnet_ids  # Uses transit subnets
  vpc_name            = module.vpcs[each.key].vpc_name
  vpc_cidr            = module.vpcs[each.key].cidr_block
  private_subnet_ids  = module.subnets[each.key].private_subnet_ids
  security_group_id   = try(module.security_groups[each.key].dns_security_group_id, null)

  dr_role    = var.disaster_recovery_role
  owner      = var.owner
  aws_region = var.aws_region

  depends_on = [module.vpcs, module.subnets, module.security_groups]
}

#===================================================================================
# DNS FORWARDING RULES
# Configures DNS forwarding between VPCs (multi-VPC only)
#===================================================================================
module "dns_rules" {
  source    = "./modules/dns-rules"
  for_each  = length(var.network_config) > 1 ? { for vpc in var.network_config : vpc.vpc_name => vpc } : {}  # Multi-VPC only

  resolver_outbound_id = module.dns_endpoints[each.key].resolver_outbound_id
  resolver_inbound_ips = module.dns_endpoints[each.key].resolver_inbound_ips
  transit_destinations = try([for dest in each.value.transit_destinations : {
    dest_vpc_name    = dest.dest_vpc_name
    dest_cidr_block  = dest.dest_cidr_block
    dest_environment = dest.dest_environment
    dest_azs         = dest.dest_azs
  }], [])

  environment = each.value.environment
  owner       = var.owner
  aws_region  = var.aws_region
  dr_role     = var.disaster_recovery_role

  depends_on = [module.dns_endpoints]
}

#===================================================================================
# VPC ENDPOINTS
# Creates interface/gateway endpoints for AWS services (conditional per VPC)
#===================================================================================
module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"
  for_each = { for vpc in var.network_config : vpc.vpc_name => vpc if vpc.enable_vpc_endpoints }  # Conditional creation

  vpc_endpoints = try(each.value.vpc_endpoints, null)  # Endpoint list from config
  environment   = each.value.environment

  vpc_id             = module.vpcs[each.key].vpc_id
  vpc_name           = module.vpcs[each.key].vpc_name
  subnet_ids         = module.subnets[each.key].endpoint_subnet_ids  # Dedicated endpoint subnets
  route_table_ids    = module.subnets[each.key].endpoint_route_table_ids
  security_group_ids = [module.security_groups[each.key].endpoint_security_group_id]

  aws_region             = var.aws_region
  disaster_recovery_role = var.disaster_recovery_role

  depends_on = [module.vpcs, module.subnets]
}
