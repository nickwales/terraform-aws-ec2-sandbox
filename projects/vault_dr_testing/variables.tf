variable "name" {
  default = "vault-dr"
}

variable "owner" {}
variable "purpose" {}
variable "region" {}

variable "consul_token" {
  default = "root"
}

variable "private_subnets" {
  default = ["10.0.1.0/24"]
}

variable "public_subnets" {
  default = ["10.0.101.0/24"]
}

variable "vault_ent_license" {}