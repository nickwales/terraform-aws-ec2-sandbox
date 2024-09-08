data "local_file" "consul_server_key" {
  filename = "${path.module}./infra/certs/dc1-server-consul-0-key.pem"
}

data "local_file" "consul_server_cert" {
  filename = "${path.module}./infra/certs/dc1-server-consul-0.pem"
}

data "local_file" "consul_agent_ca" {
  filename = "${path.module}./infra/certs/consul-agent-ca.pem"
}