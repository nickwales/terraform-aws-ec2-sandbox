#!/bin/sh
export CONSUL_HTTP_SSL_VERIFY=false
export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')"
echo "Connecting to: $CONSUL_HTTP_ADDR"

echo "Outputting token to ./token"
consul login -method iam_auth -aws-auto-bearer-token -token-sink-file="./token"
echo "This is the token value: $(cat ./token)"