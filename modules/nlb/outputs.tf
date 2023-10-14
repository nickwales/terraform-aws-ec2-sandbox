output "app_target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "consul_target_group_arn" {
  value = aws_lb_target_group.consul.arn
}

output "lb_address" {
  value = aws_lb.lb.dns_name
}