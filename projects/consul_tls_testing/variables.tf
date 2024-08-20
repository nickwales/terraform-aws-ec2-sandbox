variable "name" {}
variable "owner" {}
variable "purpose" {}
variable "region" {}

variable "cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "consul_token" {
  default = "root"
}

variable "consul_version" {
  default = "1.16.2"
}
variable "consul_binary" {
  default = "consul"
}
variable "consul_license" {
  default = ""
}
variable "nomad_license" {
  default = ""
}

variable "nomad_bootstrap_token" {}

variable "datacenter" {
  default = "dc1"
}

variable "consul_server_count" {
  description = "The number of Consul servers, should be 1 or 3"
  default = 1
}

variable "consul_gateway_count" {
  description = "The number of Consul gateway instances"
  default = 1
}

variable "consul_encryption_key" {
  default = "P4+PEZg4jDcWkSgHZ/i3xMuHaMmU8rx2owA4ffl2K8w="
}

variable "backend_partition" {
  description = "Admin partition the middleware agents should join"
  default = "default"
}

variable "middleware_partition" {
  description = "Admin partition the middleware agents should join"
  default = "default"
}

variable "frontend_partition" {
  description = "Admin partition the frontend agents should join"
  default = "default"
}
