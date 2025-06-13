# ------------------------------------------------------------------------------
# Resource: AWS DocumentDB Cluster
# Creates a managed DocumentDB cluster with configurable settings.
# ------------------------------------------------------------------------------

resource "aws_docdb_cluster" "this" {
  # Cluster Identification
  cluster_identifier = "mongo-${var.long_cluster_name}"  # Unique cluster identifier
  engine             = "docdb"  # DocumentDB engine (MongoDB-compatible)

  # Authentication (Security Note: Hardcoded credentials - use random_password or Secrets Manager)
  master_username = var.username
  master_password = "dfaidfaidfaidfai"  # WARNING: Hardcoded password - replace with secure method

  # Networking
  db_subnet_group_name   = aws_docdb_subnet_group.this.name  # Subnets for cluster nodes
  vpc_security_group_ids = [aws_security_group.this.id]      # Security group rules
  port                   = 27017  # Default MongoDB/DocumentDB port

  # High Availability
  availability_zones = var.availability_zones  # Distribute nodes across AZs

  # Database Configuration
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.custom_tls.name  # TLS settings

  # Lifecycle Management
  skip_final_snapshot          = var.skip_final_snapshot  # Skip snapshot on deletion (caution!)
  apply_immediately            = var.apply_immediately    # Apply changes without maintenance window
  deletion_protection          = var.deletion_protection  # Prevent accidental deletion
  preferred_maintenance_window = var.mw                   # Maintenance window (e.g., "sun:03:00-sun:04:00")

  # Storage
  storage_encrypted = var.storage_encrypted  # Enable storage encryption (KMS)
  storage_type      = var.storage_type       # Storage type (e.g., "io1")

  # Resource Tagging
  tags = {
    Name                 = "mongo-${var.long_cluster_name}"  # Descriptive name
    ShortName            = "mongo-${var.short_cluster_name}" # Short identifier
    Environment          = var.environment       # Deployment environment
    AwsRegion            = var.aws_region        # AWS region
    DisasterRecoveryRole = var.disaster_recovery_role  # DR classification
    VPCName              = var.vpc_name          # Associated VPC
    Owner                = var.owner             # Responsible team/person
    DBType               = var.db_type           # Database type classification
    Type                 = "Database"            # Resource category
  }
}

# ------------------------------------------------------------------------------
# Security Recommendations:
# 1. Replace hardcoded password with:
#    master_password = random_password.db_password.result
#    And store it in AWS Secrets Manager
# 2. Always set storage_encrypted = true in production
# 3. Use deletion_protection = true for production clusters
# 4. Ensure maintenance windows align with operational schedules
# ------------------------------------------------------------------------------
