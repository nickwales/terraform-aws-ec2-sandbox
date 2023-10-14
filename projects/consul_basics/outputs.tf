output "app_lb" {
  value = "http://${module.consul_frontend_dc1.lb_address}"
}

output "dc1_consul_ui_addr" {
  value = "http://${module.consul_server_dc1.lb_address}:8500"
}

output "dc1_gateway_addr" {
  value = "http://${module.consul_gateway_dc1.lb_address}:8443"
}

output "dc2_consul_ui_addr" {
  value = "http://${module.consul_server_dc2.lb_address}:8500"
}
output "dc2_gateway_addr" {
  value = "http://${module.consul_gateway_dc2.lb_address}:8443"
}

output "consul_token" {
  value = var.consul_token
}