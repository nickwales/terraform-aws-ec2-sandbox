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


### services

### Consul configuration 
##  These can be run on any machine.

### Proxy Defaults

cat <<EOT > /root/proxy-defaults.hcl
Kind      = "proxy-defaults"
Name      = "global"
MeshGateway {
  Mode = "local"
}
EOT

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

## Allow the client to talk to the database
cat <<EOT > /root/aws-database-intention.hcl
Kind = "service-intentions"
Name = "database"
Sources = [
  {
    Name   = "cache"
    Peer   = "edge"
    Action = "allow"
  },
  {
    Name   = "cache"
    Action = "allow"
  }
]
EOT
consul config write /root/aws-database-intention.hcl

## Allow the client to talk to the cache
cat <<EOT > /root/aws-cache-intention.hcl
Kind = "service-intentions"
Name = "cache"
Sources = [
  {
    Name   = "edge-client"
    Peer   = "edge"
    Action = "allow"
  }
]
EOT
consul config write /root/aws-cache-intention.hcl

cat <<EOT > /root/exported-services.hcl
Kind = "exported-services"
Name = "default"
Services = [
  {
    Name = "cache"
    Consumers = [
      {
        Peer = "edge"
      }
    ]
  }      
]
EOT
consul config write /root/exported-services.hcl


# Configure the cache to failover to AWS peer
cat <<EOT > /root/cache-failover.hcl
Kind           = "service-resolver"
Name           = "cache"
ConnectTimeout = "3s"
Failover = {
  "*" = {
    Targets = [
      {Peer = "edge"}
    ]
  }
}
EOT
consul config write /root/cache-failover.hcl


# Configure the database to failover to edge peer
cat <<EOT > /root/database-failover.hcl
Kind           = "service-resolver"
Name           = "database"
ConnectTimeout = "3s"
Failover = {
  "*" = {
    Targets = [
      {Peer = "edge"}
    ]
  }
}
EOT
consul config write /root/database-failover.hcl