## DC1

data "local_file" "consul_server_key_dc1" {
  filename = "${path.module}/creds_dc1/dc1-server-consul-0-key.pem"
}

data "local_file" "consul_server_cert_dc1" {
  filename = "${path.module}/creds_dc1/dc1-server-consul-0.pem"
}

data "local_file" "consul_agent_ca_dc1" {
  filename = "${path.module}/creds_dc1/consul-agent-ca.pem"
}

data "local_file" "nomad_bootstrap_token_dc1" {
  filename = "${path.module}/creds_dc1/nomad_bootstrap_token"
}


## DC2
data "local_file" "consul_server_key_dc2" {
  filename = "${path.module}/creds_dc2/dc2-server-consul-0-key.pem"
}

data "local_file" "consul_server_cert_dc2" {
  filename = "${path.module}/creds_dc2/dc2-server-consul-0.pem"
}

data "local_file" "consul_agent_ca_dc2" {
  filename = "${path.module}/creds_dc2/consul-agent-ca.pem"
}

data "local_file" "nomad_bootstrap_token_dc2" {
  filename = "${path.module}/creds_dc2/nomad_bootstrap_token"
}
