#### Deploy mesh examples

## Setup env variables
export CONSUL_HTTP_ADDR=$(cat terraform.tfstate | jq -r '.outputs.consul_lb.value')
export CONSUL_HTTP_TOKEN=$(cat terraform.tfstate | jq -r '.outputs.consul_token.value')

export NOMAD_ADDR=$(cat terraform.tfstate | jq -r '.outputs.nomad_lb.value')
export NOMAD_TOKEN=$(cat terraform.tfstate | jq -r '.outputs.nomad_token.value')

## Deploy config

consul config write consul_config/mesh_examples/proxy_defaults.hcl
consul config write consul_config/mesh_examples/service_defaults_ingress.hcl
consul config write consul_config/mesh_examples/service_defaults_teeceepee.hcl

## Deploy Jobs

nomad job run jobs/mesh_examples/upstream.nomad
