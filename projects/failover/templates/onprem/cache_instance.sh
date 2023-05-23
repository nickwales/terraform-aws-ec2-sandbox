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



## Cache service

cat <<EOT > /etc/systemd/system/cache.service
[Unit]
Description=cache
After=syslog.target network.target

[Service]
Environment=NAME="edge cache"
Environment=MESSAGE="edge cache"
Environment=LISTEN_ADDR="0.0.0.0:9202"
Environment=UPSTREAM_URIS="http://localhost:10001"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/cache.hcl
service {
  name = "cache"
  port = 9202
  tags = ["vm", "cache"]

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
          destination_name = "database"
          local_bind_port  = 10001
        }           
      }      
    }
  }
  token = "root"
}
EOT

cat <<EOT > /etc/systemd/system/cache-sidecar.service
[Unit]
Description=Cache Sidecar
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=root
ExecStart=/usr/bin/consul connect envoy -sidecar-for cache -admin-bind 127.0.0.1:19021
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl restart cache
systemctl restart cache-sidecar