#!/bin/sh
# Determine the region if configured in tfvars to set the tls cert
tfvars="infra/terraform.tfvars"
region="us-east-1"
if [ -f $tfvars ]; then
    echo "A tfvars file exists"
    newRegion=$(cat $tfvars | grep region | awk '{print $3}' |  tr -d '"')
    if [ ! -z ${newRegion} ]; then
      echo "tfvars file has overridden the region to: ${newRegion}"
      region="${newRegion}"
    fi
fi
echo "This is the region ${region}"

# Create certificates and other credentials if required
dc=dc1
if ! [ -d infra/creds_${dc} ]; then  
  echo "Certificates directory does not exist, creating certs..."
  consul tls ca create 
  consul tls cert create -server -dc ${dc} -additional-dnsname="*.elb.${region}.amazonaws.com"
  mkdir infra/creds_${dc}
  mv *.pem infra/creds_${dc}
  consul keygen > infra/creds_${dc}/encryption_key
  uuidgen | tr "[:upper:]" "[:lower:]" > infra/creds_${dc}/nomad_bootstrap_token
else
  echo "Certificates directory does exist, moving on..."
fi

dc=dc2
if ! [ -d infra/creds_${dc} ]; then  
  echo "Certificates directory does not exist, creating certs..."
  consul tls ca create 
  consul tls cert create -server -dc ${dc} -additional-dnsname="*.elb.${region}.amazonaws.com"
  mkdir infra/creds_${dc}
  mv *.pem infra/creds_${dc}
  consul keygen > infra/creds_${dc}/encryption_key
  uuidgen | tr "[:upper:]" "[:lower:]" > infra/creds_${dc}/nomad_bootstrap_token
else
  echo "Certificates directory does exist, moving on..."
fi

terraform -chdir="./infra" init -upgrade
terraform -chdir=infra apply -auto-approve
