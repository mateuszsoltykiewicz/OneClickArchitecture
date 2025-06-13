# ------------------------------------------------------------------------------
# Resource: Security Group for ElastiCache (Redis) Cluster
# Defines network access rules for secure communication with the Redis cluster.
# ------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "security-${var.long_cluster_name}"  # Unique security group name
  description = "Security group for ElastiCache cluster"
  vpc_id      = data.aws_vpc.selected.id             # Attach to the selected VPC

  # INBOUND RULES
  ingress {
    description = "Allow Redis connections from private network"
    from_port   = 6379            # Redis default port
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]  # Broad private network range (consider narrowing for production)
  }

  # OUTBOUND RULES
  egress {
    description = "Allow outbound Redis traffic"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Wide open egress (review for compliance requirements)
  }

  # TAGGING
  tags = {
    Name                 = "security-${var.long_cluster_name}"  # Identifier
    Environment          = var.environment                      # Environment context
    AwsRegion            = var.aws_region                       # AWS region
    DisasterRecoveryRole = var.disaster_recovery_role           # DR classification
    VPCName              = var.vpc_name                         # Associated VPC
    Purpose              = "Elastic"                            # Resource purpose
    Tier                 = "Private"                            # Network tier
    Owner                = var.owner                            # Ownership tracking
  }
}

# ------------------------------------------------------------------------------
# Security Recommendations:
# 1. Narrow the ingress CIDR range to specific subnets or security groups for better security.
#    For example, ["10.1.0.0/16"] or use security group references.
# 2. Restrict egress to only what is necessary, if possible.
# 3. Add explicit description fields to all rules for easier management.
# 4. Enable VPC flow logs to monitor and audit traffic patterns.
# ------------------------------------------------------------------------------
