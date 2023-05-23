# Install Envoy
export envoy_version="1.24.1"
useradd envoy
curl https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
func-e use ${envoy_version}
cp /root/.func-e/versions/${envoy_version}/bin/envoy /usr/local/bin

export CONSUL_HTTP_TOKEN=root
echo CONSUL_HTTP_TOKEN=root >> /etc/environment

# Install fake-service
mkdir -p /opt/fake-service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.24.2/fake_service_linux_amd64.zip
unzip -od /opt/fake-service/ fake_service_linux_amd64.zip
rm -f fake_service_linux_amd64.zip
chmod +x /opt/fake-service/fake-service


### On prem services

### Consul configuration 
###  These can be run on any member of the Consul cluster.

## Proxy Defaults
cat <<EOT > /root/proxy-defaults.hcl
Kind      = "proxy-defaults"
Name      = "global"
MeshGateway {
  Mode = "local"
}
EOT
consul config write /root/proxy-defaults.hcl

## Create a TCP listener on port 3456 
cat <<EOT > /root/ingress.hcl
Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 3456
    Protocol = "tcp"
    Services = [
      {
        Name = "edge-client"
      }
    ]
  }
]
EOT
consul config write /root/ingress.hcl

## Exported services

cat <<EOT > /root/exported-services.hcl
Kind = "exported-services"
Name = "default"
Services = [
  {
    Name = "database"
    Consumers = [
      {
        Peer = "aws"
      }
    ]
  }     
]
EOT
consul config write /root/exported-services.hcl


### Intentions 

## Deny all by default
cat <<EOT > /root/default-intention.hcl
Kind = "service-intentions"
Name = "*"
Sources = [
  {
    Name   = "*"
    Action = "deny"
  }
]
EOT
consul config write /root/default-intention.hcl

## Allow the ingress to talk to the "client"
cat <<EOT > /root/edge-client-intention.hcl
Kind = "service-intentions"
Name = "edge-client"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  }
]
EOT
consul config write /root/edge-client-intention.hcl

## Allow the client to talk to the database
cat <<EOT > /root/edge-database-intention.hcl
Kind = "service-intentions"
Name = "cache"
Sources = [
  {
    Name   = "edge-client"
    Action = "allow"
  }
]
EOT
consul config write /root/edge-database-intention.hcl


## Allow the client to talk to the cache service
cat <<EOT > /root/edge-cache-intention.hcl
Kind = "service-intentions"
Name = "database"
Sources = [
  {
    Name   = "cache"
    Action = "allow"
  },
  {
    Name   = "cache"
    Peer   = "aws"
    Action = "allow"
  }  
]
EOT
consul config write /root/edge-cache-intention.hcl

cat <<EOT > /root/database-failover.hcl
Kind           = "service-resolver"
Name           = "database"
ConnectTimeout = "3s"
Failover = {
  "*" = {
    Targets = [
      {Peer = "aws"}
    ]
  }
}
EOT
consul config write /root/database-failover.hcl


# Configure the cache to failover to AWS peer
cat <<EOT > /root/cache-failover.hcl
Kind           = "service-resolver"
Name           = "cache"
ConnectTimeout = "3s"
Failover = {
  "*" = {
    Targets = [
      {Peer = "aws"}
    ]
  }
}
EOT
consul config write /root/cache-failover.hcl


