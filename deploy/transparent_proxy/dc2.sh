## This deploys
# A couple of services with transparent proxy

## Allow access to the "upstream" from the downstream in dc1
cat <<EOT > /root/downstream-intention.hcl
Kind = "service-intentions"
Name = "upstream"
Sources = [
  {
    Name   = "downstream"
    Peer   = "dc1"
    Action = "allow"
  }
]
EOT

consul config write /root/downstream-intention.hcl

### Install Apps 
## Upstream service 
cat <<EOT > /etc/systemd/system/upstream.service
[Unit]
Description=upstream
After=syslog.target network.target

[Service]
Environment=NAME="upstream in dc2"
Environment=MESSAGE="upstream in dc2"
Environment=LISTEN_ADDR="0.0.0.0:9101"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/upstream.hcl
service {
  name = "upstream"
  port = 9101
  tags = ["vm", "t-proxy"]

  checks = [
    {
      name = "HTTP API on port 9101"
      http = "http://127.0.0.1:9101/health"
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

cat <<EOT > /etc/systemd/system/upstream-sidecar.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}
ExecStart=/usr/bin/consul connect envoy -sidecar-for upstream -admin-bind 127.0.0.1:19011
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl restart upstream
systemctl restart upstream-sidecar

cat << 'EOT' > /root/exported-services.hcl
Kind = "exported-services"
Name = "default"

Services = [
  {
    Name      = "upstream"
    Consumers = [
        {
            Peer  = "dc1"
        }
    ]
  }
]
EOT
consul config write /root/exported-services.hcl