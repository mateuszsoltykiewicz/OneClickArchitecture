# ------------------------------------------------------------------------------
# Resource: AWS VPC
# Creates a Virtual Private Cloud (VPC) with DNS support and hostnames enabled.
# ------------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block        # The primary CIDR block for the VPC
  enable_dns_support   = true                  # Enables DNS resolution within the VPC
  enable_dns_hostnames = true                  # Enables DNS hostnames for instances

  tags = merge(
    var.tags,  # Merge in any additional user-provided tags
    {
      Name                 = var.vpc_name                 # VPC name for identification
      Environment          = var.environment              # Environment tag (dev, prod, etc.)
      DisasterRecoveryRole = var.dr_role                  # DR classification (active/passive)
      AwsRegion            = var.aws_region               # Region for context
      Owner                = var.owner                    # Resource owner/team
      ShortName            = var.vpc_name                 # Short name for quick reference
      CiDr                 = var.cidr_block               # CIDR block for traceability
      Type                 = "VPC"                        # Resource type for cost tracking
    }
  )
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Enable DNS support and hostnames for service discovery and AWS integrations.
# - Use merge() to apply both global and resource-specific tags for cost allocation, automation, and compliance.
# - Ensure the CIDR block is unique and does not overlap with other VPCs in your environment.
# - Use clear, consistent tagging for all resources.
# ------------------------------------------------------------------------------
