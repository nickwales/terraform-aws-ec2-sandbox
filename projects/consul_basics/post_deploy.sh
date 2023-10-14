#!/bin/sh

# Set the consul addresses
consul_dc1_addr=$(cat terraform.tfstate | jq -r '.outputs.dc1_consul_ui_addr.value')
consul_dc2_addr=$(cat terraform.tfstate | jq -r '.outputs.dc2_consul_ui_addr.value')
consul_token=$(cat terraform.tfstate | jq -r '.outputs.consul_token.value')

export CONSUL_HTTP_TOKEN=$consul_token

# Creating peering connections
datastores_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-datastores -partition datastores)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-datastores -peering-token $datastores_peering_token -partition datastores
 
global_api_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-global-api -partition global-api)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-global-api -peering-token $datastores_peering_token -partition global-api
 

global_api_sg_dc1=$(cat << EOF
Kind               = "sameness-group"
Name               = "global-api"
Partition          = "global-api"
DefaultForFailover = true
Members = [
  { Partition = "global-api" },
  { Peer = "dc2-global-api" },
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write -partition global-api - <<< $global_api_sg_dc1

global_api_sg_dc2=$(cat << EOF
Kind               = "sameness-group"
Name               = "global-api"
Partition          = "global-api"
DefaultForFailover = true
Members = [
  { Partition = "global-api" },
  { Peer = "dc1-global-api" },
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write -partition global-api - <<< $global_api_sg_dc2

exported_services_global_api_dc1=$(cat << EOF
Kind = "exported-services"
Name = "global-api"
Partition = "global-api"
Services = [
  {
    Name = "middleware"
    Namespace = "secure"
    Consumers = [
      {
        SamenessGroup = "global-api"
      },
      {
        Partition = "ui"
      }
    ]
  }   
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write -partition global-api - <<< $exported_services_global_api_dc1

exported_services_global_api_dc2=$(cat << EOF
Kind = "exported-services"
Name = "global-api"
Partition = "global-api"
Services = [
  {
    Name = "middleware"
    Namespace = "secure"
    Consumers = [
      {
        SamenessGroup = "global-api"
      }
    ]
  }   
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write -partition global-api - <<< $exported_services_global_api_dc2


### Datastores

datastores_sg_dc1=$(cat << EOF
Kind               = "sameness-group"
Name               = "datastores"
Partition          = "datastores"
DefaultForFailover = true
Members = [
  { Partition = "datastores" },
  { Peer = "dc2-datastores" },
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write -partition datastores - <<< $datastores_sg_dc1

datastores_sg_dc2=$(cat << EOF
Kind               = "sameness-group"
Name               = "datastores"
Partition          = "datastores"
DefaultForFailover = true
Members = [
  { Partition = "datastores" },
  { Peer = "dc1-datastores" },
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write -partition datastores - <<< $datastores_sg_dc2


exported_services_datastores_dc2=$(cat << EOF
Kind = "exported-services"
Name = "datastores"
Partition = "datastores"
Services = [
  {
    Name = "backend"
    Namespace = "postgres"
    Consumers = [
      {
        SamenessGroup = "datastores"
      }
    ]
  }   
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write -partition datastores - <<< $exported_services_datastores_dc2
