# ------------------------------------------------------------------------------
# EKS SECURITY GROUPS & RULES – WITH BEST PRACTICES
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Control Plane Security Group
# - Used for the EKS API server (managed by AWS)
# - Should only allow required inbound traffic (typically TCP/443 from nodes)
# - Outbound rules are rarely needed unless you have specific requirements
# ------------------------------------------------------------------------------

resource "aws_security_group" "control_plane" {
  count = var.create_security_group ? 1 : 0

  name        = "eks-control-plane-${var.long_cluster_name}"
  description = "EKS control plane security group"
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(
    var.tags,
    {
      Name                  = "eks-control-plane-${var.long_cluster_name}"
      Tier                  = "Private"
      Purpose               = "Control"
      Owner                 = var.owner
      VPCName               = var.long_vpc_name
      DisasterRecoveryRole  = var.disaster_recovery_role
      AwsRegion             = var.aws_region
      Environment           = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# Worker Node Security Group
# - Used for EKS worker nodes (EC2 instances)
# - Should allow:
#   * Outbound internet access for pulling images, updates, etc.
#   * Inbound from ALB (e.g., port 80/443 for HTTP/HTTPS apps)
#   * Inbound from other nodes for inter-node communication
#   * Inbound from control plane for API server communication (TCP/443)
# ------------------------------------------------------------------------------

resource "aws_security_group" "node" {
  count = var.create_security_group ? 1 : 0

  name        = "eks-node-${var.long_cluster_name}"
  description = "EKS worker node security group"
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(
    var.tags, local.base_tags,
    {
      Name                  = "eks-node-${var.long_cluster_name}"
      Tier                  = "Private"
      Purpose               = "Node"
      Owner                 = var.owner
      VPCName               = var.long_vpc_name
      DisasterRecoveryRole  = var.disaster_recovery_role
      AwsRegion             = var.aws_region
      Environment           = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# SECURITY GROUP RULES
# ------------------------------------------------------------------------------

# --- API SERVER ACCESS ---

# Allow inbound 443 (API server) from worker nodes to control plane
resource "aws_security_group_rule" "control_plane_ingress_node" {
  description              = "Allow nodes to communicate with API server"
  security_group_id        = aws_security_group.control_plane[0].id
  source_security_group_id = aws_security_group.node[0].id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

# Allow outbound 443 (API server) from worker nodes to control plane (if needed)
resource "aws_security_group_rule" "node_egress_api" {
  description              = "Allow nodes to connect to API server"
  security_group_id        = aws_security_group.node[0].id
  source_security_group_id = aws_security_group.control_plane[0].id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

# --- NODE INTERNET ACCESS ---

# Allow worker nodes outbound access to the internet (for pulling images, etc.)
resource "aws_security_group_rule" "node_egress_internet" {
  description       = "Allow nodes to access internet"
  security_group_id = aws_security_group.node[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# --- NODE SELF-COMMUNICATION ---

# Allow all traffic between nodes (required for Kubernetes networking)
resource "aws_security_group_rule" "node_ingress_self" {
  security_group_id = aws_security_group.node[0].id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
}

# ------------------------------------------------------------------------------
# BEST PRACTICES & SECURITY NOTES
# ------------------------------------------------------------------------------

# - Use the latest EKS-optimized AMIs and keep nodes patched [1].
# - Enable EKS audit logging for visibility [1].
# - Restrict API server access to only trusted sources (e.g., do NOT open 443 to 0.0.0.0/0 for production) [2][4].
# - Use RBAC and IAM roles for fine-grained access control [4][6].
# - Use network policies for pod-to-pod communication control [1][3][5].
# - Never allow SSH (port 22) from the internet to nodes [6].
# - Do not run containers as privileged or with host networking unless absolutely necessary [1][6].
# - Regularly review security group rules for least privilege.
# - Use separate security groups for control plane, nodes, and ALB for clear separation of concerns [2][3].
# - Monitor and audit all changes to security groups and cluster configuration [1][5].
# - Consider using tools like AWS GuardDuty, Security Hub, or open-source solutions for runtime threat detection [1].

# ------------------------------------------------------------------------------
# REFERENCES
# ------------------------------------------------------------------------------
# [1] https://www.wiz.io/academy/eks-security-best-practices
# [2] https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
# [3] https://lumigo.io/aws-eks/aws-eks-cluster-architecture-quick-start-best-practices/
# [4] https://blog.rad.security/blog/eks-best-practices-for-security
# [5] https://docs.aws.amazon.com/eks/latest/best-practices/network-security.html
# [6] https://cast.ai/blog/eks-security-checklist-10-best-practices-for-a-secure-cluster/

