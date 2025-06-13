resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.disaster_recovery_role}-${var.environment}-terraform-${var.aws_region}-${var.owner}"

  # Enable versioning for state rollback
  versioning {
    enabled = true
  }

  # Add tags for ownership and auditing
  tags = {
    Name                  = "${var.disaster_recovery_role}-${var.environment}-terraform-${var.aws_region}-${var.owner}"
    Environment           = var.environment
    Owner                 = var.owner
    AwsRegion             = var.aws_region
    DisasterRecoveryRole  = var.disaster_recovery_role
    Purpose               = "Terraform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
