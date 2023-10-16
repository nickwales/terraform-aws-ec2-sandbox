#!/bin/sh

### Questions

## How can I export sameness groups like services?
#  Are they services?
## From a DNS perspective, how can I manage who can query for my exported serviecs vs my non exported services?
## Is exporting the service which is part of a sameness group the same as exporting the SG?


# Set the consul cluster addresses
consul_dc1_addr=$(cat terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')
consul_dc2_addr=$(cat terraform.tfstate | jq -r '.outputs.dc2_consul_lb.value')
consul_token=$(cat terraform.tfstate | jq -r '.outputs.consul_token.value')

export CONSUL_HTTP_TOKEN=$consul_token

export CONSUL_HTTP_ADDR=$consul_dc1_addr
consul partition create -name global-api
consul partition create -name datastores
consul partition create -name ui

consul namespace create -name public -partition ui
consul namespace create -name private -partition ui

consul namespace create -name postgres -partition datastores
consul namespace create -name mongo -partition datastores
consul namespace create -name elasticsearch -partition datastores

consul namespace create -name secure -partition global-api
consul namespace create -name insecure -partition global-api

export CONSUL_HTTP_ADDR=$consul_dc2_addr
consul partition create -name global-api
consul partition create -name datastores
consul partition create -name ui

consul namespace create -name public -partition ui
consul namespace create -name private -partition ui

consul namespace create -name postgres -partition datastores
consul namespace create -name mongo -partition datastores
consul namespace create -name elasticsearch -partition datastores

consul namespace create -name secure -partition global-api
consul namespace create -name insecure -partition global-api

token_id=0
for partition in ui global-api datastores
do
partition_agent_policy=$(cat <<EOT
node_prefix "" {
  policy = "write"
}
  partition "${partition}" {
    node_prefix "" {
      policy = "write"
    }
    namespace_prefix "" {
      service_prefix "" {
        policy = "read"
      }
      key_prefix "" {
        policy = "read"
      }
    } 
  }
EOT
)

CONSUL_HTTP_ADDR=$consul_dc1_addr consul acl policy create \
  -name "${partition}-agent-policy" \
  -description "This is the agent policy for ${partition} nodes" \
  -rules $partition_agent_policy

CONSUL_HTTP_ADDR=$consul_dc2_addr consul acl policy create \
  -name "${partition}-agent-policy" \
  -description "This is the agent policy for ${partition} nodes" \
  -rules - <<< $partition_agent_policy

CONSUL_HTTP_ADDR=$consul_dc1_addr consul acl token create  \
  -secret "30000000-0000-0000-0000-00000000000${token_id}" \
  -policy-name "${partition}-agent-policy"


CONSUL_HTTP_ADDR=$consul_dc2_addr consul acl token create  \
  -secret "30000000-0000-0000-0000-00000000000${token_id}" \
  -policy-name "${partition}-agent-policy"

token_id=$((token_id + 1))
echo $token_id
done



# Creating peering connections
## Datastores to datastores
datastores_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-datastores -partition datastores)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-datastores -peering-token $datastores_peering_token -partition datastores
## Global API to global API
global_api_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-global-api -partition global-api)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-global-api -peering-token $datastores_peering_token -partition global-api
 
# Might need to be added?
## Middleware DC2 to UI DC1
ui_to_middleware_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-global-api -partition ui)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-ui -peering-token $ui_to_middleware_peering_token -partition global-api

# Create API Sameness Group in DC1
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

# Create API Sameness Group in DC2
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

# Export API sameness group DC1
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
  } #,
  # {
  #   Name = "product-api"
  #   Namespace = "insecure"
  #   Consumers = [
  #     {
  #       Partition = "ui"
  #     }
  #   ]
  # }
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
      },
      {
        Peer = "dc1-ui"
      }
    ]
  },
  {
    Name = "search"
    Namespace = "insecure"
    Consumers = [
      {
        Peer = "dc1-ui"
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

exported_services_datastores_dc1=$(cat << EOF
Kind = "exported-services"
Name = "datastores"
Partition = "datastores"
Services = [
  {
    Name = "backend"
    Namespace = "postgres"
    Consumers = [
      {
        Partition = "global-api"
      }
    ]
  }   
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write -partition datastores - <<< $exported_services_datastores_dc1



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
