#!/bin/sh

# Create certificates
consul tls ca create 
consul tls cert create
mkdir certs
mv *.pem certs

terraform apply -auto-approve