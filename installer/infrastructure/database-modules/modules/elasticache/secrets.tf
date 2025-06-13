# ------------------------------------------------------------------------------
# Resource: Random Password
# Generates a secure, random password for the database user.
# Special characters are enabled and restricted to a custom set for compatibility.
# ------------------------------------------------------------------------------

resource "random_password" "db_password" {
  length           = 32                # Password length (32 characters)
  special          = true              # Include special characters
  override_special = "!&#$^<>-"        # Restrict to these special characters for DB compatibility
}

# ------------------------------------------------------------------------------
# Resource: AWS Secrets Manager Secret
# Creates a new secret in AWS Secrets Manager to securely store DB credentials.
# The secret name includes the cluster name and a UUID for uniqueness.
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "cred-${var.long_cluster_name}-${uuid()}"  # Unique secret name per cluster
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
# - Use the Secrets Manager secret in your application or as the master password source for your database resource.
# ------------------------------------------------------------------------------

