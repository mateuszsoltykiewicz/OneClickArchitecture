# ------------------------------------------------------------------------------
# Data Source: Select VPC by ID
# Retrieves details for the specified VPC by its ID.
# Useful for referencing VPC attributes elsewhere in your configuration.
# ------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  id = var.vpc_id  # The VPC ID provided as a variable
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Use this data source to access VPC attributes (e.g., CIDR block, tags) in other resources or outputs.
# - Ensures your configuration is robust and avoids hardcoding VPC details.
# - If you need to select a VPC by tags or filters, use the aws_vpc data source with 'filter' blocks instead.
# ------------------------------------------------------------------------------
