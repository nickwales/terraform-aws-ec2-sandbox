#!/bin/sh

## Export some variables
export VAULT_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.vault_lb.value')"
export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.consul_lb.value')"
export CONSUL_HTTP_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.consul_token.value')"
export HOSTNAME="$(cat infra/terraform.tfstate | jq -r '.outputs.lb_hostname.value')"
export VAULT_TOKEN=$(cat ./vault-creds.json | jq -r .root_token)

# Test that services are up
echo "##### Getting Consul catalog services #####"
consul catalog services

echo "##### Getting Vault status #####"
vault status

## Initialize and Unseal Vault if it hasn't already been.
vault_response=$(curl --write-out '%{http_code}' --silent --output /dev/null "${VAULT_ADDR}/v1/sys/leader")
if (( $vault_response == 200 )) ; then
    echo "Vault is already setup, moving on..."
else
  echo "Initializing and unsealing Vault"
  vault_output=$(vault operator init -key-shares=1 -key-threshold=1 -format json)
  echo $vault_output > ./vault-creds.json 
  export VAULT_TOKEN=$(cat ./vault-creds.json | jq -r .root_token)
  VAULT_UNSEAL_KEY=$(cat ./vault-creds.json | jq -r '.unseal_keys_b64[0]') && sleep 3
  vault operator unseal $VAULT_UNSEAL_KEY
fi

## Configure Consul Secrets Engine in Vault
# vault secrets enable consul
#consul_management_token=$(consul acl token create -policy-name="global-management" -format=json | jq -r .SecretID)
# vault write consul/config/access \
#     address="127.0.0.1:8500" \
#     token=${consul_management_token}

## Create Consul policy and role
# consul acl policy create \
#   -name "ESM_Policy" \
#   -description "Enables ESM to function" \
#   -rules @config/consul_acl_policies/esm_policy.hcl

# consul acl role create \
#   -name "ESM_Role" \
#   -description "Enables ESM to function" \
#   -policy-name "ESM_Policy"

## Create Vault role


terraform -chdir=config init
terraform -chdir=config apply  -auto-approve
#sleep 5

