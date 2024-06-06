#!/bin/sh

## Export some variables

export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.consul_lb.value')"
export CONSUL_HTTP_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.consul_token.value')"
export NOMAD_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.nomad_lb.value')"
export NOMAD_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.nomad_token.value')"

echo $NOMAD_ADDR
terraform -chdir=config init
terraform -chdir=config apply -auto-approve
