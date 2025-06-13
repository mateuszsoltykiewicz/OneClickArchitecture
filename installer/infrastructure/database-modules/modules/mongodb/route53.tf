# ------------------------------------------------------------------------------
# Resource: Route53 DNS Record for MongoDB (DocumentDB)
# Creates a CNAME record in Route53 pointing to the DocumentDB cluster endpoint.
# Only created if DNS integration (var.route53) is enabled.
# ------------------------------------------------------------------------------

resource "aws_route53_record" "mongodb" {
  # Conditionally create this record if Route53 integration is enabled
  count = try(var.route53, false) != false ? 1 : 0

  # The Route53 zone in which to create the record (must exist and be private if required)
  zone_id = data.aws_route53_zone.selected[0].id

  # DNS name for the record, e.g., "mycluster.myenv.myowner"
  name = "${var.short_cluster_name}.${data.aws_route53_zone.selected[0].name}"

  type = "CNAME"  # CNAME record points one DNS name to another

  ttl = 300  # Time-to-live for DNS record (in seconds)

  # The DNS target for this record: the DocumentDB cluster endpoint
  records = [aws_docdb_cluster.this.endpoint]
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure the Route53 zone exists and matches your environment/owner naming convention.
# - The CNAME will allow applications to use a stable DNS name for the DocumentDB cluster.
# - If you have multiple clusters, use unique short_cluster_name values to avoid DNS conflicts.
# ------------------------------------------------------------------------------
