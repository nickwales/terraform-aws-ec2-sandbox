#!/bin/sh

### Questions

## How can I export sameness groups like services?
#  Are they services?
## From a DNS perspective, how can I manage who can query for my exported serviecs vs my non exported services?
## Is exporting the service which is part of a sameness group the same as exporting the SG?


# Set the consul cluster addresses
consul_dc1_addr="$(cat terraform.tfstate | jq -r '.outputs.consul_entrypoint.value')"
#consul_dc2_addr=$(cat terraform.tfstate | jq -r '.outputs.dc2_consul_lb.value')
consul_token=$(cat terraform.tfstate | jq -r '.outputs.consul_token.value')

export CONSUL_HTTP_TOKEN=$consul_token

export CONSUL_HTTP_ADDR=$consul_dc1_addr

# API calls for namespace create (consul ent binary not required)

namespaces=("ui" "middleware" "datastores" "network")
for ns in "${namespaces[@]}"; do
curl --request PUT "$CONSUL_HTTP_ADDR/v1/namespace" \
--header "X-Consul-Token: $CONSUL_HTTP_TOKEN" \
--data @- << EOF
    {
        "Name": "$ns",
        "Description": "namespace for $ns",
        "Partition": "default",
        "Meta": {
        "tag": "$ns"
        }
    }
EOF
done

consul intention create -deny "*" "*" 

database_intention=$(cat <<EOT
Kind = "service-intentions"
Name = "database"
Namespace = "datastores"
Sources = [
  {
    Name   = "middleware"
    Namespace = "middleware"
    Action = "allow"
  }
]
EOT
)
consul config write - <<< $database_intention

middleware_intention=$(cat <<EOT
Kind = "service-intentions"
Name = "middleware"
Namespace = "middleware"
Sources = [
  {
    Name   = "frontend"
    Namespace = "ui"
    Action = "allow"
  }
]
EOT
)
consul config write - <<< $middleware_intention

frontend_intention=$(cat <<EOT
Kind = "service-intentions"
Name = "frontend"
Namespace = "ui"
Sources = [
  {
    Name   = "ingress-gateway"
    Namespace = "default"
    Action = "allow"
  }
]
EOT
)
consul config write - <<< $frontend_intention

telemetry_collector_intention=$(cat <<EOT
Kind = "service-intentions"
Name = "consul-telemetry-collector"
Namespace = "default"
Sources = [
  {
    Name   = "*"
    Namespace = "*"
    Action = "allow"
  }
]
EOT
)
consul config write - <<< $telemetry_collector_intention

proxy_defaults=$(cat <<EOT
Kind      = "proxy-defaults"
Name      = "global"
Config {
  envoy_telemetry_collector_bind_socket_dir = "/opt/envoy_stats"
  protocol = "http"
}
EOT
)
consul config write - <<< $proxy_defaults

## Ingress gateway
ingress_config=$(cat <<EOT
Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 8080
    Protocol = "http"
    Services = [
      {
        Name = "frontend"
        Namespace = "ui"
        Hosts = ["*"]
      }
    ]
  }
]
EOT
)
consul config write - <<< $ingress_config




collector_defaults=$(cat <<EOT
Kind      = "service-defaults"
Name      = "consul-telemetry-collector"
Protocol  = "tcp"
EOT
)
consul config write - <<< $collector_defaults