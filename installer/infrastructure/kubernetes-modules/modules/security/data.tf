# ------------------------------------------------------------------------------
# Data Source: Select AWS VPC by Name Tag
# Retrieves the VPC that matches the specified 'Name' tag.
# ------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"        # Filter by the 'Name' tag key
    values = [var.long_vpc_name]  # Match the VPC with the given name from variable
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure the 'Name' tag is unique across your AWS account to avoid ambiguous results.
# - If multiple VPCs share the same name, consider adding additional filters (e.g., Environment, Region).
# - Use the returned VPC ID (data.aws_vpc.selected.id) for referencing in other resources.
# ------------------------------------------------------------------------------
