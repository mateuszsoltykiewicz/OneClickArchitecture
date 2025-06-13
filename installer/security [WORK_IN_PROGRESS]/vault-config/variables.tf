variable "vault_address" {
  description = "Vault server address"
  type        = string
}

variable "vault_token" {
  description = "Vault root token"
  type        = string
  sensitive   = true
}

variable "databases" {
  description = "Map of database configurations"
  type = map(object({
    type      = string
    endpoint  = string
    username  = string
    password  = string
    rotation  = number
    statements = list(string)
  }))
}
