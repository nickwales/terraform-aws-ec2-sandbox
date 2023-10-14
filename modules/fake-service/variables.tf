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
variable "consul_license" {
  default = ""
}
variable "consul_version" {
  default = "1.16.2"
}
variable "consul_binary" {
  description = "Allows upgrading to Consul Enterprise"
  default     = "consul"
}

variable "consul_namespace" {
  default = "default"
}

variable "consul_datacenter" {
  default = "dc1"
}
variable "consul_partition" {
  description = "The Consul admin partition this agent should be part of"
  default = "default"
}
variable "instance_count" {
  description = "The number of frontend app instances"
  default = 1
}
variable "consul_encryption_key" {
  default = "P4+PEZg4jDcWkSgHZ/i3xMuHaMmU8rx2owA4ffl2K8w="
}
variable "consul_agent_ca" {}

variable "upstream_uris" {
  description = "Comma separated list of upstream URIs"
  default = ""
}

variable "app_port" {
  description = "Port that fake-service should run on"
  default = "8080"
}

variable "target_groups" {
  description = "List of target groups"
  type    = list(string)
  default = [""]
}