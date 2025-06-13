variable "namespace" {
  type = string
}

variable "apps" {
  type = list(string)

  default = [
  ] 
}