# ------------------------------------------------------------------------------
# AWS Provider Configuration
# Sets the AWS region dynamically from the loaded configuration.
# ------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.role_arn
    session_name = "${var.disaster_recovery_role}-${var.environment}-bucket-${var.aws_region}-${var.owner}"
  }
}
# ------------------------------------------------------------------------------
# Best Practices:
# - Use a variable or local value for region to support multi-region or environment-agnostic deployments.
# - For multi-account or multi-region setups, consider using provider aliases:
#     provider "aws" {
#       alias  = "us_east_1"
#       region = "us-east-1"
#     }
# - For automation, ensure AWS credentials are provided via environment variables, shared credentials file, or a credentials block.
# - Document in your README how and where region is set for clarity.
# ------------------------------------------------------------------------------
