## Run this on dc1

### Install Apps 

## Create a resolver for spectrum-guard in dc2
cat <<EOT > /root/spectrum-resolver.hcl
Kind           = "service-resolver"
Name           = "spectrum-guard"
ConnectTimeout = "5s"
Failover = {
  "*" = {
    Targets = [
      {Peer = "dc2"}
    ]
  }
}
EOT
consul config write /root/spectrum-resolver.hcl


## Create a resolver for spectrum-guard in dc2
cat <<EOT > /root/spectrum-resolver.hcl
Kind           = "service-resolver"
Name           = "spectrum-guard-dc2"
ConnectTimeout = "5s"
Redirect {
  Service    = "spectrum-guard"
  Datacenter = "dc2"
}
EOT
consul config write /root/spectrum-resolver.hcl

## Create a resolver for spectrum-guard-terminating in dc2
cat <<EOT > /root/spectrum-resolver-terminating.hcl
Kind           = "service-resolver"
Name           = "spectrum-guard-terminating-dc2"
ConnectTimeout = "5s"
Redirect {
  Service    = "spectrum-guard-terminating"
  Datacenter = "dc2"
}
EOT
consul config write /root/spectrum-resolver-terminating.hcl


## Create a TCP listener for spectrum-guard 
cat <<EOT > /root/ingress.hcl
Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 2345
    Protocol = "tcp"
    Services = [
      {
        Name = "spectrum-guard-dc2"
      }
    ]
  },
  {
    Port     = 3456
    Protocol = "tcp"
    Services = [
      {
        Name = "spectrum-guard-client"
      }
    ]
  }  

]
EOT
consul config write /root/ingress.hcl


## Spectrum Guard 
cat <<EOT > /etc/systemd/system/spectrum-guard-client.service
[Unit]
Description=spectrum-guard-client
After=syslog.target network.target

[Service]
Environment=NAME="spectrum-guard-client in dc1"
Environment=MESSAGE="spectrum-guard-client in dc1"
Environment=LISTEN_ADDR="0.0.0.0:9200"
Environment=UPSTREAM_URIS="http://127.0.0.1:9300,http://127.0.0.1:9301"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/systemd/system/spectrum-guard-client-sidecar.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}
ExecStart=/usr/bin/consul connect envoy -sidecar-for spectrum-guard-client -admin-bind 127.0.0.1:19100
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/spectrum-guard-client.hcl
service {
  name = "spectrum-guard-client"
  port = 9200
  tags = ["spectrum-guard-client"]

  checks = [
    {
      name = "HTTP API on port 9200"
      http = "http://127.0.0.1:9200/health"
      interval = "10s"
      timeout = "5s"
    }
  ]

  connect {
    sidecar_service {
      proxy {
        upstreams {
          destination_name = "spectrum-guard-terminating-dc2"
          local_bind_port = 9301
        }    
        upstreams {
          destination_name = "spectrum-guard-dc2"
          local_bind_port = 9300
        }    
      }
    }
  }

  token = "${CONSUL_HTTP_TOKEN}"
}
EOT
consul reload

cat <<EOT > /root/spectrum-guard-client-intention.hcl
Kind = "service-intentions"
Name = "spectrum-guard-client"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  }
]
EOT
consul config write /root/spectrum-guard-client-intention.hcl

cat <<EOT > /root/spectrum-guard-dc2-intention.hcl
Kind = "service-intentions"
Name = "spectrum-guard-dc2"
Sources = [
  {
    Name   = "spectrum-guard-client"
    Action = "allow"
  }
]
EOT
consul config write /root/spectrum-guard-dc2-intention.hcl

cat <<EOT > /root/spectrum-guard-terminating-dc2-intention.hcl
Kind = "service-intentions"
Name = "spectrum-guard-terminating-dc2"
Sources = [
  {
    Name   = "spectrum-guard-client"
    Action = "allow"
  }
]
EOT
consul config write  /root/spectrum-guard-terminating-dc2-intention.hcl

systemctl enable spectrum-guard-client --now
systemctl enable spectrum-guard-client-sidecar --now
consul reload