variable "environment" {
  type = string
}

variable "disaster_recovery_role" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "owner" {
  type = string
}

variable "role_arn" {
  type = string
  sensitive = true
  default = "arn:aws:iam::775292115464:role/terraform_oidc"
}