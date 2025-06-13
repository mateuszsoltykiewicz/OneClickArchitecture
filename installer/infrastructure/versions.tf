# ------------------------------------------------------------------------------
# Terraform Provider Requirements
# Locks the AWS provider to a compatible version for reproducible builds.
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Official AWS provider from HashiCorp
      version = "~> 5.95.0"       # Use any 5.x version >= 5.95.0 and < 6.0.0
    }
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Pin the provider version to avoid unexpected breaking changes.
# - Review the AWS provider CHANGELOG before upgrading to a new major version.
# - Consider using a `required_version` block to pin Terraform CLI version as well:
#
#   terraform {
#     required_version = ">= 1.5.0, < 2.0.0"
#     required_providers { ... }
#   }
#
# - Document provider and Terraform version requirements in your README for team clarity.
# ------------------------------------------------------------------------------
