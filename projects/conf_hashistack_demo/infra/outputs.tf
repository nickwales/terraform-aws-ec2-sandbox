output "dc1_consul_token" {
  value = module.consul_server_dc1.consul_token
}

output "dc1_lb_hostname" {
  value = aws_lb.lb_dc1.dns_name
}
output "dc1_consul_lb" {
  value = "https://${aws_lb.lb_dc1.dns_name}:8501"
}

output "dc1_nomad_lb" {
  value = "http://${aws_lb.lb_dc1.dns_name}:4646"
}

output "dc1_application_lb" {
  value = "http://${aws_lb.lb_dc1.dns_name}/ui"
}

output "dc1_nomad_token" {
  value = data.local_file.nomad_bootstrap_token_dc1.content
}

# output "dc2_consul_token" {
#   value = module.consul_server_dc2.consul_token
# }

# output "dc2_lb_hostname" {
#   value = aws_lb.lb_dc2.dns_name
# }
# output "dc2_consul_lb" {
#   value = "https://${aws_lb.lb_dc2.dns_name}:8501"
# }

# output "dc2_nomad_lb" {
#   value = "http://${aws_lb.lb_dc2.dns_name}:4646"
# }

# output "dc2_application_lb" {
#   value = "http://${aws_lb.lb_dc2.dns_name}/ui"
# }


