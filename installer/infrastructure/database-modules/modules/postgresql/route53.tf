# ------------------------------------------------------------------------------
# Resource: Route53 DNS Record for Elasticache (or Aurora)
# Creates a CNAME record in Route53, pointing to the specified cluster endpoint.
# This is only created if DNS integration (var.route53) is enabled.
# ------------------------------------------------------------------------------

resource "aws_route53_record" "elasticache" {
  # Only create this record if Route53 integration is enabled
  count = try(var.route53, false) != false ? 1 : 0

  # The Route53 zone in which to create the record (must exist and be private if required)
  zone_id = data.aws_route53_zone.selected[0].id

  # DNS name for the record, e.g., "mycluster.myenv.myowner"
  name = "${var.short_cluster_name}.${data.aws_route53_zone.selected[0].name}"

  type = "CNAME"  # CNAME record points one DNS name to another

  ttl = 300  # Time-to-live for DNS record (in seconds)

  # The DNS target for this record.
  # NOTE: This currently points to the Aurora cluster endpoint.
  #       If this is meant for Elasticache, you should use the Elasticache endpoint instead:
  #       [aws_elasticache_replication_group.<name>.primary_endpoint_address]
  records = [aws_rds_cluster.aurora_clusters.endpoint]
}
