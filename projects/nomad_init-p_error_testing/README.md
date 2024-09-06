

### Deploy packages

Run this on client and server
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt install nomad=1.7.6-1
```

### Client

```
mkdir -p /site/apps/nomad/config
mkdir -p /site/apps/java/bin

cp /usr/bin/nomad /site/apps/nomad/nomad

cat <<EOT > /site/apps/nomad/config/nomad.hcl
bind_addr = "0.0.0.0"
client {
  enabled = true
  server_join {
        retry_join = ["provider=aws tag_key=Name tag_value=jumpbox-server"]
  }
  chroot_env = {
    "/bin" =   "/bin"
    "/etc" =   "/etc"
    "/lib" =   "/lib"
    "/lib32" =   "/lib32"
    "/lib64" =   "/lib64"
    "/run/resolvconf" =   "/run/resolvconf"
    "/sbin" =   "/sbin"
    "/usr" =   "/usr"
    "/site/apps/java" =   "/site/apps/java"

  }
}
EOT

# Edit /lib/systemd/system/nomad.service 
sed -i 's#ExecStart=.*#ExecStart=/bin/bash -c "PATH=/site/apps/java/bin:$PATH exec /site/apps/nomad/nomad agent -log-level=DEBUG -config=/site/apps/nomad/config"#g' /lib/systemd/system/nomad.service

systemctl daemon-reload
systemctl restart nomad
```

### Server 

```
cat <<EOT > /etc/nomad.d/nomad.hcl
data_dir = "/opt/nomad"

# Enable the server
server {
  enabled = true
  bootstrap_expect = 1
}
EOT

systemctl restart nomad

cat <<EOT > /root/sleep.hcl
job "sleep" {
  type = "batch"

  group "sleep" {
    count = 1

    task "sleep" {
      driver = "exec"

      config {
        command  = "sleep"
        args = ["10"]
      }
    }
  }
}
EOT

nomad job run /root/sleep.hcl
```


