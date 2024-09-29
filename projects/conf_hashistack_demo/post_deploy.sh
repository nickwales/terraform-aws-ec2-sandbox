#!/bin/sh

# DC1
## Export some variables

export CONSUL_HTTP_SSL_VERIFY=false
export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')"
export CONSUL_HTTP_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_token.value')"
export NOMAD_ADDR="http://$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_lb_hostname.value'):4646"
export NOMAD_TOKEN="$(cat infra/creds_dc1/nomad_bootstrap_token)"
export TF_DATA_DIR=".terraform_dc1"


echo "What is the consul lb"
echo $CONSUL_HTTP_ADDR
# Test that services are up
echo "##### Getting Consul catalog services #####"
consul catalog services
echo "##### Getting Nomad Job Status #####"
nomad job status

terraform -chdir=config init -upgrade
terraform -chdir=config apply -var="peer=dc2" -var="datacenter=dc1" -var="job_region=dc1" -auto-approve
#sleep 5

## DC2
# export CONSUL_HTTP_SSL_VERIFY=false
# export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc2_consul_lb.value')"
# export CONSUL_HTTP_TOKEN="$(cat infra/terraform.tfstate | jq -r '.outputs.dc2_consul_token.value')"
# export NOMAD_ADDR="http://$(cat infra/terraform.tfstate | jq -r '.outputs.dc2_lb_hostname.value'):4646"
# export NOMAD_TOKEN="$(cat infra/creds_dc2/nomad_bootstrap_token)"
# export TF_DATA_DIR=".terraform_dc2"

# echo "What is the consul lb"
# echo $CONSUL_HTTP_ADDR
# # Test that services are up
# echo "##### Getting Consul catalog services #####"
# consul catalog services
# echo "##### Getting Nomad Job Status #####"
# nomad job status

# terraform -chdir=config init -upgrade
# terraform -chdir=config apply -var="peer=dc1" -var="datacenter=dc2" -var="job_region=dc2" -auto-approve