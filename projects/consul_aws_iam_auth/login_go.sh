#!/bin/sh
export CONSUL_HTTP_SSL_VERIFY=false
export CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')"

## Create output.json
/usr/local/bin/login

## Replace strings

cat output.json | sed "s/\"/'/g" > output_string.json

# Create payload.json
# cat <<EOF > payload.json
# {
#   "AuthMethod": "iam_auth",
#   "BearerToken": "$(cat output_string.json)"
# }
# EOF


cat ./payload.json
curl -k \
  --request POST \
  --data @payload.json \
  "${CONSUL_HTTP_ADDR}/v1/acl/login"

