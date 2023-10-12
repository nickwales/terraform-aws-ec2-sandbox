data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "local_file" "consul_server_key_dc1" {
  filename = "${path.module}/certs_dc1/dc1-server-consul-0-key.pem"
}

data "local_file" "consul_server_cert_dc1" {
  filename = "${path.module}/certs_dc1/dc1-server-consul-0.pem"
}

data "local_file" "consul_agent_ca_dc1" {
  filename = "${path.module}/certs_dc1/consul-agent-ca.pem"
}

data "local_file" "consul_agent_ca_dc2" {
  filename = "${path.module}/certs_dc2/consul-agent-ca.pem"
}
data "local_file" "consul_server_key-dc2" {
  filename = "${path.module}/certs_dc2/dc2-server-consul-0-key.pem"
}

data "local_file" "consul_server_cert-dc2" {
  filename = "${path.module}/certs_dc2/dc2-server-consul-0.pem"
}


# data "local_file" "consul_encryption_key" {
#   filename = "${path.module}/certs/encryption_key"
# }

# data "local_file" "consul_license" {
#   filename = "${path.module}/certs/consul_license"
# }