#!/bin/sh

# Create certificates
consul tls ca create 
consul tls cert create -server
mkdir certs_dc1
mv *.pem certs_dc1

consul keygen > certs_dc1/encryption_key

terraform apply -auto-approve