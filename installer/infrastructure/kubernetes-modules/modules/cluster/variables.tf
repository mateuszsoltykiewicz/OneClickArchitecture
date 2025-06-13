# ------------------------------------------------------------------------------
# Cluster Identification Variables
# ------------------------------------------------------------------------------
variable "short_cluster_name" {
  type        = string
  description = "Short, human-friendly name for the cluster (used in tags, DNS, etc.)"
  nullable    = false
}

variable "long_cluster_name" {
  type        = string
  description = "Full, unique name for the cluster (used in AWS resource identifiers)"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Networking & Environment Variables
# ------------------------------------------------------------------------------
variable "long_vpc_name" {
  type        = string
  description = "Full name of the VPC where the cluster will be deployed"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
  nullable    = false
}

variable "disaster_recovery_role" {
  type        = string
  description = "Disaster recovery role classification (e.g., primary, secondary)"
  nullable    = false
}

variable "aws_region" {
  type        = string
  description = "AWS region code (e.g., us-east-1)"
  nullable    = false
}

variable "owner" {
  type        = string
  description = "Owner/team responsible for the cluster"
  nullable    = false
}

# ------------------------------------------------------------------------------
# Subnet Configuration
# ------------------------------------------------------------------------------
variable "subnets_filter" {
  type = list(object({
    tier    = string
    purpose = string
  }))
  description = "Filter for worker node subnets using 'tier' and 'purpose' tags"
  default     = [{ tier = "*", purpose = "Kubernetes" }]
  nullable    = false
}

variable "control_plane_subnets_filter" {
  type = list(object({
    tier    = string
    purpose = string
  }))
  description = "Filter for control plane subnets using 'tier' and 'purpose' tags"
  default     = [{ tier = "*", purpose = "Kubernetes" }]
  nullable    = false
}

# ------------------------------------------------------------------------------
# Cluster Configuration
# ------------------------------------------------------------------------------
variable "cluster_attributes" {
  type = object({
    k8s_version                              = string
    enable_cluster_creator_admin_permissions = bool
    enable_irsa                              = bool
  })
  description = <<-EOT
    Cluster core configuration:
    - k8s_version: Kubernetes version (e.g., "1.30")
    - enable_cluster_creator_admin_permissions: Grant admin to cluster creator
    - enable_irsa: Enable IAM Roles for Service Accounts (IRSA)
  EOT
  nullable    = false
}

# ------------------------------------------------------------------------------
# Security Configuration
# ------------------------------------------------------------------------------
variable "security" {
  type = object({
    enable_security_groups_for_pods      = bool
    cluster_endpoint_public_access       = bool
    cluster_endpoint_private_access      = bool
    cluster_endpoint_public_access_cidrs = list(string)
    authentication_mode                  = string
  })
  description = <<-EOT
    Security settings for the cluster:
    - enable_security_groups_for_pods: Use security groups for pod networking
    - cluster_endpoint_public_access: Allow public API server access
    - cluster_endpoint_private_access: Restrict API server to private access
    - cluster_endpoint_public_access_cidrs: Whitelisted CIDRs for public access
    - authentication_mode: Auth method (e.g., "API_AND_CONFIG_MAP")
  EOT
  nullable    = false
}

# ------------------------------------------------------------------------------
# Security Group Integration
# ------------------------------------------------------------------------------
variable "node_security_group_id" {
  type        = string
  description = "Existing security group ID for worker nodes"
  default     = null
}

variable "cluster_security_group_id" {
  type        = list(string)
  description = "Existing security group ID for cluster communication"
  default     = []
}

variable "control_plane_security_group_id" {
  type        = string
  description = "Existing security group ID for control plane"
  default     = null
}

variable "monitoring_security_group_id" {
  type        = string
  description = "Existing security group ID for monitoring tools"
  default     = null
}

# ------------------------------------------------------------------------------
# IAM Configuration
# ------------------------------------------------------------------------------
variable "node_iam_role_additional_policies" {
  type        = map(string)
  description = "Additional IAM policies for worker node role"
  default = {
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  nullable = false
}

variable "iam_role_additional_policies" {
  type        = map(string)
  description = "Additional IAM policies for cluster role"
  default = {
    AmazonEKSClusterPolicy = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }
  nullable = false
}

# ------------------------------------------------------------------------------
# Compute Configuration
# ------------------------------------------------------------------------------
variable "instance_types" {
  type        = list(string)
  description = "Allowed instance types for EKS managed node groups (e.g., [\"m6g.4xlarge\"])."
  default     = ["m6g.4xlarge"]
  nullable    = false
}
