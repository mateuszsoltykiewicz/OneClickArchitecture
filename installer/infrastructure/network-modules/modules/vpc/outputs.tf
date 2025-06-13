# ------------------------------------------------------------------------------
# Output: VPC ID
# The unique identifier for the created VPC.
# ------------------------------------------------------------------------------
output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the created VPC."
}

# ------------------------------------------------------------------------------
# Output: VPC ARN
# The Amazon Resource Name for the created VPC.
# ------------------------------------------------------------------------------
output "vpc_arn" {
  value       = aws_vpc.this.arn
  description = "The ARN of the created VPC."
}

# ------------------------------------------------------------------------------
# Output: Environment
# The environment tag associated with this VPC (e.g., dev, prod).
# ------------------------------------------------------------------------------
output "environment" {
  value       = var.environment
  description = "The environment associated with this VPC."
}

# ------------------------------------------------------------------------------
# Output: VPC Name
# The name tag used for the VPC.
# ------------------------------------------------------------------------------
output "vpc_name" {
  value       = var.vpc_name
  description = "The name of the VPC."
}

# ------------------------------------------------------------------------------
# Output: AWS Region
# The AWS region in which the VPC is deployed.
# ------------------------------------------------------------------------------
output "aws_region" {
  value       = var.aws_region
  description = "The AWS region where the VPC is deployed."
}

# ------------------------------------------------------------------------------
# Output: CIDR Block
# The primary CIDR block used for the VPC.
# ------------------------------------------------------------------------------
output "cidr_block" {
  value       = var.cidr_block
  description = "The CIDR block of the VPC."
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Descriptions make outputs self-documenting for module consumers and in `terraform output`.
# - Outputting both IDs and ARNs is helpful for integration with other AWS services.
# - Outputting environment, name, and region can simplify debugging and cross-module references.
# ------------------------------------------------------------------------------
