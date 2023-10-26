#!/bin/sh

### Questions

## How can I export sameness groups like services?
# Answer: we cannot



# Set the consul cluster addresses
consul_dc1_addr=$(cat terraform.tfstate | jq -r '.outputs.dc1_consul_lb.value')
consul_dc2_addr=$(cat terraform.tfstate | jq -r '.outputs.dc2_consul_lb.value')
export CONSUL_HTTP_TOKEN=$(cat terraform.tfstate | jq -r '.outputs.consul_token.value')


# Create Partitions and namespaces
export CONSUL_HTTP_ADDR=$consul_dc1_addr
consul partition create -name ui
consul namespace create -name public -partition ui

consul partition create -name datastores
consul namespace create -name elasticsearch -partition datastores

consul partition create -name global-api
consul namespace create -name external -partition global-api
consul namespace create -name internal -partition global-api

export CONSUL_HTTP_ADDR=$consul_dc2_addr
consul partition create -name ui
consul namespace create -name public -partition ui

consul partition create -name datastores
consul namespace create -name elasticsearch -partition datastores

consul partition create -name global-api
consul namespace create -name external -partition global-api
consul namespace create -name internal -partition global-api

# Configure ACLs
### Testing

partition_agent_default_policy=$(cat <<EOT
partition_prefix "ui" {
  namespace_prefix "" {
    node_prefix "" {
      policy = "read"
    }
    session_prefix "" {
      policy = "write"
    }
    service_prefix "" {
      policy = "read"
    }
    key_prefix "" {
      policy = "read"
    }
  }
  Not allowed?!?

}
query_prefix "" {
  policy = "read"
}
EOT
)


token_id=0
for partition in ui global-api datastores
do
partition_agent_policy=$(cat <<EOT
node_prefix "" {
  policy = "write"
}

namespace_prefix "" {
  node_prefix "" {
    policy = "read"
  }
  session_prefix "" {
    policy = "write"
  }
  service_prefix "" {
    policy = "read"
  }
  key_prefix "" {
    policy = "read"
  }
}
# Not allowed?!?
# query_prefix "" {
#   policy = "read"
# }
EOT
)

CONSUL_HTTP_ADDR=$consul_dc1_addr consul acl policy create \
  -name "${partition}-agent-policy" \
  -description "This is the agent policy for ${partition} nodes" \
  -rules $partition_agent_policy \
  -partition $partition

CONSUL_HTTP_ADDR=$consul_dc2_addr consul acl policy create \
  -name "${partition}-agent-policy" \
  -description "This is the agent policy for ${partition} nodes" \
  -rules - <<< $partition_agent_policy \
  -partition $partition

CONSUL_HTTP_ADDR=$consul_dc1_addr consul acl token create  \
  -secret "30000000-0000-0000-0000-00000000000${token_id}" \
  -policy-name "${partition}-agent-policy" \
  -partition $partition

CONSUL_HTTP_ADDR=$consul_dc2_addr consul acl token create  \
  -secret "30000000-0000-0000-0000-00000000000${token_id}" \
  -policy-name "${partition}-agent-policy" \
  -partition $partition

token_id=$((token_id + 1))
echo $token_id
done

# Creating peering connections
## Set configurations

mesh_config=$(cat <<EOT
Kind = "mesh"
Peering {
  PeerThroughMeshGateways = true
}
EOT
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write - <<< $mesh_config
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write - <<< $mesh_config

proxy_config=$(cat <<EOT
Kind = "proxy-defaults"
Name = "global"
MeshGateway {
   Mode = "local"
}
EOT
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write - <<< $proxy_config
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write - <<< $proxy_config

# Peer DC1 UI to export to DC2 UI
dc1_ui_to_dc2_ui_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-ui -partition ui)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-ui -peering-token $dc1_ui_to_dc2_ui_peering_token -partition ui



# Peer DC2 api-global to export to DC1 UI
dc1_ui_to_dc2_api_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-global-api -partition ui)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-ui -peering-token $dc1_ui_to_dc2_api_peering_token -partition global-api

# dc1_api_to_dc2_api_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-global-api -partition global-api)
# CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-global-api -peering-token $dc1_api_to_dc2_api_peering_token -partition global-api

# Peer UI DC1 to Datastores DC2 for sameness groups
# dc1_datastores_to_dc2_datastores_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-datastores -partition datastores)
# CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-datastores -peering-token $dc1_datastores_to_dc2_datastores_peering_token -partition datastores

# Peer datastores DC1 and DC2 for sameness groups
dc1_datastores_to_dc2_datastores_peering_token=$(CONSUL_HTTP_ADDR=$consul_dc1_addr consul peering generate-token -name dc2-datastores -partition datastores)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul peering establish -name dc1-datastores -peering-token $dc1_datastores_to_dc2_datastores_peering_token -partition datastores

##### UI Consul Configurations

## Export dc2-ui services to dc1-ui
exported_services_ui_dc2=$(cat << EOF
Kind = "exported-services"
Name = "ui"
Partition = "ui"
Services = [
  {
    Name = "images"
    Namespace = "public"
    Consumers = [
      {
        Peer = "dc1-ui"
      }
    ]
  }      
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc2_addr consul config write - <<< $exported_services_ui_dc2


##### Global API Consul Configuration

# Create Gloabl API Sameness Group in DC1
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
    Name = "search-data"
    Namespace = "internal"
    Consumers = [
      {
        SamenessGroup = "global-api"
      } 
    ]
  },
  {
    Name = "search-api"
    Namespace = "external"
    Consumers = [
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
    Name = "search-data"
    Namespace = "internal"
    Consumers = [
      {
        SamenessGroup = "global-api"
      } 
    ]
  },
  {
    Name = "search-api"
    Namespace = "external"
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



##### Datastores Consul Configuration

# Create datastores search sameness group in DC1
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


# Export datastores services and sameness groups
exported_services_datastores_dc1=$(cat << EOF
Kind = "exported-services"
Name = "datastores"
Partition = "datastores"
Services = [
  {
    Name = "products"
    Namespace = "elasticsearch"
    Consumers = [
      {
        SamenessGroup = "datastores"
      }
    ]
  }         
]
EOF
)
CONSUL_HTTP_ADDR=$consul_dc1_addr consul config write -partition datastores - <<< $exported_services_datastores_dc1



# Create Elastic search sameness group in DC2
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


# Export datastores services and sameness groups
exported_services_datastores_dc2=$(cat << EOF
Kind = "exported-services"
Name = "datastores"
Partition = "datastores"
Services = [
  {
    Name = "products"
    Namespace = "elasticsearch"
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



curl -H "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" "${consul_dc1_addr}/v1/query" \
  --request POST \
  --verbose \
  --data @- << EOF
{
  "Name": "products",
  "Token": "",
  "Service": {
    "Service": "products",
    "SamenessGroup": "datastores",
    "Namespace": "elasticsearch",
    "Partition": "datastores"
  }
}
EOF

curl -H "X-Consul-Token: ${CONSUL_HTTP_TOKEN}" "${consul_dc1_addr}/v1/query" --verbose


____END____


