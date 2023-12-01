output "consul_token" {
  value = var.consul_token
}

output "service_discovery_entrypoint" {
  value = "http://${aws_lb.lb.dns_name}:8080"
}

output "service_mesh_entrypoint" {
  value = "http://${aws_lb.lb.dns_name}/ui/"
}

output "consul_entrypoint" {
  value = "http://${aws_lb.lb.dns_name}:8500"
}
