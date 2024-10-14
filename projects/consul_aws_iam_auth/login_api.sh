#!/bin/sh
CONSUL_HTTP_SSL_VERIFY=false
CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')"
ACCESS_KEY=$(aws configure get aws_access_key_id)
SECRET_KEY=$(aws configure get aws_secret_access_key)

REGION="us-east-1"
SERVICE="sns"
METHOD="GET"
HOST="$SERVICE.$REGION.amazonaws.com"
ALGO="AWS4-HMAC-SHA256"

fulldate=$(date -u +"%Y%m%dT%H%M00Z")
shortdate=$(date -u +"%Y%m%d")


file_sha256=$(echo -n "" | openssl dgst -sha256 -binary | xxd -p -c 256)

function urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf "$c" ;;
    *) printf "$c" | xxd -p -c1 | while read x;do printf "%%%s" "$x";done
  esac
done
}

function to_hex() {
    printf "$1" | od -A n -t x1 | tr -d [:space:]
}
function hmac_sha256() {
    printf "$2" | \
        openssl dgst -binary -hex -sha256 -mac HMAC -macopt hexkey:"$1" | \
        sed 's/^.* //'
}

canonicalQuery="$(urlencode "Action")=$(urlencode "ListSubscriptions")"

# Assemble canonical url
canonicalRequest="$METHOD
/
$canonicalQuery
host:$HOST
x-amz-date:$fulldate

host;x-amz-date
$file_sha256"

canonReqSha=$(echo -n "$canonicalRequest" | openssl dgst -sha256 -binary | xxd -p -c 256)

stringToSign="$ALGO
$fulldate
$shortdate/$REGION/$SERVICE/aws4_request
$canonReqSha"

secret=$(to_hex "AWS4${SECRET_KEY}")
k_date=$(hmac_sha256 "${secret}" "${shortdate}")
k_region=$(hmac_sha256 "${k_date}" "${REGION}")
k_service=$(hmac_sha256 "${k_region}" "${SERVICE}")
k_signing=$(hmac_sha256 "${k_service}" "aws4_request")
signature=$(hmac_sha256 "${k_signing}" "${stringToSign}" | sed 's/^.* //')


AUTHORIZATION="$ALGO Credential=${ACCESS_KEY}/${shortdate}/${REGION}/${SERVICE}/aws4_request, SignedHeaders=host;x-amz-date, Signature=${signature}"
ENCODED_AUTH=$(echo $AUTHORIZATION | base64 )

cat <<EOF > payload.json
{
  "AuthMethod": "iam_auth",
  "BearerToken": "${ENCODED_AUTH}"
}
EOF

cat ./payload.json
curl -k \
  --request POST \
  --data @payload.json \
  "${CONSUL_HTTP_ADDR}/v1/acl/login"

