# ------------------------------------------------------------------------------
# Global/Environment Variables
# ------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "AWS Region (e.g., eu-central-1)"
}

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role (e.g., primary, secondary, standby)"
}

variable "owner" {
  type        = string
  description = "Name of the setup owner or responsible team"
}

# ------------------------------------------------------------------------------
# Kubernetes Cluster Configuration List
# Each element defines a cluster and its core settings.
# ------------------------------------------------------------------------------

variable "kubernetes_config" {
  description = <<-EOT
    List of Kubernetes cluster configurations.
    Each object defines a cluster's identity, networking, add-ons, security, and node group settings.
  EOT

  type = list(object({
    # Cluster Identity
    local_long_cluster_name  = string   # Unique, descriptive cluster name (used for resource naming)
    local_short_cluster_name = string   # Short cluster name (used for DNS, tags, etc.)
    local_environment        = string   # Environment (e.g., dev, prod)
    local_long_vpc_name      = string   # Name of the VPC to deploy the cluster in

    # Add-ons Configuration (optional, with defaults)
    addons = optional(list(object({
      addon_name = optional(string)    # Name of the EKS add-on (e.g., aws-efs-csi-driver)
      version    = optional(string)    # Version of the add-on
      role_arn   = optional(string)    # IAM role ARN for the add-on (IRSA)
    })), [
      { addon_name = "aws-efs-csi-driver", version = "v2.1.7-eksbuild.1", role_arn = null },
      { addon_name = "s3_csi_driver", version = "v1.13.0-eksbuild.1", role_arn = null },
      { addon_name = "eks-pod-identity-agent", version = "v1.3.5-eksbuild.2", role_arn = null },
      { addon_name = "aws-ebs-csi-driver", version = "v1.44.0-eksbuild.1", role_arn = null },
      { addon_name = "snapshot-controller", version = "v8.2.0-eksbuild.1", role_arn = null }
    ])

    # Enable Route53 integration for this cluster
    route53 = optional(bool, false)

    # Subnet Selection for Nodes (optional, with default)
    subnets_filter = optional(list(object({
      tier    = string                # Subnet tier (e.g., private, public, *)
      purpose = string                # Subnet purpose (e.g., Kubernetes, Database)
    })), [
      {
        tier    = "*"
        purpose = "Kubernetes"
      }
    ])

    # Subnet Selection for Control Plane (optional, with default)
    control_plane_subnets_filter = optional(list(object({
      tier    = string
      purpose = string
    })), [{
      tier    = "*"
      purpose = "Kubernetes"
    }])

    # Cluster Attributes (optional, with defaults)
    cluster_attributes = optional(object({
      k8s_version                              = optional(string, "1.32")      # Kubernetes version
      enable_cluster_creator_admin_permissions = optional(bool, true)           # Grant admin to cluster creator
      enable_irsa                              = optional(bool, true)           # Enable IAM Roles for Service Accounts
    }), {
      k8s_version                              = "1.32"
      enable_cluster_creator_admin_permissions = true
      enable_irsa                              = true
    })

    # Security Settings (optional, with defaults)
    security = optional(object({
      enable_security_groups_for_pods      = optional(bool, false)              # Use SGs for pods (advanced networking)
      cluster_endpoint_public_access       = optional(bool, true)               # Allow public API access
      cluster_endpoint_private_access      = optional(bool, true)               # Allow private API access
      cluster_endpoint_public_access_cidrs = optional(list(string), ["0.0.0.0/0"]) # Whitelist CIDRs for public API
      authentication_mode                  = optional(string, "API_AND_CONFIG_MAP") # Auth mode for API
    }), {
      enable_security_groups_for_pods      = false
      cluster_endpoint_public_access       = true
      cluster_endpoint_private_access      = true
      cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
      authentication_mode                  = "API_AND_CONFIG_MAP"
    })

    # Node Group Instance Types (optional, with default)
    instance_types = optional(list(string), ["m6g.4xlarge"])                    # Allowed EC2 instance types for nodes

    # Node Groups Configuration (optional)
    node_groups = optional(map(object({
      subnet_tags = optional(object({
        tier    = string
        purpose = string
      }), {
        tier    = "*"
        purpose = "Kubernetes"
      })
      ami_type                   = optional(string, "BOTTLEROCKET_ARM_64")      # AMI type for nodes
      capacity_type              = optional(string, "ON_DEMAND")                # On-demand or spot
      disk_size                  = optional(number, 20)                         # Disk size in GB
      use_custom_launch_template = optional(bool, false)                        # Use custom launch template
      instance_types             = optional(list(string), ["m6g.4xlarge"])      # Instance types for this node group
      volume_type                = optional(string, "gp3")                      # EBS volume type
      min_size                   = optional(number, 1)                          # Minimum nodes
      max_size                   = optional(number, 3)                          # Maximum nodes
      desired_size               = optional(number, 1)                          # Desired nodes
      labels                     = optional(map(string), null)                  # Node labels for scheduling
    }))
    )
  }))
}

# ------------------------------------------------------------------------------
# Notes:
# - This structure enables flexible, multi-cluster, multi-environment deployments.
# - All major cluster and node group settings are customizable per cluster.
# - Defaults are provided for most optional fields for ease of use.
# - Use this variable as the main input for a for_each-driven EKS module pattern.
# ------------------------------------------------------------------------------
