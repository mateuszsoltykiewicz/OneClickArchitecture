variable "cluster_name" { 
  type = string
}

variable "aws_region" { 
  type = string 
}

variable "environment" { 
  type = string
}

variable "tags" { 
  type = map(string) 
  default = {}
}

variable "disaster_recovery_role" { 
  type = string 
}

variable "role_arn" { 
  type = string 
  default = "arn:aws:iam::775292115464:role/terraform_oidc"
}

variable "owner" { 
  type = string
}