# ------------------------------------------------------------------------------
# Resource: Route53 DNS Record for ElastiCache (Redis)
# Creates a CNAME record in Route53 pointing to the Redis primary endpoint.
# Only created if DNS integration (var.route53) is enabled.
# ------------------------------------------------------------------------------

resource "aws_route53_record" "elasticache" {
  # Only create this record if Route53 integration is enabled
  count = try(var.route53, false) != false ? 1 : 0

  # The Route53 zone in which to create the record (must exist and be private if required)
  zone_id = data.aws_route53_zone.selected[0].id

  # DNS name for the record, e.g., "myredis.myenv.myowner"
  name = "${var.short_cluster_name}.${data.aws_route53_zone.selected[0].name}"

  type = "CNAME"  # CNAME record points one DNS name to another

  ttl = 300  # Time-to-live for DNS record (in seconds)

  # The DNS target for this record: the Redis primary endpoint address
  records = [aws_elasticache_replication_group.this.primary_endpoint_address]
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure the Route53 zone exists and matches your naming convention.
# - The CNAME allows applications to use a stable DNS name for the Redis cluster.
# - If using cluster mode, you may also want to output or create a record for the
#   configuration endpoint: aws_elasticache_replication_group.this.configuration_endpoint_address
# ------------------------------------------------------------------------------
