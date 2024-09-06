resource "consul_acl_token_policy_attachment" "attachment" {
    token_id = "00000000-0000-0000-0000-000000000002"
    policy   = "global-management"
}

module "nomad-setup" {
  source  = "hashicorp-modules/nomad-setup/consul"
  version = "2.0.0"

  nomad_jwks_url   = "http://nomad.service.consul:4646/.well-known/jwks.json"
  nomad_namespaces = ["default", "home"]
}

