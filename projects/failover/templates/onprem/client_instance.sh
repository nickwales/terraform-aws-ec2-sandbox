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


## Edge client

## Downstream (calling) service 
cat <<EOT > /etc/systemd/system/edge-client.service
[Unit]
Description=edge-client
After=syslog.target network.target

[Service]
Environment=NAME="edge client"
Environment=MESSAGE="edge client"
Environment=UPSTREAM_URIS="http://localhost:10000"
Environment=LISTEN_ADDR="0.0.0.0:9100"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/systemd/system/edge-client-sidecar.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target
Wants=consul.service

[Service]
User=envoy
Group=envoy
Environment=CONSUL_HTTP_TOKEN=root
ExecStart=/usr/bin/consul connect envoy -sidecar-for edge-client -admin-bind 127.0.0.1:19010
ExecStopPost=+/usr/local/bin/consul-tproxy-cleanup
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/edge-client.hcl
service {
  name = "edge-client"
  port = 9100
  tags = ["on-prem"]

  checks = [
    {
      name = "HTTP API on port 9100"
      http = "http://127.0.0.1:9100/health"
      interval = "10s"
      timeout = "5s"
    }
  ]

  connect {
    sidecar_service {
      proxy {
        upstreams {
          destination_name = "cache"
          destination_peer = "aws"
          local_bind_port  = 10000
        }          
      }
    }
  }
  token = "root"
}
EOT


consul reload
systemctl daemon-reload
systemctl restart edge-client
systemctl restart edge-client-sidecar