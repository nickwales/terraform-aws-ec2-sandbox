#!/bin/sh

terraform destroy -auto-approve

rm -rf certs* 
