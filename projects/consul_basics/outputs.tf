output "lb_addr" {
  value = aws_lb.lb.dns_name
}