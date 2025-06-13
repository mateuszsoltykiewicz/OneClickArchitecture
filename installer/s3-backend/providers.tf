provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.role_arn
    session_name = "${var.disaster_recovery_role}-${var.environment}-bucket-${var.aws_region}-${var.owner}"
  }
}