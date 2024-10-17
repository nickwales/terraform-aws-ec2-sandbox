output "dc1_consul_token" {
  value = module.consul_server_dc1.consul_token
}

output "dc1_lb_hostname" {
  value = aws_lb.lb_dc1.dns_name
}
output "dc1_consul_lb" {
  value = "https://${aws_lb.lb_dc1.dns_name}:8501"
}
