#!/bin/sh

terraform -chdir=infra destroy -auto-approve

rm -rf infra/creds