variable "name" {}
variable "owner" {}
variable "purpose" {}
variable "region" {}

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

variable "consul_license" {}
variable "consul_version" {
  default = "1.16.3"
}
variable "consul_binary" {
  default = "consul"
}

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
  default = "backend"
}

variable "middleware_partition" {
  description = "Admin partition the middleware agents should join"
  default = "middleware"
}

variable "frontend_partition" {
  description = "Admin partition the frontend agents should join"
  default = "frontend"
}

variable "hcp_client_id" {}
variable "hcp_client_secret" {}
variable "hcp_resource_id" {}