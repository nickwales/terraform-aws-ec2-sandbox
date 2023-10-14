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
variable "consul_token" {
  default = "root"
}
variable "consul_license" {}
variable "consul_version" {
  default = "1.16.2"
}
variable "consul_binary" {
  default = "consul"
}
variable "partition" {
  description = "The Consul admin partition this agent should be part of"
  default = "default"
}

variable "partitions" {
  description = "A bash array of partitions"
  default = "('global-api' 'datastores' 'sucky' 'sucky2')"
}
variable "datacenter" {
  default = "dc1"
}
variable "middleware_count" {
  description = "The number of middleware app instances"
  default = 1
}
variable "consul_encryption_key" {
  default = "P4+PEZg4jDcWkSgHZ/i3xMuHaMmU8rx2owA4ffl2K8w="
}
variable "consul_agent_ca" {}