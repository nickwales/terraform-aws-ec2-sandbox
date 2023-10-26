#!/bin/sh

# Create certificates
consul tls ca create 
consul tls cert create -server
consul tls cert create -client
mkdir certs_dc1
mv *.pem certs_dc1

consul tls ca create 
consul tls cert create -dc dc2 -server
consul tls cert create -dc dc2 -client
mkdir certs_dc2
mv *.pem certs_dc2

consul keygen > certs_dc1/encryption_key
consul keygen > certs_dc2/encryption_key

terraform apply -auto-approve