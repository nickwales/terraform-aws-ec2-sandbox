module "consul_setup" {
  source = "hashicorp-modules/nomad-setup/consul"

  nomad_jwks_url = "http://nomad.service.consul:4646/.well-known/jwks.json"

  nomad_namespaces = ["default", "ingress"]
}

module "consul_setup_database" {
  source = "github.com/nickwales/terraform-consul-nomad-setup"

  nomad_jwks_url = "http://nomad.service.consul:4646/.well-known/jwks.json"

  consul_admin_partition = "database"
}