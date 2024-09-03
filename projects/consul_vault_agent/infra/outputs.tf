output "consul_token" {
  value = module.consul_server_dc1.consul_token
}

output "lb_hostname" {
  value = aws_lb.lb.dns_name
}
output "consul_lb" {
  value = "http://${aws_lb.lb.dns_name}:8500"
}

output "vault_lb" {
  value = "http://${aws_lb.lb.dns_name}:8200"
}