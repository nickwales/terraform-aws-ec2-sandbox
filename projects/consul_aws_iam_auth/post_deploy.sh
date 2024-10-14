#!/bin/sh

# DC1
## Export some variables

export CONSUL_HTTP_SSL_VERIFY=false
export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')"
export CONSUL_HTTP_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_token.value')"
export TF_DATA_DIR=".terraform_dc1"


echo "What is the consul lb"
echo $CONSUL_HTTP_ADDR
# Test that services are up
echo "##### Getting Consul catalog services #####"
consul catalog services


terraform -chdir=config init -upgrade
terraform -chdir=config apply -auto-approve
