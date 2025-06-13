# ------------------------------------------------------------------------------
# Resource: Random Password
# Generates a secure, random password for the database user.
# Special characters are disabled for compatibility with most database engines.
# ------------------------------------------------------------------------------

resource "random_password" "db_password" {
  length  = 16        # Password length (16 characters)
  special = false     # Exclude special characters (set to true if your DB engine allows)
}

# ------------------------------------------------------------------------------
# Resource: AWS Secrets Manager Secret
# Creates a new secret in AWS Secrets Manager to securely store DB credentials.
# The secret name includes the cluster name and a UUID for uniqueness.
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "creds-${var.long_cluster_name}-${uuid()}"  # Unique secret name per cluster
}

# ------------------------------------------------------------------------------
# Resource: AWS Secrets Manager Secret Version
# Stores the actual credentials (username and password) in the secret as a JSON string.
# The password is taken from the random_password resource above.
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret_version" "db_creds_value" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.db_password.result
  })
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Reference aws_secretsmanager_secret.db_credentials.arn or .name to pass the secret to RDS, Aurora, or DocumentDB.
# - Never output or log the actual password or secret string in Terraform outputs.
# - This setup avoids hardcoding sensitive credentials in your Terraform code or state files.
# - Consider using the Secrets Manager secret in your application or as the master password source for your database resource.
# ------------------------------------------------------------------------------
