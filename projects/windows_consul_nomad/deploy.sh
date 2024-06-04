#!/bin/sh

# Create certificates
consul tls ca create 
consul tls cert create -server
mkdir certs
mv *.pem certs

consul keygen > certs/encryption_key

#terraform apply -auto-approve