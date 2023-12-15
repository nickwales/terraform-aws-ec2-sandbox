locals {
  message = var.message != "" ? var.message : "${var.name} in ${var.consul_datacenter}"
}