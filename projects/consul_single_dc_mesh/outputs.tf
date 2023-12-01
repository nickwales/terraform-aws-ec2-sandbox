output "consul_token" {
  value = var.consul_token
}

output "app_addr" {
  value = "http://${aws_lb.lb.dns_name}"
}

# output "dc1_app_lb" {
#   value = "http://${module.nlb_dc1.lb_address}"
# }


# output "dc1_consul_lb" {
#   value = "http://${module.nlb_dc1.lb_address}:8500"
# }

# output "dc2_consul_lb" {
#   value = "http://${module.nlb_dc2.lb_address}:8500"
# }