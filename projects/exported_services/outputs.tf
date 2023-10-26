output "consul_token" {
  value = var.consul_token
}


output "dc1_app_lb" {
  value = "http://${module.nlb_dc1.lb_address}:8080"
}

output "dc1_consul_lb" {
  value = "http://${module.nlb_dc1.lb_address}:8500"
}

output "dc2_consul_lb" {
  value = "http://${module.nlb_dc2.lb_address}:8500"
}