variable "cluster_name" { 
  type = string
  default = "develop-develop-develop-digitalfirstai-active-eu-central-1"
}

variable "aws_region" { 
  type = string 
  default = "eu-central-1"
}

variable "vpc_id" { 
  type = string 
  default = "vpc-0ce9856c033b7a7d9"
}

variable "oidc_provider_arn" {
  type = string 
  default = "arn:aws:iam::775292115464:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/01E7B2C2CBA03411B73A885E0D35A815"
}

variable "public_subnet_ids" { 
  type = list(string) 
  default = [ "subnet-0ecb090b97e4542bd", "subnet-08d5b594cd6a8f893" ]
}

# variable "private_subnet_ids" { type = list(string) }
variable "node_security_group_ids" { 
  type = list(string)
  default = [ "sg-0601f8fd698bd72a7" ]  
}

variable "cluster_endpoint" { 
  type = string 
  default = "https://01E7B2C2CBA03411B73A885E0D35A815.gr7.eu-central-1.eks.amazonaws.com"  
}

variable "environment" { 
  type = string
  default = "develop"
}

variable "tags" { 
  type = map(string) 
  default = {}  
}

variable "loki_bucket_name" { 
  type = string 
  default = "active-develop-loki-eu-central-1-digitalfirstai"
}

variable "qdrant_bucket_name" { 
  type = string 
  default = "active-develop-qdrant-eu-central-1-digitalfirstai"  
}

variable "cert_manager_chart_version" {
  type    = string
  default = "v1.12.16"
}

variable "karpenter_chart_version" {
  type    = string
  default = "0.35.8"
}

variable "prometheus_operator_chart_version" {
  type    = string
  default = "0.24.2"
}

variable "grafana_chart_version" {
  type    = string
  default = "6.59.0"
}

variable "loki_chart_version" {
  type    = string
  default = "6.30.0"
}

variable "qdrant_operator_chart_version" {
  type    = string
  default = "2.4.2"
}

variable "disaster_recovery_role" { 
  type = string 
  default = "active"
}

variable "role_arn" { 
  type = string 
  default = "arn:aws:iam::775292115464:role/terraform_oidc"
}

variable "owner" { 
  type = string
  default = "digitalfirstai"
}

#----------------------------------------
# ACM CONFIGURATION
#----------------------------------------
variable "acm_configuration" {
  type = object({
    domain_name = string
    route53_zone_id = string
  })
}