# ------------------------------------------------------------------------------
# Resource: AWS RDS Aurora Cluster (PostgreSQL)
# Creates a managed Aurora PostgreSQL cluster with configurable settings.
# ------------------------------------------------------------------------------

resource "aws_rds_cluster" "aurora_clusters" {
  # Cluster identification and networking
  cluster_identifier = var.long_cluster_name  # Unique identifier for the cluster
  vpc_security_group_ids = [aws_security_group.this.id]  # Attach custom security group
  db_subnet_group_name   = aws_db_subnet_group.this.name  # Use specified subnets
  availability_zones     = var.availability_zones  # Distribute nodes across AZs

  # Database engine configuration
  engine              = "aurora-postgresql"  # Aurora PostgreSQL-compatible edition
  engine_mode         = "provisioned"        # Traditional writer/reader setup
  engine_version      = var.engine_version   # PostgreSQL version (e.g., "13.7")
  port                = 5432                 # Default PostgreSQL port

  # Authentication and security
  master_username     = var.username  # Admin username (avoid default 'postgres')
  master_password     = "dfaidfaidfaidfai"  # WARNING: Hardcoded credentials - use random_password or AWS Secrets Manager
  storage_encrypted   = var.storage_encrypted  # Enable storage encryption (KMS)
  ca_certificate_identifier = var.ca_certificate_identifier  # SSL/TLS certificate

  # Maintenance and operations
  apply_immediately           = var.apply_immediately  # Apply changes without maintenance window
  skip_final_snapshot         = var.skip_final_snapshot  # Bypass final snapshot on deletion (caution!)
  allow_major_version_upgrade = var.allow_major_version_upgrade  # Permit major version upgrades
  deletion_protection         = var.deletion_protection  # Prevent accidental deletion

  # Database naming
  database_name = lower(var.owner)  # Initial database name (lowercase enforced)

  # Resource tagging
  tags = {
    Name                 = var.long_cluster_name  # Full descriptive name
    DatabaseName         = var.owner             # Owner/organization name
    Environment          = var.environment       # Deployment environment
    VPCName              = var.vpc_name          # Associated VPC
    DisasterRecoveryRole = var.disaster_recovery_role  # DR role for automation
    ShortClusterName     = var.short_cluster_name  # Short identifier
    AWSRegion            = var.aws_region        # AWS region
    Engine               = "aurora-postgresql"   # Engine type
    Owner                = var.owner             # Responsible team/person
    DBType               = var.db_type           # Custom type classification (ensure var.db_type exists)
    Type                 = "Database"            # Resource category
  }
}
