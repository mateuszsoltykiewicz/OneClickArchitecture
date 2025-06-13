# ------------------------------------------------------------------------------
# Resource: Security Group for MongoDB/DocumentDB Cluster
# Defines network access rules for secure communication with the cluster.
# ------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "security-${var.long_cluster_name}"  # Unique SG name
  description = "Security group for MongoDB cluster"
  vpc_id      = data.aws_vpc.selected.id  # Attach to selected VPC

  # INBOUND RULES
  ingress {
    description = "Allow MongoDB connections from private network"
    from_port   = 27017  # MongoDB/DocumentDB default port
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]  # Broad private network range (consider narrowing)
  }

  # OUTBOUND RULES
  egress {
    description = "Allow outbound MongoDB traffic"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Wide open egress (common but review for compliance)
  }

  # TAGGING
  tags = {
    Name                 = "security-${var.long_cluster_name}"  # Identifier
    Environment          = var.environment       # Environment context
    AwsRegion            = var.aws_region        # Region tracking
    DisasterRecoveryRole = var.disaster_recovery_role  # DR classification
    VPCName              = var.vpc_name          # Associated VPC
    Purpose              = "mongodb"             # Resource purpose
    Tier                 = "Private"             # Network tier
    Owner                = var.owner             # Ownership tracking
  }
}

# ------------------------------------------------------------------------------
# Security Recommendations:
# 1. Narrow ingress CIDR range to specific subnets (e.g., ["10.1.0.0/16"])
# 2. Restrict egress to specific security groups or IP ranges if possible
# 3. Add explicit description fields to all rules
# 4. Consider security group references instead of CIDR blocks:
#    security_group_id = module.application_sg.security_group_id
# 5. Enable VPC flow logs to monitor traffic patterns
# ------------------------------------------------------------------------------
