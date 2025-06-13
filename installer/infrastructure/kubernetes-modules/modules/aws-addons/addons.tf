# ------------------------------------------------------------------------------
# Add-on: CoreDNS
# Installs CoreDNS cluster DNS provider for Kubernetes service discovery.
# Required for DNS resolution within the cluster.
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "coredns" {
  cluster_name = var.long_cluster_name
  addon_name   = "coredns"
  
  # Version format: <coredns-version>-eksbuild.<build-number>
  addon_version = var.coredns.version
  
  # Automatically overwrite conflicts during creation/updates
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # IAM role for service account (IRSA) for fine-grained permissions
  service_account_role_arn = var.coredns.role_arn

  tags = {
    Name                 = "CoreDNS Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# Add-on: kube-proxy
# Maintains network rules on nodes for pod communication.
# Required for proper Kubernetes networking functionality.
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.long_cluster_name
  addon_name   = "kube-proxy"
  
  # Version format: <k8s-version>-eksbuild.<build-number>
  addon_version = var.kube_proxy.version
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name                 = "Kube Proxy Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# Add-on: VPC CNI (Container Network Interface)
# Provides networking functionality for pods using AWS VPC networking.
# Essential for pod-to-pod and external communication.
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.long_cluster_name
  addon_name   = "vpc-cni"
  
  # Version format: <cni-version>-eksbuild.<build-number>
  addon_version = var.vpc_cni.version
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # IAM role for VPC CNI operations (ENI management)
  service_account_role_arn = var.vpc_cni.role_arn

  tags = {
    Name                 = "VPC-CNI Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# Add-on: EFS CSI Driver
# Enables dynamic provisioning of EFS volumes for persistent storage.
# Required for EFS-based persistent volumes in Kubernetes.
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name = var.long_cluster_name
  addon_name   = "aws-efs-csi-driver"
  
  # Version format: <driver-version>-eksbuild.<build-number>
  addon_version = var.efs_csi_driver.version
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # IAM role for EFS CSI driver operations
  service_account_role_arn = var.efs_csi_driver.role_arn

  tags = {
    Name                 = "EFS CSI Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# Add-on: S3 CSI Driver
# Provides capability to mount S3 buckets as volumes in pods.
# Enables direct S3 access for applications.
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "s3_csi_driver" {
  cluster_name = var.long_cluster_name
  addon_name   = "aws-mountpoint-s3-csi-driver"
  
  # Version format: <driver-version>-eksbuild.<build-number>
  addon_version = var.s3_csi_driver.version
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # IAM role for S3 CSI driver operations
  service_account_role_arn = var.s3_csi_driver.role_arn

  tags = {
    Name                 = "S3 CSI Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# Add-on: EKS Pod Identity Agent
# Manages pod identity associations for IAM roles.
# Required for IAM roles for service accounts (IRSA) functionality.
# ------------------------------------------------------------------------------
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.long_cluster_name
  addon_name   = "eks-pod-identity-agent"
  
  # Version format: <agent-version>-eksbuild.<build-number>
  addon_version = var.pod_identity_agent.version
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name                 = "Pod Identity Agent Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name         = var.long_cluster_name
  addon_name           = "aws-ebs-csi-driver"

  addon_version        = var.ebs_csi_driver.version

  service_account_role_arn = module.ebs_csi_driver.role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name                 = "EBS CSI Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

resource "aws_eks_addon" "snapshot-controller" {
  cluster_name = var.long_cluster_name
  addon_name   = "snapshot-controller"
  
  # Version format: <k8s-version>-eksbuild.<build-number>
  addon_version = var.snapshot_controller.version
  
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name                 = "Snapshot controller Add-on"
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    ClusterName          = var.long_cluster_name
  }
}

# ------------------------------------------------------------------------------
# General Notes:
# 1. Versioning: All addon_versions use EKS-optimized builds
# 2. Conflict Resolution: OVERWRITE automatically resolves conflicts
# 3. IAM Roles: Service accounts use IAM Roles for Service Accounts (IRSA)
# 4. Tagging: Consistent tagging for cost allocation and resource management
#
# Best Practices:
# - Always verify add-on version compatibility with your EKS version
# - Use OVERWRITE cautiously in production environments
# - Regularly update add-ons to receive security patches and new features
# - Monitor add-on health through CloudWatch and Kubernetes events
# ------------------------------------------------------------------------------
