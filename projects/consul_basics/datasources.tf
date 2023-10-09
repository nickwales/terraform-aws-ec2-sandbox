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

data "local_file" "consul_server_key" {
  filename = "${path.module}/certs/dc1-server-consul-0-key.pem"
}

data "local_file" "consul_server_cert" {
  filename = "${path.module}/certs/dc1-server-consul-0.pem"
}

data "local_file" "consul_agent_ca" {
  filename = "${path.module}/certs/consul-agent-ca.pem"
}