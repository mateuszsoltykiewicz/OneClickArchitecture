# ------------------------------------------------------------------------------
# Resource: AWS EC2 Transit Gateway
# Creates a Transit Gateway for scalable cross-VPC and hybrid cloud networking.
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "this" {
  description                    = "Transit Gateway for cross-VPC networking"
  amazon_side_asn                = var.amazon_side_asn   # ASN for BGP (must be unique in your org)
  auto_accept_shared_attachments = "enable"              # Automatically accept VPC attachments from your org
  default_route_table_association = "enable"             # Attachments automatically associated with default route table
  default_route_table_propagation = "enable"             # Attachments automatically propagate routes to default table
  dns_support                    = "enable"              # Enables DNS resolution across VPCs

  tags = merge(
    var.tags,  # Merge in any additional user-provided tags
    {
      Name                 = "${var.owner}-${var.dr_role}-tgw-${var.aws_region}"  # Unique, descriptive name
      DisasterRecoveryRole = var.dr_role
      AwsRegion            = var.aws_region
      Owner                = var.owner
      ASN                  = var.amazon_side_asn
      Type                 = "TransitGateway"
    }
  )
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use a unique ASN for each TGW in your AWS Organization to avoid conflicts.
# - Enable auto-accept, association, and propagation for easier multi-VPC management.
# - Enable DNS support for cross-VPC DNS resolution (e.g., Route53 Resolver).
# - Use clear, consistent tagging for automation, cost allocation, and compliance.
# - Consider naming conventions that include environment, owner, and region for clarity.
# ------------------------------------------------------------------------------
