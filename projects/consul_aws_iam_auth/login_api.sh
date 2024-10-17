#!/bin/sh
CONSUL_HTTP_SSL_VERIFY=false
CONSUL_HTTP_ADDR="$(cat infra/terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')"
ACCESS_KEY=$(aws configure get aws_access_key_id)
SECRET_KEY=$(aws configure get aws_secret_access_key)
SESSION_TOKEN="$(aws configure get aws_session_token)"

REGION="us-east-1"
SERVICE="sts"
METHOD="POST"
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


canonicalQuery="$(urlencode "Action")=$(urlencode "GetCallerIdentity")&$(urlencode "Version")=$(urlencode "2011-06-15")"

# Assemble canonical url
canonicalRequest="$METHOD
/
$canonicalQuery
host:$HOST
x-amz-date:$fulldate

host;x-amz-date
$file_sha256"

echo "canonicalRequest: $canonicalRequest"

canonReqSha=$(echo  "$canonicalRequest" | openssl dgst -sha256 -binary | xxd -p -c 256)

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

AUTHORIZATION="$ALGO Credential=${ACCESS_KEY}/${shortdate}/${REGION}/${SERVICE}/aws4_request, SignedHeaders=host;user-agent;x-amz-date, Signature=${signature}"
HEADERS=$(jq --arg auth "$AUTHORIZATION" --arg fulldate "$fulldate" --arg host "$HOST" -c --null-input '{"Authorization": [$auth], "x-amz-date": [$fulldate], "host": [$host]}')
ENCODED_HEADERS=$(echo $HEADERS | base64)
URL=$(echo "https://aws.amazon.com/iam?${canonicalQuery}&Version=2011-06-15" | base64 | perl -pe 'chomp') #| tr -d ‘\n’)


echo "This is the url: ${URL}"
BODY=$(echo -n "$canonicalQuery" | base64)

echo "starting jq"
token=$(
  jq --arg body "$BODY" \
    --arg url "${URL}" \
    --arg encoded_headers "$ENCODED_HEADERS" \
    --null-input \
    -c '{"iam_http_request_method":"POST","iam_request_body":"QWN0aW9uPUdldENhbGxlcklkZW50aXR5","iam_request_headers":$encoded_headers,"iam_request_url":"aHR0cHM6Ly9hd3MuYW1hem9uLmNvbS9pYW0/QWN0aW9uPUdldENhbGxlcklkZW50aXR5JlZlcnNpb249MjAxMS0wNi0xNQ=="}'
)

echo "This is the token: $token"
payload=$(jq --arg token "$token" -j --null-input '{"AuthMethod": "iam_auth", "BearerToken":$token}')

echo "This is the payload: $payload"
curl -k \
  --request POST \
  --data "$payload" \
  "${CONSUL_HTTP_ADDR}/v1/acl/login"
