output "app_lb" {
  value = aws_lb.lb.dns_name
}

output "dc1_lb_addr" {
  value = module.consul_server_dc1.lb_address
}

output "dc1_gateway_addr" {
  value = module.consul_gateway_dc1.lb_address
}

output "dc2_lb_addr" {
  value = module.consul_server_dc2.lb_address
}
output "dc2_gateway_addr" {
  value = module.consul_gateway_dc2.lb_address
}