#Anonymous policy

resource "consul_acl_policy" "anonymous" {
  name        = "anonymous-policy"
  datacenters = ["dc1"]
  rules       = <<-RULE
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}

service_prefix "" {
  policy = "read"
}
    RULE
}

resource "consul_acl_token_policy_attachment" "anonymous" {
    token_id = "00000000-0000-0000-0000-000000000002"
    policy   = "${consul_acl_policy.anonymous.name}"
}


module "consul_setup" {
  source = "hashicorp-modules/nomad-setup/consul"

  nomad_jwks_url = "http://nomad.service.consul:4646/.well-known/jwks.json"
  nomad_namespaces = var.nomad_namespaces
}

