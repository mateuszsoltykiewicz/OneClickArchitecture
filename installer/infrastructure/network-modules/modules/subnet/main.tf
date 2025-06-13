# SUBNETS: Create subnets based on input configuration
# - One subnet per AZ with configurable CIDR blocks
# - Public subnets auto-assign public IPs
# - Tags include Kubernetes cluster association if provided
resource "aws_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.tier == "Public" ? true : false

  tags = merge(
    var.tags,
    {
      Name                 = each.value.name
      Tier                 = each.value.tier    # Public/Private
      Purpose              = each.value.purpose # Kubernetes/Database/etc
      Environment          = var.environment
      DisasterRecoveryRole = var.dr_role
      AwsRegion            = var.aws_region
      Owner                = var.owner
      Type                 = "Subnet"
      VpcName              = var.vpc_name
      availabilityZone     = each.value.az
    },
    # Kubernetes-specific tags (conditionally added)
    each.value.purpose == "Kubernetes" ? {
      # Cluster identifier tag (required for EKS auto-discovery)
      "kubernetes.io/cluster/${var.long_cluster_name}" = "shared"
      "karpenter.sh/discovery" = var.long_cluster_name
      
      # ELB role tag (different for public/private subnets)
      (each.value.tier == "Public" ? "kubernetes.io/role/elb" : "kubernetes.io/role/internal-elb") = "1"
    } : {}
  )
}


# ELASTIC IPs: Create EIPs for NAT Gateways
# - Only for Private non-Database subnets
# - One EIP per qualifying subnet
resource "aws_eip" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if subnet.tier == "Private" && !contains(["Database", "Endpoint"], subnet.purpose) }
  domain = "vpc"
  
  tags = {
    Name                 = "eip-${var.vpc_name}"
    Environment          = var.environment
    Owner                = var.owner
    VpcId                = var.vpc_id
    VpcName              = var.vpc_name
    DisasterRecoveryRole = var.dr_role
    Type                 = "EIP"
    AwsRegion            = var.aws_region
  }
}

# NAT GATEWAYS: Create NAT resources for outbound private subnet traffic
# - One NAT per Private non-Database subnet
# - Uses EIPs created above
resource "aws_nat_gateway" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if subnet.tier == "Private" && !contains(["Database", "Endpoint"], subnet.purpose) }

  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.this[each.key].id

  tags = {
    Name                 = "nat-${each.key}"
    Environment          = var.environment
    Owner                = var.owner
    VpcId                = var.vpc_id
    VpcName              = var.vpc_name
    DisasterRecoveryRole = var.dr_role
    Type                 = "NAT"
    AwsRegion            = var.aws_region
  }
}

# ROUTE TABLES: Create one route table per subnet
# Note: This creates many route tables - consider consolidating by tier/purpose
resource "aws_route_table" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                 = "rt-${each.key}"
      SubnetName           = each.key            # Associated subnet name
      SubnetId             = aws_subnet.this[each.key].id
      Tier                 = each.value.tier
      Purpose              = each.value.purpose
      Type                 = "RouteTable"
      Environment          = var.environment
      DisasterRecoveryRole = var.dr_role
      VpcName              = var.vpc_name
      Owner                = var.owner
      AwsRegion            = var.aws_region
    }
  )
}

# INTERNET GATEWAY ROUTE: Public subnets route 0.0.0.0/0 to IGW
# - Only created if IGW exists (var.internet_gateway != false)
resource "aws_route" "igw" {
  for_each = { for subnet in var.subnets : 
    subnet.name => subnet 
    if subnet.tier == "Public" }

  route_table_id = aws_route_table.this[each.key].id
  gateway_id     = var.internet_gateway_id
  destination_cidr_block = "0.0.0.0/0"  # Default route to internet
}

resource "aws_route" "nat" {
  for_each = { 
    for subnet in var.subnets : 
    subnet.name => subnet 
    if subnet.tier == "Private" && !contains(["Database", "Endpoint"], subnet.purpose) 
  }

  route_table_id           = aws_route_table.this[each.key].id
  nat_gateway_id           = aws_nat_gateway.this[each.key].id
  destination_cidr_block   = "0.0.0.0/0"  # Default route to internet via NAT
}


# TRANSIT GATEWAY ROUTE: Private subnets route 10.0.0.0/8 to TGW
# - For Kubernetes, Database, Monitoring subnets
# - Only created if TGW exists (var.transit_gateway != false)
resource "aws_route" "tgw" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if subnet.tier == "Private" && !contains(["Kubernetes", "Monitoring"], subnet.purpose) && try(var.transit_gateway, false) != false && try(var.transit_gateway_id, null) != null }

  route_table_id         = aws_route_table.this[each.key].id
  transit_gateway_id     = try(var.transit_gateway_id, null)
  destination_cidr_block = "10.0.0.0/8"  # Common private network range
}

# INTERNAL ROUTE TABLES: Private non-Database subnets get NAT routes
# - Creates additional route tables for NAT configuration
# Note: Potential overlap with previous route tables
resource "aws_route_table" "internal" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if subnet.tier == "Private" && !contains(["Database", "Endpoint"], subnet.purpose) }

  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }
}

# ROUTE ASSOCIATIONS: Bind subnets to their route tables
# - Creates explicit 1:1 subnet to route table mapping
resource "aws_route_table_association" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}
