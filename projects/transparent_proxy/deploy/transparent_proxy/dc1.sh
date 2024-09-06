## This deploys
# A couple of services with transparent proxy

## Allow the ingress to talk to the "legacy service"
cat <<EOT > /root/downstream-intention.hcl
Kind = "service-intentions"
Name = "downstream"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  }
]
EOT

consul config write /root/downstream-intention.hcl

## Allow the ingress to talk to the "legacy service"
cat <<EOT > /root/downstream-intention.hcl
Kind = "service-intentions"
Name = "upstream"
Sources = [
  {
    Name   = "downstream"
    Action = "allow"
  }
]
EOT

consul config write /root/downstream-intention.hcl

### Setup transparent proxy scripts

cat << 'EOT' > /usr/local/bin/consul-tproxy-redirect
#!/usr/bin/env bash
set -o errexit

usage(){
  echo "Usage: $(basename "$0") <service_name>"
  exit 1
}

# Ensure a service name was provided
if [[ $# -eq 0 ]]; then
    usage
fi

# Obtain user IDs for consul and envoy
CONSUL_UID=$(id --user consul)
PROXY_UID=$(id --user envoy)

consul connect redirect-traffic \
    -proxy-id="${1}-sidecar-proxy" \
    -proxy-uid="${PROXY_UID}" \
    -exclude-uid="${CONSUL_UID}" \
    -exclude-inbound-port=22 \
    -exclude-inbound-port=1234 \
    -exclude-inbound-port=2345 \
    -exclude-inbound-port=3456 \
    -exclude-inbound-port=8500 \
    -exclude-inbound-port=8443 \
    -exclude-inbound-port=8444
EOT
chmod +x /usr/local/bin/consul-tproxy-redirect


cat << 'EOT' > /usr/local/bin/consul-tproxy-cleanup
#!/usr/bin/env bash
set -o errexit
iptables --table nat --flush
declare -a consul_chains=("INBOUND" "IN_REDIRECT" "OUTPUT" "REDIRECT")
for i in "${consul_chains[@]}"
do
  iptables --table nat --delete-chain "CONSUL_PROXY_${i}"
done
iptables --table nat --delete-chain "CONSUL_DNS_REDIRECT" || true
EOT
chmod +x /usr/local/bin/consul-tproxy-cleanup


### Install Apps 

## Downstream (calling) service 
cat <<EOT > /etc/systemd/system/downstream.service
[Unit]
Description=downstream
After=syslog.target network.target

[Service]
Environment=NAME="downstream"
Environment=MESSAGE="downstream"
Environment=UPSTREAM_URIS="http://upstream.virtual.consul,http://upstream.virtual.dc2.consul"
Environment=LISTEN_ADDR="0.0.0.0:9100"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT > /etc/consul.d/downstream.hcl
service {
  name = "downstream"
  port = 9100
  tags = ["vm", "t-proxy"]

  checks = [
    {
      name = "HTTP API on port 5000"
      http = "http://127.0.0.1:9100/health"
      interval = "10s"
      timeout = "5s"
    }
  ]

  connect {
    sidecar_service {
      proxy {
        mode = "transparent"
      }
    }
  }
  token = "${CONSUL_HTTP_TOKEN}"
}
EOT

cat <<EOT > /etc/systemd/system/downstream-sidecar.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target
Wants=consul.service

ConditionFileIsExecutable=/usr/local/bin/consul-tproxy-cleanup
ConditionFileIsExecutable=/usr/local/bin/consul-tproxy-redirect

[Service]
User=envoy
Group=envoy
Environment=CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}
ExecStartPre=+/usr/local/bin/consul-tproxy-redirect downstream
ExecStart=/usr/bin/consul connect envoy -sidecar-for downstream -admin-bind 127.0.0.1:19010
ExecStopPost=+/usr/local/bin/consul-tproxy-cleanup
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT


## Upstream service 
cat <<EOT > /etc/systemd/system/upstream.service
[Unit]
Description=upstream
After=syslog.target network.target

[Service]
Environment=NAME="upstream in dc1"
Environment=MESSAGE="upstream in dc1"
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
systemctl restart downstream
systemctl restart downstream-sidecar


## Create a TCP listener on port 3456 
cat <<EOT > /root/ingress.hcl
Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 3456
    Protocol = "tcp"
    Services = [
      {
        Name = "downstream"
      }
    ]
  }
]
EOT
consul config write /root/ingress.hcl