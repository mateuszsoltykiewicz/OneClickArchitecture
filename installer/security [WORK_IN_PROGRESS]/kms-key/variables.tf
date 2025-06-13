variable "name" {
  description = "KMS key alias name"
  type        = string
  default     = "vault-auto-unseal"
}

variable "description" {
  description = "KMS key description"
  type        = string
  default     = "Vault auto-unseal key"
}

variable "deletion_window" {
  description = "Days to wait before deleting key"
  type        = number
  default     = 30
}
