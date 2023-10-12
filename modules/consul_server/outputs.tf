output "lb_address" {
  value = aws_lb.consul_server_lb.dns_name
}