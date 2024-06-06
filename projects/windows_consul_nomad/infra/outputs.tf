output "consul_token" {
  value = module.consul_server_dc1.consul_token
}

output "nomad_token" {
  value = module.nomad_server_dc1.nomad_bootstrap_token
}

output "consul_lb" {
  value = "http://${aws_lb.lb.dns_name}:8500"
}

output "nomad_lb" {
  value = "http://${aws_lb.lb.dns_name}:4646"
}

output "vault_lb" {
  value = "http://${aws_lb.lb.dns_name}:8200"
}