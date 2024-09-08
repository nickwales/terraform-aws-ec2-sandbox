#!/bin/sh

## Export some variables
export VAULT_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.vault_lb.value')"
export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.consul_lb.value')"
export CONSUL_HTTP_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.consul_token.value')"
export HOSTNAME="$(cat infra/terraform.tfstate | jq -r '.outputs.lb_hostname.value')"
export VAULT_TOKEN=$(cat ./vault-creds.json | jq -r .root_token)
export NOMAD_ADDR="http://$(cat infra/terraform.tfstate | jq -r '.outputs.lb_hostname.value'):4646"
export NOMAD_TOKEN="30d8650c-d7fa-45d7-ab6e-7a8bf7c74a6b"


echo "What is the consul lb"
echo $CONSUL_HTTP_ADDR
# Test that services are up
echo "##### Getting Consul catalog services #####"
consul catalog services

terraform -chdir=config init -upgrade
terraform -chdir=config apply -var="hostname=${HOSTNAME}"  -auto-approve
#sleep 5


