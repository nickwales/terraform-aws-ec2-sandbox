# Install Envoy
export envoy_version="1.24.1"
useradd envoy
curl https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
func-e use ${envoy_version}
cp /root/.func-e/versions/${envoy_version}/bin/envoy /usr/local/bin

export CONSUL_HTTP_TOKEN=root

# Install fake-service
mkdir -p /opt/fake-service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.24.2/fake_service_linux_amd64.zip
unzip -od /opt/fake-service/ fake_service_linux_amd64.zip
rm -f fake_service_linux_amd64.zip
chmod +x /opt/fake-service/fake-service



## "Database" service 
cat <<EOT > /etc/systemd/system/edge-database.service
[Unit]
Description=edge-database
After=syslog.target network.target

[Service]
Environment=NAME="edge-database on-prem"
Environment=MESSAGE="edge-database on-prem"
Environment=LISTEN_ADDR="0.0.0.0:9101"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/edge-database.hcl
service {
  name = "edge-database"
  port = 9101
  tags = ["vm", "database"]

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
  token = "root"
}
EOT

cat <<EOT > /etc/systemd/system/edge-database-sidecar.service
[Unit]
Description=Edge Database Sidecar
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=root
ExecStart=/usr/bin/consul connect envoy -sidecar-for edge-database -admin-bind 127.0.0.1:19011
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl restart edge-database
systemctl restart edge-database-sidecar

