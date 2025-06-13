# ------------------------------------------------------------------------------
# Resource: Route53 DNS Record for EKS Cluster Endpoint
# Creates a CNAME record in the selected private Route53 zone, pointing to the EKS cluster endpoint.
# ------------------------------------------------------------------------------

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.selected.id

  # DNS name for the record, e.g., "mycluster.prod.acme"
  name    = "${var.short_cluster_name}.${data.aws_route53_zone.selected.name}"

  type    = "CNAME"  # CNAME record points one DNS name to another
  ttl     = 300      # Time-to-live for DNS record (in seconds)

  # The DNS target for this record: the EKS cluster endpoint (API server URL)
  records = [var.cluster_endpoint]
}

# ------------------------------------------------------------------------------
# Best Practices:
# - Ensure the cluster endpoint is a DNS name (not an IP address) for CNAME records.
# - Use this DNS name in your kubeconfig or application deployments for stable access.
# - If you use multiple environments or clusters, ensure short_cluster_name is unique within the zone.
# ------------------------------------------------------------------------------
