# Enforce SSL requests only
resource "aws_s3_bucket_policy" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Only allow access from specific IAM roles/users
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::775292115464:role/terraform_oidc"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.tf_state.arn}",
          "${aws_s3_bucket.tf_state.arn}/*"
        ]
      },
      # Enforce SSL
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket.tf_state.arn}",
          "${aws_s3_bucket.tf_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}