terraform {
  backend "s3" {
    bucket         = "active-develop-terraform-eu-central-1-digitalfirstai"
    key            = "active-develop-monitoring-state-eu-central-1-digitalfirstai.tfstate"
    region         = "eu-central-1"
  }
}
