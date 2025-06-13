# ------------------------------------------------------------------------------
# Resource: Private Route53 Hosted Zone
# Creates a private DNS zone associated with the specified VPC.
# Used for internal DNS resolution within the VPC (e.g., for Kubernetes, microservices, etc.).
# ------------------------------------------------------------------------------

resource "aws_route53_zone" "private" {
  name = "${var.environment}.${lower(var.owner)}"  # DNS zone name, e.g., "prod.acme"

  vpc {
    vpc_id = var.vpc_id  # Associate the zone with the specified VPC for private resolution
  }

  tags = {
    Name                 = "${var.environment}.${lower(var.owner)}"  # Resource name for easy identification
    Environment          = var.environment                           # Deployment environment (dev, prod, etc.)
    Owner                = var.owner                                 # Resource owner or team
    AwsRegion            = var.aws_region                            # AWS region for context
    DisasterRecoveryRole = var.disaster_recovery_role                # DR classification (primary/secondary)
    Type                 = "Route53Zone"                             # Resource type for cost tracking
  }
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure the zone name matches your internal DNS naming convention.
# - The zone will only be resolvable from within the associated VPC.
# - You can associate additional VPCs with this zone using the aws_route53_zone_association resource if needed.
# - Use clear, consistent tagging for cost allocation, automation, and compliance.
# - If you plan to use this zone for Kubernetes, ensure your cluster and nodes use this VPC.
# ------------------------------------------------------------------------------
