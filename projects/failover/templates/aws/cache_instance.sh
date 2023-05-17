# Set the consul token
export CONSUL_HTTP_TOKEN=root
echo CONSUL_HTTP_TOKEN=root >> /etc/environment

# Install Envoy
export envoy_version="1.24.1"
useradd envoy
curl https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
func-e use ${envoy_version}
cp /root/.func-e/versions/${envoy_version}/bin/envoy /usr/local/bin

# Install fake-service
mkdir -p /opt/fake-service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.24.2/fake_service_linux_amd64.zip
unzip -od /opt/fake-service/ fake_service_linux_amd64.zip
rm -f fake_service_linux_amd64.zip
chmod +x /opt/fake-service/fake-service



## "cache" service 
cat <<EOT > /etc/systemd/system/aws-cache.service
[Unit]
Description=aws-cache
After=syslog.target network.target

[Service]
Environment=NAME="aws-cache in ec2"
Environment=MESSAGE="aws-cache in ec2"
Environment=LISTEN_ADDR="0.0.0.0:9100"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/aws-cache.hcl
service {
  name = "aws-cache"
  port = 9100
  tags = ["aws", "cache"]

  checks = [
    {
      name = "HTTP API on port 9100"
      http = "http://127.0.0.1:9100/health"
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

cat <<EOT > /etc/systemd/system/aws-cache-sidecar.service
[Unit]
Description=AWS cache Sidecar
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=root
ExecStart=/usr/bin/consul connect envoy -sidecar-for aws-cache -admin-bind 127.0.0.1:19010
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl restart aws-cache
systemctl restart aws-cache-sidecar



