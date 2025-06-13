resource "aws_vpc_endpoint" "this" {
  for_each = { for ep in var.vpc_endpoints : "${ep.service_type}-${ep.service_name}" => ep }

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value.service_name}"
  vpc_endpoint_type   = each.value.service_type
  private_dns_enabled = each.value.service_type == "Interface" ? true : false

  # Gateway endpoints require route table associations
  route_table_ids = each.value.service_type == "Gateway" ? var.route_table_ids : null

  # Interface endpoints require subnet and security group associations
  subnet_ids          = each.value.service_type == "Interface" ? var.subnet_ids : null
  security_group_ids  = each.value.service_type == "Interface" ? var.security_group_ids : null
  policy              = try(each.value.policy, false) != false ? each.value.policy : null

  tags = merge(
    var.tags,
    {
      Name                 = "${each.value.service_name}-endpoint-${var.vpc_name}"
      ServiceType          = each.value.service_type
      VpcName              = var.vpc_name
      VpcId                = var.vpc_id
      AwsRegion            = var.aws_region
      DisasterRecoveryRole = var.disaster_recovery_role
      Environment          = var.environment
      Type                 = "VPCEndpoint"
    }
  )
}