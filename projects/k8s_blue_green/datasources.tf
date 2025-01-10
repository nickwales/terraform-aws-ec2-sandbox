data "aws_availability_zones" "available" {}

data "local_file" "consul_agent_ca" {
  filename = "${path.module}/certs/consul-agent-ca.pem"
}