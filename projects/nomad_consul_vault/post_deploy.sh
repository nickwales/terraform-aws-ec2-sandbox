#!/bin/sh



# Configure CLIs

export CONSUL_HTTP_TOKEN=$(cat terraform.tfstate | jq -r .outputs.consul_token.value)
export CONSUL_HTTP_ADDR=$(cat terraform.tfstate | jq -r .outputs.consul_lb.value)
export NOMAD_HTTP_ADDR=$(cat terraform.tfstate | jq -r .outputs.nomad_lb.value)


# Configure Vault JWT Auth
export VAULT_ADDR=$(cat terraform.tfstate | jq -r .outputs.vault_lb.value)

init_output=$(vault operator init -key-shares 1 -key-threshold 1 -format json)
echo $init_output > vault_init.json

export VAULT_TOKEN=$(echo $init_output | jq -r .root_token)
VAULT_UNSEAL_KEY=$(echo $init_output | jq -r '.unseal_keys_b64.[0]')
vault operator unseal $VAULT_UNSEAL_KEY

vault auth enable jwt

jwt_role=$(cat <<EOT
{
  "role_type": "jwt",
  "bound_audiences": "vault.io",
  "user_claim": "/nomad_job_id",
  "user_claim_json_pointer": true,
  "claim_mappings": {
    "nomad_namespace": "nomad_namespace",
    "nomad_job_id": "nomad_job_id"
  },
  "token_period": "5m",
  "token_ttl": "10m",
  "token_type": "service",
  "token_policies": ["nomad-workloads"]
}
EOT
)
curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request POST \
  --data "${jwt_role}" \
  "${VAULT_ADDR}/v1/auth/jwt/role/nomad-workloads"

jwt_config=$(cat <<EOT
{
  "jwks_url": "http://nomad.service.consul:4646/.well-known/jwks.json",
  "jwt_supported_algs": ["RS256"],
  "default_role": "nomad-workloads"
}
EOT
)
curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
  --request POST \
  --data "${jwt_config}" \
  "${VAULT_ADDR}/v1/auth/jwt/config"

vault secrets enable -path=secret -version=2 kv 
jwt_identifier=$(vault auth list -format json | jq -r '."jwt/".accessor')


policies=$(cat <<EOT
path "secret/data/{{identity.entity.aliases.${jwt_identifier}.metadata.nomad_namespace}}/{{identity.entity.aliases.${jwt_identifier}.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "secret/data/{{identity.entity.aliases.${jwt_identifier}.metadata.nomad_namespace}}/{{identity.entity.aliases.${jwt_identifier}.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}
path "secret/metadata/{{identity.entity.aliases.${jwt_identifier}.metadata.nomad_namespace}}/*" {
  capabilities = ["list"]
}
path "secret/metadata/*" {
  capabilities = ["list"]
}
EOT
)

policies=$(cat <<EOT
path "kv/*" {
  capabilities = ["read", "list"]
}
path "secret/data/test" {
  capabilities = ["read"]
}

path "secret/data/*" {
  capabilities = ["read"]
}
path "secret/data/*" {
  capabilities = ["list"]
}
path "secret/metadata/*" {
  capabilities = ["list"]
}
EOT
)

vault policy write nomad-workloads - <<< $policies

vault kv put secret/data/default/test secret_key=hello




# Configure Nomad

export NOMAD_ADDR=$(cat terraform.tfstate | jq -r .outputs.nomad_lb.value)
nomad job run jobs/vault_examples/test.nomad

# Configure Consul

consul config write ./consul_config/proxy_defaults.hcl 
consul config write ./consul_config/service_defaults_teeceepee.hcl
consul config write ./consul_config/service_defaults_ingress.hcl

nomad job run jobs/downstream.nomad
nomad job run jobs/midstream.nomad
nomad job run jobs/upstream.nomad
nomad job run jobs/teeceepee.nomad
nomad job run jobs/ingress-gateway.nomad
#nomad job run jobs/terminating-gateway.nomad