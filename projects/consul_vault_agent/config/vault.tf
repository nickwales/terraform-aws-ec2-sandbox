resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Manages the Consul backend"
  address     = "127.0.0.1:8500"
  token       = var.consul_management_token

  default_lease_ttl_seconds = 120
  max_lease_ttl_seconds     = 120
}

resource "vault_consul_secret_backend_role" "esm" {
  name    = "esm"
  backend = vault_consul_secret_backend.consul.path

  consul_roles = [
    consul_acl_role.esm_role.name,
  ]
}

## AWS Auth engine
resource "vault_auth_backend" "aws" {
  type = "aws"
  description = "Auth to Vault via EC2 roles"
}

resource "vault_aws_auth_backend_role" "example" {
  backend                         = vault_auth_backend.aws.path
  role                            = "esm"
  auth_type                       = "iam"
  bound_iam_role_arns             = [
    "arn:aws:iam::068591307351:role/acls-dc120240827012924068500000003",
    "arn:aws:iam::068591307351:role/esm-acls-dc120240827231416522100000001",
    "arn:aws:iam::068591307351:role/esm-acls-dc120240828010359303100000001"
  ]
  bound_iam_instance_profile_arns = [
    "arn:aws:iam::068591307351:instance-profile/acls-dc120240827012924567000000007",
    "arn:aws:iam::068591307351:instance-profile/esm-acls-dc120240828010359883000000007",
    "arn:aws:iam::068591307351:instance-profile/esm-acls-dc120240827231417025100000008"
  ]
  inferred_entity_type            = "ec2_instance"
  inferred_aws_region             = "us-east-1"
  token_ttl                       = 72000
  token_max_ttl                   = 72000
  token_policies                  = ["default", "esm"]
}

resource "vault_policy" "esm" {
  name = "esm"

  policy = <<EOT
path "consul/creds/esm" {
  capabilities = ["read"]
}
EOT
}