module "consul_setup" {
  source = "hashicorp-modules/nomad-setup/consul"

  nomad_jwks_url = "http://nomad.service.consul:4646/.well-known/jwks.json"

  nomad_namespaces = ["default", "ingress"]
}