


```BASH
echo "Creating Vault agent config"
mkdir -p /etc/vault-agent.d/
cat <<EOF > /etc/vault-agent.d/config.hcl

pid_file = "./pidfile"

vault {
  address = "http://vault.service.consul:8200"
  retry {
    num_retries = 5
  }
}

auto_auth {
  method "aws" {
    mount_path = "auth/aws"
    config = {
      type = "iam"
      role = "esm"
    }
  }

  sink "file" {
    config = {
      path = "/tmp/sink"
    }
  }
}

cache {
  // An empty cache stanza still enables caching
}


listener "unix" {
  address = "/etc/vault-agent.d/agent.pid"
  tls_disable = true

  agent_api {
    enable_quit = true
  }
}

listener "tcp" {
  address = "127.0.0.1:8100"
  tls_disable = true
}

template {
  source = "/etc/consul-esm.d/token.hcl.ctmpl"
  destination = "/etc/consul-esm.d/token.hcl"
  # exec {
  #   command = ["consul-esm", "-config-file", "/etc/consul-esm.d/config.hcl"] 
  # }
}
EOF

echo "Creating ESM Config"
mkdir /etc/consul-esm.d

cat <<EOF > /etc/consul-esm.d/config.hcl
log_level = "INFO"
enable_syslog = false
log_json = false
instance_id = ""
consul_service = "consul-esm"
consul_service_tag = ""
consul_kv_path = "consul-esm/"
external_node_meta {
    "external-node" = "true"
}
node_reconnect_timeout = "72h"
node_probe_interval = "10s"
disable_coordinate_updates = false
http_addr = "localhost:8500"
datacenter = "dc1"
ca_path = "/etc/consul.d/certs/"
cert_file = ""
key_file = ""

ping_type = "udp"
passing_threshold = 0
critical_threshold = 0
EOF

cat <<EOF > /etc/consul-esm.d/token.hcl.ctmpl
{{ with secret "consul/creds/esm" }}
token = "{{ .Data.token }}"
{{ end }}
EOF


cat <<EOF > /etc/systemd/system/consul-esm.service
[Unit]
Description="HashiCorp Consul ESM"
Documentation=https://www.consul.io/
Requires=network-online.target
After=consul.service
ConditionFileNotEmpty=/etc/consul-esm.d/config.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul-esm agent -config-dir=/etc/consul-esm.d/
ExecReload=/bin/kill --signal SIGINT $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/consul-esm-watcher.path
[Path]
PathChanged=/etc/consul-esm.d/token.hcl

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/consul-esm-watcher.service
[Unit]
Description=ESM Restarter
After=network.target
StartLimitIntervalSec=10
StartLimitBurst=5

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart consul-esm.service

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now consul-esm-watcher.service
systemctl enable --now consul-esm-watcher.path
systemctl enable --now consul-esm.service
```