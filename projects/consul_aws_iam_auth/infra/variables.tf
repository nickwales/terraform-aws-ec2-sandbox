variable "name" {}
variable "owner" {}
variable "purpose" {}
variable "region" {
  default = "us-east-1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnets" {
  default = ["10.0.101.0/24"]
}
variable "private_subnets" {
  default = ["10.0.1.0/24"]
}

variable "consul_token" {
  default = "root"
}
variable "consul_version" {
  default = "1.18.2"
}
variable "consul_binary" {
  description = "This should be either `consul` or `consul-enterprise`"
  default = "consul"
}
variable "consul_license" {
  default = ""
}

variable "nomad_license" {
  default = ""
}

variable "datacenter" {
  default = "dc1"
}

variable "datacenter_dc2" {
  default = "dc2"
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

variable "consul_encryption_key_dc2" {
  default = "EFQYW26d5z78B30rAyCyTJnS0bkgsq5gaGQRlrlXXnA="
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
