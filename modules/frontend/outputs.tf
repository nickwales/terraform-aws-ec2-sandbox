output "lb_address" {
  value = aws_lb.frontend.dns_name
}