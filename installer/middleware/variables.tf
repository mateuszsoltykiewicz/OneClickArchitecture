variable "environment" {
  description = "Environment to deploy (e.g., prod, dev)"
  type        = string
}

variable "eks_cluster_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "role_arn" {
  type = string
  default = "arn:aws:iam::775292115464:role/terraform_oidc"
}

variable "aws_region" {
  type = string
}

variable "dr_role" {
  type = string
}

variable "owner" {
  type = string
}

variable "oidc_provider_arn" {
  type = string 
  default = "arn:aws:iam::775292115464:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/01E7B2C2CBA03411B73A885E0D35A815"
}