variable "name" {}
variable "owner" {}
variable "region" {}
variable "vpc_id" {}

variable "cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "nomad_token" {
  default = "root"
}

variable "nomad_version" {
  default = "1.8.0"
}
variable "nomad_binary" {
  description = "Allows upgrading to nomad Enterprise"
  default     = "nomad"
}

variable "consul_binary" {
  default = "consul"
}

variable "consul_version" {
  default = "1.18.2"
}
variable "consul_license" {
  default = ""
}
variable "consul_token" {
  default = "root"
}

variable "consul_partition" {
  default = "default"
}
variable "consul_agent_token" {
  default = "root"
}
variable "consul_encryption_key" {
  default = "P4+PEZg4jDcWkSgHZ/i3xMuHaMmU8rx2owA4ffl2K8w="
}
variable "datacenter" {
  default = "dc1"
}

## Vault
variable "vault_enabled" {
  default = true
}
variable "vault_addr" {
  default = "http://vault.service.consul:8200"
}

variable "vault_jwt_path" {
  default = "jwt"
}

variable "nomad_client_count" {
  description = "The number of nomad clients, should be 1 or 3"
  default = 1
}

variable "nomad_encryption_key" {
  default = "P4+PEZg4jDcWkSgHZ/i3xMuHaMmU8rx2owA4ffl2K8w="
}

#variable "nomad_bootstrap_token" {}

variable "consul_ca_file" {}
# variable "consul_cert_file" {}
# variable "consul_key_file" {}

variable "target_groups" {
  description = "List of target groups"
  type    = list(string)
  default = []
}

variable "key_name" {}