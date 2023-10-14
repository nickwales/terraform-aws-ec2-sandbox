variable "name" {
  default = "lb"
}
variable "owner" {}
variable "region" {}

variable "subnets" {}

variable "consul_datacenter" {
  default = "dc1"
}

variable "vpc_id" {}

variable "internal" {
  default = false
}