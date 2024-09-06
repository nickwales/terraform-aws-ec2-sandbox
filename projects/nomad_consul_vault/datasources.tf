# Consul Certs
data "local_file" "consul_server_key_dc1" {
  filename = "${path.module}/certs_dc1/dc1-server-consul-0-key.pem"
}
data "local_file" "consul_server_cert_dc1" {
  filename = "${path.module}/certs_dc1/dc1-server-consul-0.pem"
}
data "local_file" "consul_agent_ca_dc1" {
  filename = "${path.module}/certs_dc1/consul-agent-ca.pem"
}

# Nomad Certs
data "local_file" "nomad_server_key" {
  filename = "${path.module}/certs_dc1/global-server-nomad-key.pem"
}
data "local_file" "nomad_server_cert" {
  filename = "${path.module}/certs_dc1/global-server-nomad.pem"
}
data "local_file" "nomad_agent_ca" {
  filename = "${path.module}/certs_dc1/nomad-agent-ca.pem"
}

# data "local_file" "consul_agent_ca_dc2" {
#   filename = "${path.module}/certs_dc2/consul-agent-ca.pem"
# }
# data "local_file" "consul_server_key-dc2" {
#   filename = "${path.module}/certs_dc2/dc2-server-consul-0-key.pem"
# }

# data "local_file" "consul_server_cert-dc2" {
#   filename = "${path.module}/certs_dc2/dc2-server-consul-0.pem"
# }

