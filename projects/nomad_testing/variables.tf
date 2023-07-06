variable "region" {
  default = "us-east-1"
}

variable "consul_token" {
  default = "root"
}

variable "consul_datacenter" {
  default = "dc1"
}

variable "envoy_version" {
  default = "1.24.1"
}

variable "server_count" {}

variable "client_count" {}