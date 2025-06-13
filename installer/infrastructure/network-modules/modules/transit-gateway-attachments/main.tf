# ------------------------------------------------------------------------------
# Resource: Transit Gateway VPC Attachment
# Attaches the specified VPC to the Transit Gateway using the provided subnets.
# Enables cross-VPC and hybrid network routing via the Transit Gateway.
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {

  transit_gateway_id = var.transit_gateway_id  # The ID of the Transit Gateway to attach to
  vpc_id             = var.vpc_id              # The VPC to attach
  subnet_ids         = var.subnet_ids          # List of subnet IDs (typically one per AZ for HA)

  tags = merge(
    var.tags,  # Common tags for all resources
    {
      Name                 = "tgw-attach-${var.transit_gateway_id}-${var.vpc_name}"  # Unique, descriptive name
      DisasterRecoveryRole = var.dr_role
      AwsRegion            = var.aws_region
      Owner                = var.owner
      Type                 = "VPCAttachment"
    }
  )
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Provide at least one subnet ID per AZ for high availability and fault tolerance.
# - Tag all attachments for cost allocation, automation, and compliance.
# - Use descriptive naming for the attachment for easy identification in the AWS Console.
# - Ensure the attached subnets are in private AZs for security and routing best practices.
# - If you use multiple attachments, consider adding environment or cluster name to the Name tag.
# ------------------------------------------------------------------------------
