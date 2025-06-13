# outputs.tf

# Map of all subnet names to their IDs (key: subnet name, value: subnet ID)
output "subnet_ids" {
  value = try({ for k, v in aws_subnet.this : k => v.id }, null)
}

# Map of private subnet IDs to their VPC/subnet details 
# (Only subnets with tag Tier="Private")
output "private_subnets" {
  value = try({ for subnet in aws_subnet.this : subnet.id => {
    vpc_id    = subnet.vpc_id
    subnet_id = subnet.id
  } if subnet.tags.Tier == "Private"}, null)
}

# Map of transit subnet IDs to their AZs 
# (Requires tags: Tier="Private" AND Purpose="Transit")
output "private_azs" {
  value = try({ for subnet in aws_subnet.this : subnet.id => {
    subnet_id = subnet.id
    subnet_az = subnet.tags.availabilityZone
  } if subnet.tags.Tier == "Private" && subnet.tags.Purpose == "Transit" }, null)
}

# Direct passthrough of input VPC ID
output "vpc_id" {
  value = var.vpc_id
}

# List of route table IDs for private subnets (tag Tier="Private")
output "private_route_table_ids" {
  value = try([for route_table in aws_route_table.this : route_table.id if route_table.tags.Tier == "Private"], null)
}

# List of route table IDs for Kubernetes endpoints 
# (tags Tier="Private" AND Purpose="Kubernetes")
output "endpoint_route_table_ids" {
  value = try([for route_table in aws_route_table.this : route_table.id if route_table.tags.Tier == "Private" && route_table.tags.Purpose == "Kubernetes"], null)
}

# List of public route table IDs (tag Tier="Public")
output "public_route_table_ids" {
  value = try([for route_table in aws_route_table.this : route_table.id if route_table.tags.Tier == "Public"], null)
}

# List of transit subnet IDs (tags Tier="Private" AND Purpose="Transit")
output "transit_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Private" && subnet.tags.Purpose == "Transit"], null)
}

# List of Kubernetes endpoint subnet IDs 
# (tags Tier="Private" AND Purpose="Kubernetes")
output "endpoint_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Private" && subnet.tags.Purpose == "Endpoints" ], null)
}

# List of all private subnet IDs (tag Tier="Private")
output "private_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Private"], null)
}

output "public_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Public"], null)
}

# List of database subnet IDs 
output "database_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Private" && subnet.tags.Purpose == "Database" ], null)
}

# List of public Kubernetes subnet IDs 
output "kubernetes_public_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Public" && subnet.tags.Purpose == "Kubernetes" ], null)
}

output "kubernetes_private_subnet_ids" {
  value = try([for subnet in aws_subnet.this : subnet.id if subnet.tags.Tier == "Private" && subnet.tags.Purpose == "Kubernetes" ], null)
}

# ------------------------------------------------------------------------------
# Important Notes:
# 1. Tag Consistency: All filters rely on correct tagging (Tier/Purpose). Ensure:
#    - Public subnets: Tier="Public"
#    - Private subnets: Tier="Private"
#    - Purpose tags: "Transit", "Kubernetes", "Database", etc.
#
# 3. Route Table Strategy: Current 1:1 subnet:route table ratio might be 
#    inefficient. Consider consolidating to:
#    - 1 public route table for all public subnets
#    - 1 private route table per AZ
#
# 4. NAT Gateway Efficiency: Current 1:1 NAT:subnet ratio could be optimized to
#    1 NAT per AZ
# ------------------------------------------------------------------------------
