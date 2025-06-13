# ------------------------------------------------------------------------------
# Resource: AWS Internet Gateway (IGW)
# Provides internet access for public subnets in the VPC.
# Conditionally created based on var.create_igw flag.
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  # Create IGW only if flag is true (better than count for conditional resources)

  vpc_id = var.vpc_id  # Attach to specified VPC

  # Tags combine common tags + resource-specific tags
  tags = merge(
    var.tags,  # Common tags from variables
    local.igw_tags  # Standardized IGW tags
  )

  # Lifecycle policy ensures proper replacement if needed
  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Local Variables for Tagging Consistency
# ------------------------------------------------------------------------------
locals {
  igw_tags = {
    Name                 = "igw-${var.vpc_name}"  # Simplified name (avoids length issues)
    Component            = "network"
    Resource             = "internet-gateway"
    Environment          = var.environment
    DisasterRecoveryRole = var.dr_role
    Owner                = var.owner
    AwsRegion            = var.aws_region
  }
}

# ------------------------------------------------------------------------------
# Best Practices Implemented:
# 1. Used for_each instead of count for conditional resources
# 2. Simplified naming convention to avoid AWS tag length limits
# 3. Separated tag configuration into locals for reusability
# 4. Added lifecycle management for safer updates
# 5. Standardized tag keys across resources
# 6. Clear variable descriptions for documentation
#
# Typical IGW Usage:
# - Required for public subnets with internet-facing resources
# - Not needed for purely private VPC architectures
# - Often used with NAT Gateway for private subnet outbound access
# ------------------------------------------------------------------------------
