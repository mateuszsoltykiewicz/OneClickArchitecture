variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for auto-unseal"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "storage_class" {
  description = "Storage class for PVC"
  type        = string
  default     = "gp2"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}
