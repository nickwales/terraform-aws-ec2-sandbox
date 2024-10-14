locals {
  datacenter = var.datacenter
}

terraform {  
  backend "local" { path = "terraform_dc1.tfstate" }
}

provider "consul" {
  datacenter = var.datacenter
}

provider "nomad" {}
