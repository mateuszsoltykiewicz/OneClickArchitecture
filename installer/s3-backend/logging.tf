# Enable access logging (logs go to a separate bucket)
resource "aws_s3_bucket" "tf_state_logs" {
  bucket = "${var.disaster_recovery_role}-${var.environment}-tfstate-logs-${var.aws_region}-${var.owner}"
}

resource "aws_s3_bucket_logging" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  target_bucket = aws_s3_bucket.tf_state_logs.id
  target_prefix = "log/"
}