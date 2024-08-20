#!/bin/sh

# Create a CA

mkdir ~/certs
cd ~/certs

openssl genrsa -des3 -out consul-agent-ca.key 2048
openssl req -x509 -new -nodes -key consul-agent-ca.key -sha256 -days 1825 -out consul-agent-ca.pem


# Create certificates

cat <<EOF >> ssl.conf
[req]
req_extensions = req_ext
distinguished_name = dn
[ dn ]
CN = *.dc1.consul
[ req_ext ]
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = localhost
DNS.2 = *.amazonaws.com
DNS.3 = server.dc1.consul
IP.1  = 127.0.0.1
EOF

openssl req -new -newkey rsa:2048 -nodes -keyout server.dc1.consul.key -out server.dc1.consul.csr -subj '/CN=server.dc1.consul' -config ssl.conf
openssl x509 -req -in server.dc1.consul.csr -CA consul-agent-ca.pem -CAkey consul-agent-ca.key -CAcreateserial -out server.dc1.consul.crt -extfile ssl.conf -extensions req_ext

terraform apply -auto-approve
