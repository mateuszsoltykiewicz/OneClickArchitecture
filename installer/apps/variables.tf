variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "owner" {
  type = string
}

variable "disaster_recovery_role" {
  type = string
}

variable "role_arn" {
  type = string
  sensitive = true
}