# Consul Certs
data "local_file" "consul_server_key_dc1" {
  filename = "${path.module}/certs/server.dc1.consul.key"
}
data "local_file" "consul_server_cert_dc1" {
  filename = "${path.module}/certs/server.dc1.consul.crt"
}
data "local_file" "consul_agent_ca_dc1" {
  filename = "${path.module}/certs/consul-agent-ca.pem"
}

