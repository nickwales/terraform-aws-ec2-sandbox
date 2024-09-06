

module "vault_setup" {
  source = "hashicorp-modules/nomad-setup/vault"

  nomad_jwks_url = "http://nomad.service.consul:4646/.well-known/jwks.json"
}

resource "vault_mount" "secret" {
  path      = "secret"
  type      = "kv"
  options = {
    version = "2"
  }
  description = "KV Secrets Go Here"
}

resource "vault_kv_secret_backend_v2" "secret" {
  mount                = vault_mount.secret.path
  max_versions         = 5
  cas_required         = false
}

resource "vault_kv_secret_v2" "frontend" {
  mount                      = vault_mount.secret.path
  name                       = "applications/frontend/config"
  delete_all_versions        = false
  data_json                  = jsonencode(
  {
    message = "Highly secure credential from Vault to connect to middleware"
  }
  )
}

resource "vault_kv_secret_v2" "middleware" {
  mount                      = vault_mount.secret.path
  name                       = "applications/middleware/config"
  delete_all_versions        = false
  data_json                  = jsonencode(
  {
    message = "Secure Database password for mssql"
  }
  )
}

resource "vault_kv_secret_v2" "mssql" {
  mount                      = vault_mount.secret.path
  name                       = "database/mssql/config"
  delete_all_versions        = false
  data_json                  = jsonencode(
  {
    message    = "8YBABu9TVXW2bRFe"
  }
  )
}

resource "vault_kv_secret_v2" "aspnet-sample-app" {
  mount                      = vault_mount.secret.path
  name                       = "default/aspnet-sample-app/config"
  delete_all_versions        = false
  data_json                  = jsonencode(
  {
    username = "superuser",
    password = "changeme_regularly"
    db_cred  = "password123"
  }
  )
}
