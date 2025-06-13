# ------------------------------------------------------------------------------
# Resource: Security Group for PostgreSQL Aurora Cluster
# Defines network access rules for the database cluster.
# ------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "security-${var.long_cluster_name}"  # Unique SG name
  description = "Security group for PostgreSQL RDS Aurora cluster"
  vpc_id      = data.aws_vpc.selected.id  # Attach to selected VPC

  # INBOUND RULES
  ingress {
    description = "Allow PostgreSQL connections from private network"
    from_port   = 5432  # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]  # Broad private network range (consider narrowing)
  }

  # OUTBOUND RULES
  egress {
    description = "Allow outbound PostgreSQL traffic"
    from_port   = 5432
    to_port     = 5432
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
    Purpose              = "PostgreSQL"          # Resource purpose
    Tier                 = "Private"             # Network tier
    Owner                = var.owner             # Ownership tracking
  }
}

# ------------------------------------------------------------------------------
# Security Recommendations:
# 1. Ingress: Narrow the CIDR range to specific subnets or security groups
#    (e.g., ["10.1.0.0/16"] instead of 10.0.0.0/8)
# 2. Egress: Restrict to specific destinations if possible
# 3. Add explicit description fields to all rules
# 4. Consider using security group references instead of CIDR blocks
#    (security_group_id = module.app_sg.security_group_id)
# ------------------------------------------------------------------------------
