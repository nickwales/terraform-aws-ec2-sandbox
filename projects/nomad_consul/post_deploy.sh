#!/bin/sh

# Configure CLIs

export CONSUL_HTTP_TOKEN=$(cat terraform.tfstate | jq -r .outputs.consul_token.value)
export CONSUL_HTTP_ADDR=$(cat terraform.tfstate | jq -r .outputs.consul_lb.value)
export NOMAD_HTTP_ADDR=$(cat terraform.tfstate | jq -r .outputs.nomad_lb.value)

consul config write ./consul_config/proxy_defaults.hcl 
consul config write ./consul_config/service_defaults_teeceepee.hcl
consul config write ./consul_config/service_defaults_ingress.hcl

nomad job run jobs/downstream.nomad
nomad job run jobs/midstream.nomad
nomad job run jobs/upstream.nomad
nomad job run jobs/teeceepee.nomad
nomad job run jobs/ingress-gateway.nomad
#nomad job run jobs/terminating-gateway.nomad