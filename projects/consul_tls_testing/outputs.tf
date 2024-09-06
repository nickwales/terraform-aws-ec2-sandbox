output "consul_token" {
  value = var.consul_token
}

output "consul_lb" {
  value = "http://${module.nlb.lb_address}:8500"
}

