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
##  These can be run on any machine.



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

## Allow the client to talk to the database
cat <<EOT > /root/aws-database-intention.hcl
Kind = "service-intentions"
Name = "aws-database"
Sources = [
  {
    Name   = "edge-client"
    Peer   = "edge"
    Action = "allow"
  }
]
EOT
consul config write /root/aws-database-intention.hcl

## Allow the client to talk to the cache
cat <<EOT > /root/aws-cache-intention.hcl
Kind = "service-intentions"
Name = "aws-cache"
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
    Name = "aws-cache"
    Consumers = [
      {
        Peer = "edge"
      }
    ]
  },
  {
    Name = "aws-database"
    Consumers = [
      {
        Peer = "edge"
      }
    ]
  }  
]
EOT
consul config write /root/exported-services.hcl