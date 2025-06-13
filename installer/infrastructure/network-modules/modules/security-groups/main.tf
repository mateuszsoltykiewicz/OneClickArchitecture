# main.tf

# ------------------------------------------------------------------------------
# Security Groups Module
# Manages network security groups for different tiers and purposes in a VPC
# ------------------------------------------------------------------------------

# ========================
# Private Security Group
# ========================
resource "aws_security_group" "private" {
  count = var.enable_private_security_group ? 1 : 0

  name        = "private-${var.vpc_name}"
  description = "Private security group for internal VPC communication"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, local.standard_tags, {
    Tier                  = "Private"
    Purpose               = "InternalCommunication"
    Owner                 = var.owner
    VPCName               = var.vpc_name
    DisasterRecoveryRole  = var.dr_role
    AwsRegion             = var.aws_region
    Environment           = var.environment
  })
}

resource "aws_security_group_rule" "private_ingress" {
  count = var.enable_private_security_group ? 1 : 0

  description       = "Allow internal VPC traffic"
  security_group_id = aws_security_group.private[0].id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group_rule" "private_egress" {
  count = var.enable_private_security_group ? 1 : 0

  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.private[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ========================
# DNS Security Group
# ========================
resource "aws_security_group" "dns" {
  count = var.dns ? 1 : 0

  name        = "dns-${var.vpc_name}"
  description = "Security group for DNS resolution"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, local.standard_tags, {
    Tier                  = "Private"
    Purpose               = "DNS"
    Owner                 = var.owner
    VPCName               = var.vpc_name
    DisasterRecoveryRole  = var.dr_role
    AwsRegion             = var.aws_region
    Environment           = var.environment
  })
}

resource "aws_security_group_rule" "dns_ingress" {
  count = var.dns ? 1 : 0

  description       = "Allow DNS inbound traffic"
  security_group_id = aws_security_group.dns[0].id
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [local.dns_cidr_blocks]
}

resource "aws_security_group_rule" "dns_egress" {
  count = var.dns ? 1 : 0

  description       = "Allow DNS outbound traffic"
  security_group_id = aws_security_group.dns[0].id
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ========================
# VPC Endpoints Security Group
# ========================
resource "aws_security_group" "endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name        = "endpoints-${var.vpc_name}"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, local.standard_tags, {
    Tier                  = "Private"
    Purpose               = "VPCEndpoints"
    Owner                 = var.owner
    VPCName               = var.vpc_name
    DisasterRecoveryRole  = var.dr_role
    AwsRegion             = var.aws_region
    Environment           = var.environment
  })
}

resource "aws_security_group_rule" "endpoints_https_ingress" {
  count = var.enable_vpc_endpoints ? 1 : 0

  description       = "Allow HTTPS access to VPC endpoints"
  security_group_id = aws_security_group.endpoints[0].id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group_rule" "endpoints_https_egress" {
  count = var.enable_vpc_endpoints ? 1 : 0

  description       = "Allow HTTPS access to VPC endpoints"
  security_group_id = aws_security_group.endpoints[0].id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
}

# ========================
# Public Security Group
# ========================
resource "aws_security_group" "public" {
  count = var.enable_public_security_group ? 1 : 0

  name        = "public-${var.vpc_name}"
  description = "Security group for public internet access"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, local.standard_tags, {
    Name                  = "public-${var.vpc_name}"
    Tier                  = "Public"
    Purpose               = "InternetAccess"
    Owner                 = var.owner
    VPCName               = var.vpc_name
    DisasterRecoveryRole  = var.dr_role
    AwsRegion             = var.aws_region
    Environment           = var.environment
  })
}

resource "aws_security_group_rule" "ingress_public_https" {
  count = var.enable_public_security_group ? 1 : 0

  description       = "Allow HTTPS traffic"
  security_group_id = aws_security_group.public[0].id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_public_https" {
  count = var.enable_public_security_group ? 1 : 0

  description       = "Allow HTTPS traffic"
  security_group_id = aws_security_group.public[0].id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}


