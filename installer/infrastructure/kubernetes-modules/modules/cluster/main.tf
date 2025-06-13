# ------------------------------------------------------------------------------
# EKS Cluster Module Configuration
# Creates an EKS cluster with managed node groups and IAM roles.
# ------------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"  # Pinned version for stability

  # Cluster Identification
  cluster_name = var.long_cluster_name  # Full descriptive name for the cluster

  # Networking Configuration
  vpc_id                   = data.aws_vpc.selected.id                  # VPC selected via tags
  subnet_ids               = data.aws_subnets.cluster_subnets_ids.ids  # Worker node subnets
  #control_plane_subnet_ids = data.aws_subnets.control_plane_subnets_ids.ids  # Control plane subnets (optional isolation)

  # Encryption and Logging
  create_cloudwatch_log_group = false  # Disable CloudWatch log group creation (customize if needed)
  create_kms_key              = false  # Disable KMS key creation (use existing or set to true for production)
  cluster_encryption_config   = {}     # No encryption config (enable for production)

  # Cluster Version and IAM Roles for Service Accounts (IRSA)
  cluster_version = var.cluster_attributes.k8s_version  # Kubernetes version (e.g., "1.30")
  enable_irsa     = var.cluster_attributes.enable_irsa  # Required for service account IAM roles

  # API Server Access Configuration
  cluster_endpoint_public_access  = var.security.cluster_endpoint_public_access   # Allow public API access (caution in production)
  cluster_endpoint_private_access = var.security.cluster_endpoint_private_access  # Restrict to private access
  authentication_mode             = var.security.authentication_mode             # Auth mode (e.g., "API_AND_CONFIG_MAP")

  # Advanced Networking
  enable_security_groups_for_pods = var.security.enable_security_groups_for_pods  # Use security groups for pods

  # Security Group Integration
  create_cluster_security_group = true
  create_node_security_group    = true
  #cluster_security_group_id     = var.control_plane_security_group_id  # Control plane SG
  #node_security_group_id        = var.node_security_group_id           # Worker node SG

  # IAM Configuration
  enable_cluster_creator_admin_permissions = true  # Grant admin to cluster creator
  create_iam_role                          = true  # Create dedicated IAM role for cluster
  create_node_iam_role                     = true  # Create dedicated IAM role for nodes
  openid_connect_audiences                 = ["sts.amazonaws.com"]  # OIDC audience for IRSA

  # IAM Role Naming (AWS has 64-character limit for IAM role names)
  iam_role_use_name_prefix      = false
  node_iam_role_use_name_prefix = false
  iam_role_name                 = substr("iam-cluster-${var.long_cluster_name}", 0, 38)
  node_iam_role_name            = substr("iam-role-node-${var.long_cluster_name}", 0, 38)

  # Additional IAM Policies
  iam_role_additional_policies      = var.iam_role_additional_policies       # Cluster role policies
  node_iam_role_additional_policies = var.node_iam_role_additional_policies  # Node role policies

  # Managed Node Group Configuration
  eks_managed_node_groups = {
    "default" = {
      #subnet_ids                 = data.aws_subnets.cluster_subnets_ids.ids  # Worker subnets
      ami_type                   = "BOTTLEROCKET_x86_64"  # Container-optimized OS
      capacity_type              = "ON_DEMAND"           # Spot instances not used
      disk_size                  = 50                    # Root volume size (GB)
      use_custom_launch_template = false                 # Use EKS-optimized template
      volume_type                = "gp3"                 # High-performance SSD
      min_size                   = 4                     # Minimum nodes
      max_size                   = 5                     # Maximum nodes
      desired_size               = 4                     # Initial nodes
      instance_types             = ["m5.xlarge"]    # List of allowed instance types
      
      # Node labels for Kubernetes scheduling
      tags = {
        Name                 = "node-group-default-${var.short_cluster_name}"
        Environment          = var.environment
        AwsRegion            = var.aws_region
        DisasterRecoveryRole = var.disaster_recovery_role
        ClusterName          = var.long_cluster_name
        VPCName              = var.long_vpc_name
        Owner                = var.owner
      }
    }
  }

  # Cluster-wide tags for resource tracking
  cluster_tags = {
    Name                 = var.long_cluster_name
    Environment          = var.environment
    DisasterRecoveryRole = var.disaster_recovery_role
    VPCName              = var.long_vpc_name
    VpcId                = data.aws_vpc.selected.id  # Explicit VPC ID tag
    AwsRegion            = var.aws_region
    Owner                = var.owner
    K8sVersion           = var.cluster_attributes.k8s_version
  }
}

# ------------------------------------------------------------------------------
# Best Practices and Notes:
# 1. Security: Enable KMS encryption and private API access for production clusters.
# 2. Scaling: Configure proper min/max sizes for node groups based on workload needs.
# 3. Updates: Use Terraform version constraints and test upgrades in staging first.
# 4. Monitoring: Enable CloudWatch logging and container insights for observability.
# 5. Networking: Ensure subnets have proper NAT/route tables for node connectivity.
# 6. IAM: Regularly audit IAM roles and policies for least privilege access.
# 7. Maintenance: Keep EKS add-ons and node AMIs updated to latest stable versions.
# ------------------------------------------------------------------------------
