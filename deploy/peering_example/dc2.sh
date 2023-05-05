## Run this on dc2

### Install Apps 

## Spectrum Guard with sidecar
cat <<EOT > /etc/systemd/system/spectrum-guard.service
[Unit]
Description=spectrum-guard
After=syslog.target network.target

[Service]
Environment=NAME="spectrum-guard in dc2"
Environment=MESSAGE="spectrum-guard in dc2"
Environment=LISTEN_ADDR="0.0.0.0:9200"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/systemd/system/spectrum-guard-sidecar.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}
ExecStart=/usr/bin/consul connect envoy -sidecar-for spectrum-guard -admin-bind 127.0.0.1:19100
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/spectrum-guard.hcl
service {
  name = "spectrum-guard"
  port = 9200
  tags = ["spectrum-guard"]

  checks = [
    {
      name = "HTTP API on port 9200"
      http = "http://127.0.0.1:9200/health"
      interval = "10s"
      timeout = "5s"
    }
  ]

  connect {
    sidecar_service {}
  }

  token = "${CONSUL_HTTP_TOKEN}"
}
EOT


## Spectrum Guard with terminating
cat <<EOT > /etc/systemd/system/spectrum-guard-terminating.service
[Unit]
Description=spectrum-guard-terminating
After=syslog.target network.target

[Service]
Environment=NAME="spectrum-guard in dc2 behind terminating gateway"
Environment=MESSAGE="spectrum-guard in dc2 behind terminating gateway"
Environment=LISTEN_ADDR="0.0.0.0:9201"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT


cat <<EOT > /etc/consul.d/spectrum-guard-terminating.hcl
service {
  name = "spectrum-guard-terminating"
  port = 9201
  tags = ["spectrum-guard", "terminating-gateway"]

  checks = [
    {
      name = "HTTP API on port 9201"
      http = "http://127.0.0.1:9201/health"
      interval = "10s"
      timeout = "5s"
    }
  ]
  token = "${CONSUL_HTTP_TOKEN}"
}
EOT

systemctl daemon-reload
systemctl enable spectrum-guard --now
systemctl enable spectrum-guard-sidecar --now
systemctl enable spectrum-guard-terminating --now

consul reload

## Export spectrum-guard to dc1
cat << 'EOT' > /root/exported-services.hcl
Kind = "exported-services"
Name = "default"

Services = [
  {
    Name      = "spectrum-guard"
    Consumers = [
        {
            Peer  = "dc1"
        }
    ]
  },
  {
    Name      = "spectrum-guard-terminating"
    Consumers = [
        {
            Peer  = "dc1"
        }
    ]
  }  
]
EOT
consul config write /root/exported-services.hcl

# Add spectrum guard to the terminating gateway
cat <<EOT > /root/terminating.hcl
Kind = "terminating-gateway"
Name = "terminating-gateway"

Services = [
  {
    Name = "spectrum-guard-terminating"
  }
]
EOT

consul config write /root/terminating.hcl



## Create a TCP listener on port 2345 
cat <<EOT > /root/ingress.hcl
Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 2345
    Protocol = "tcp"
    Services = [
      {
        Name = "spectrum-guard"
      }
    ]
  },
  {
    Port     = 3456
    Protocol = "tcp"
    Services = [
      {
        Name = "spectrum-guard-terminating"
      }
    ]
  },
  {
    Port     = 4567
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

cat <<EOT > /root/spectrum-guard-intention.hcl
Kind = "service-intentions"
Name = "spectrum-guard"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  },
  {
    Name   = "ingress-gateway"
    Peer   = "dc1"
    Action = "allow"
  },
  {
    Name   = "spectrum-guard-client"
    Peer   = "dc1"
    Action = "allow"
  },
  {
    Name   = "spectrum-guard-client"
    Action = "allow"
  }
]
EOT
consul config write /root/spectrum-guard-intention.hcl

cat <<EOT > /root/spectrum-guard-terminating-intention.hcl
Kind = "service-intentions"
Name = "spectrum-guard-terminating"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  },
  {
    Name   = "ingress-gateway"
    Peer   = "dc1"
    Action = "allow"
  },
  {
    Name   = "spectrum-guard-client"
    Peer   = "dc1"
    Action = "allow"
  },
  {
    Name   = "spectrum-guard-client"
    Action = "allow"
  }
]
EOT
consul config write /root/spectrum-guard-terminating-intention.hcl



## Spectrum Guard 
cat <<EOT > /etc/systemd/system/spectrum-guard-client.service
[Unit]
Description=spectrum-guard-client
After=syslog.target network.target

[Service]
Environment=NAME="spectrum-guard-client in dc2"
Environment=MESSAGE="spectrum-guard-client in dc2"
Environment=LISTEN_ADDR="0.0.0.0:9202"
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
ExecStart=/usr/bin/consul connect envoy -sidecar-for spectrum-guard-client -admin-bind 127.0.0.1:19101
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/spectrum-guard-client.hcl
service {
  name = "spectrum-guard-client"
  port = 9202
  tags = ["spectrum-guard-client"]

  checks = [
    {
      name = "HTTP API on port 9202"
      http = "http://127.0.0.1:9202/health"
      interval = "10s"
      timeout = "5s"
    }
  ]

  connect {
    sidecar_service {
      proxy {
        upstreams {
          destination_name = "spectrum-guard"
          local_bind_port = 9300
        }
        upstreams {
          destination_name = "spectrum-guard-terminating"
          local_bind_port = 9301
        }        
      }
    }
  }

  token = "${CONSUL_HTTP_TOKEN}"
}
EOT
consul reload

cat <<EOT > /root/downstream-intention.hcl
Kind = "service-intentions"
Name = "spectrum-guard-client"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  }
]
EOT
consul config write /root/downstream-intention.hcl

systemctl enable spectrum-guard-client --now
systemctl enable spectrum-guard-client-sidecar --now
consul reload