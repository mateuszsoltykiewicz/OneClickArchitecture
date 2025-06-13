# ------------------------------------------------------------------------------
# Allow Node Group to Access EKS Control Plane (Ingress)
# Allows traffic from the node security group to the control plane security group on port 443 (API server).
# ------------------------------------------------------------------------------
#resource "aws_security_group_rule" "control_plane_ingress" {
#  type                     = "ingress"
#  from_port                = 443
#  to_port                  = 443
#  protocol                 = "tcp"
#  source_security_group_id = var.node_security_group_id      # Nodes as source
#  security_group_id        = var.control_plane_security_group_id  # Control plane as target
#}

# ------------------------------------------------------------------------------
# Allow EKS Control Plane to Access Node Group (Egress)
# Allows the control plane to send traffic to the node group on port 443 (for webhook calls, etc.).
# ------------------------------------------------------------------------------
#resource "aws_security_group_rule" "control_plane_egress" {
#  type                     = "egress"
#  from_port                = 443
#  to_port                  = 443
#  protocol                 = "tcp"
#  source_security_group_id = var.node_security_group_id      # Nodes as destination
#  security_group_id        = var.control_plane_security_group_id  # Control plane as source
#}

# ------------------------------------------------------------------------------
# Allow Nodes to Communicate with Each Other (All Ports/Protocols)
# Enables full mesh networking within the node group (required for Kubernetes pod and service networking).
# ------------------------------------------------------------------------------
#resource "aws_security_group_rule" "nodes_ingress_self" {
#  type              = "ingress"
#  from_port         = 0
#  to_port           = 65535
#  protocol          = "-1"                     # All protocols
#  self              = true                     # Rule applies to the same security group
#  security_group_id = var.node_security_group_id
#}

# ------------------------------------------------------------------------------
# Best Practices:
# - These rules are essential for EKS cluster and node communication.
# - You may further restrict ports/protocols for tighter security if your workloads allow.
# - Always review AWS EKS security group recommendations for your EKS version.
# ------------------------------------------------------------------------------
