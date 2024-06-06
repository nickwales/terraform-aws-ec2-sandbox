#!/bin/sh

# Create certificates

if ! [ -d infra/certs ]; then
  echo "Certificates directory does not exist, creating certs..."
  consul tls ca create 
  consul tls cert create -server
  mkdir infra/certs
  mv *.pem infra/certs
  consul keygen > infra/certs/encryption_key
else
  echo "Certificates directory does exist, moving on..."
fi

# terraform -chdir="./infra" init
# terraform -chdir=infra apply -auto-approve
