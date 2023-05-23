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



## "Database" service 
cat <<EOT > /etc/systemd/system/aws-database.service
[Unit]
Description=aws-database
After=syslog.target network.target

[Service]
Environment=NAME="aws-database in ec2"
Environment=MESSAGE="aws-database in ec2"
Environment=LISTEN_ADDR="0.0.0.0:9100"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/aws-database.hcl
service {
  name = "aws-database"
  port = 9100
  tags = ["aws", "database"]

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

cat <<EOT > /etc/systemd/system/aws-database-sidecar.service
[Unit]
Description=AWS Database Sidecar
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=root
ExecStart=/usr/bin/consul connect envoy -sidecar-for aws-database -admin-bind 127.0.0.1:19010
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl restart aws-database
systemctl restart aws-database-sidecar







### Remove hyphens

cat <<EOT > /etc/systemd/system/database.service
[Unit]
Description=database
After=syslog.target network.target

[Service]
Environment=NAME="aws database"
Environment=MESSAGE="aws database"
Environment=LISTEN_ADDR="0.0.0.0:9201"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/database.hcl
service {
  name = "database"
  port = 9201
  tags = ["vm", "database"]

  checks = [
    {
      name = "HTTP API on port 9201"
      http = "http://127.0.0.1:9201/health"
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
consul reload

cat <<EOT > /etc/systemd/system/database-sidecar.service
[Unit]
Description=Database Sidecar
After=syslog.target network.target

[Service]
Environment=CONSUL_HTTP_TOKEN=root
ExecStart=/usr/bin/consul connect envoy -sidecar-for database -admin-bind 127.0.0.1:19021
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

consul reload
systemctl daemon-reload
systemctl restart database
systemctl restart database-sidecar

