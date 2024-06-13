<powershell>
# Install IIS
Install-WindowsFeature -name Web-Server -IncludeAllSubFeature  -IncludeManagementTools

# Allow anonymous auth on web configurations
# https://github.com/sevensolutions/nomad-iis?tab=readme-ov-file#-good-to-know--faq
Set-WebConfiguration //System.WebServer/Security/Authentication/anonymousAuthentication -metadata overrideMode -value Allow -PSPath IIS:/

# Set-Content "C:\\test.pfx" $iis_cert_file
# Import-PfxCertificate -FilePath "C:\\test.pfx" -CertStoreLocation Cert:\\LocalMachine\\My -Password (ConvertTo-SecureString -String 'Test123!' -AsPlainText -Force)

# # Install Hyper-V
# Install-WindowsFeature -Name Hyper-V -IncludeManagementTools 
# Install Docker
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
.\install-docker-ce.ps1 NoRestart

# Set the TLS version used by the PowerShell client to TLS 1.2.
#[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;


# Configure firewall rules
netsh advfirewall set publicprofile state off

# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install -y nano

$CONSUL_PATH="C:\consul"
$CONSUL_BIN_PATH="$CONSUL_PATH\bin"
$CONSUL_CONFIG_PATH="$CONSUL_PATH\conf"
$CONSUL_DATA_PATH="$CONSUL_PATH\data"
$CONSUL_LOG_PATH="$CONSUL_PATH\consul.log"
$CONSUL_CERTS_PATH="$CONSUL_PATH\certs"

$NOMAD_PATH="C:\nomad"
$NOMAD_BIN_PATH="$NOMAD_PATH\bin"
$NOMAD_CONFIG_PATH="$NOMAD_PATH\conf"
$NOMAD_DATA_PATH="$NOMAD_PATH\data"
$NOMAD_LOG_PATH="$NOMAD_PATH\nomad.log"
$NOMAD_CERTS_PATH="$NOMAD_PATH\certs"
$NOMAD_PLUGIN_PATH="$NOMAD_PATH\plugin"


New-Item -type directory $CONSUL_PATH
New-Item -type directory $CONSUL_CONFIG_PATH
New-Item -type directory $CONSUL_CERTS_PATH
New-Item -type directory $CONSUL_DATA_PATH
New-Item -type directory $CONSUL_BIN_PATH
New-Item -type directory $NOMAD_PATH
New-Item -type directory $NOMAD_CONFIG_PATH
New-Item -type directory $NOMAD_CERTS_PATH
New-Item -type directory $NOMAD_DATA_PATH
New-Item -type directory $NOMAD_BIN_PATH
New-Item -type directory $NOMAD_PLUGIN_PATH

# Write Consul Agent Cert
$consul_ca_file_test = @"
-----BEGIN CERTIFICATE-----
MIIC7jCCApSgAwIBAgIRAIn0Wic0Wl9GyYlyj/BDMUEwCgYIKoZIzj0EAwIwgbkx
CzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNj
bzEaMBgGA1UECRMRMTAxIFNlY29uZCBTdHJlZXQxDjAMBgNVBBETBTk0MTA1MRcw
FQYDVQQKEw5IYXNoaUNvcnAgSW5jLjFAMD4GA1UEAxM3Q29uc3VsIEFnZW50IENB
IDE4MzM3Mjk4NDM3ODk4MTExMzAwMDkxNTgxMjE3NDkxMjUwMDAzMzAeFw0yNDA2
MDYyMzA1NTdaFw0yOTA2MDUyMzA1NTdaMIG5MQswCQYDVQQGEwJVUzELMAkGA1UE
CBMCQ0ExFjAUBgNVBAcTDVNhbiBGcmFuY2lzY28xGjAYBgNVBAkTETEwMSBTZWNv
bmQgU3RyZWV0MQ4wDAYDVQQREwU5NDEwNTEXMBUGA1UEChMOSGFzaGlDb3JwIElu
Yy4xQDA+BgNVBAMTN0NvbnN1bCBBZ2VudCBDQSAxODMzNzI5ODQzNzg5ODExMTMw
MDA5MTU4MTIxNzQ5MTI1MDAwMzMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQl
XuDwwbEGMcMlU+s9O+vF+s+MAkTa1ge8NM4WKY19YVbWOBhYxFNLFEogZ9vZnrTE
S28nHKgUEV+rZHLvuTolo3sweTAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUw
AwEB/zApBgNVHQ4EIgQg09MWd8E8wBJLIZuxJ7hMv3gehKEA2oaWev6iCmT8gkUw
KwYDVR0jBCQwIoAg09MWd8E8wBJLIZuxJ7hMv3gehKEA2oaWev6iCmT8gkUwCgYI
KoZIzj0EAwIDSAAwRQIgRJiD8POwApcWOYb0YskI/HzcLoNIOH+hEotWP9xALOcC
IQCjaZoZfQDNL+oRRLs3AgJOmNZS6DNCnKhnd58Oja8Xmw==
-----END CERTIFICATE-----
"@
Set-Content -Path "$CONSUL_CERTS_PATH\consul-agent-ca.pem" -Value $consul_ca_file_test

# Download Consul
Invoke-WebRequest -Uri "https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_windows_amd64.zip" -OutFile "C:\consul.zip"
Expand-Archive C:\consul.zip -DestinationPath $CONSUL_BIN_PATH
Remove-Item C:\consul.zip

# Download Nomad    
cd $NOMAD_PATH
Invoke-WebRequest -Uri "https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_windows_amd64.zip" -OutFile "C:\nomad.zip"
Expand-Archive C:\nomad.zip -DestinationPath $NOMAD_BIN_PATH
Remove-Item C:\nomad.zip

# Download Nomad IIS Plugin
# Invoke-WebRequest -Uri "https://github.com/Roblox/nomad-driver-iis/releases/download/v0.1.0/win_iis.exe" -OutFile "C:\nomad\plugin\win_iis.exe"

Invoke-WebRequest -Uri "https://github.com/sevensolutions/nomad-iis/releases/download/v0.9.0/nomad_iis.zip" -OutFile "C:\nomad_iis.zip"
Expand-Archive C:\nomad_iis.zip -DestinationPath $NOMAD_PLUGIN_PATH
Remove-Item C:\nomad_iis.zip

# Add Consul and Nomad to path
$env:path =  $env:path + ";" + $CONSUl_BIN_PATH + ";" + $NOMAD_BIN_PATH
[System.Environment]::SetEnvironmentVariable('Path', $env:path,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('Path', $env:path,[System.EnvironmentVariableTarget]::Machine)


# Get Local IP
$HostIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

# Create Consul client configuration file
$consul_config = @"
datacenter = "${datacenter}"
data_dir = "C:\\consul\\data"
log_level = "INFO"
server = false
advertise_addr = "$${HostIP}"
bind_addr = "{{ GetDefaultInterfaces | exclude \"type\" \"IPv6\" | attr \"address\" }}"
client_addr = "0.0.0.0"
ui = true

telemetry {
  prometheus_retention_time = "10m"
  disable_hostname = true
}

acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    agent = "${consul_agent_token}"
    default = "${consul_agent_token}"
  }
}

encrypt = "${consul_encryption_key}"

auto_encrypt = {
  tls = true
}

tls {
  defaults {
    verify_incoming = false
    verify_outgoing = true
    ca_file = "C:\\consul\\certs\\consul-agent-ca.pem"
  }
}

ports = {
  grpc = 8502
  https = 8501
  grpc_tls = 8503
}

retry_join = ["provider=aws tag_key=role tag_value=consul-server-${datacenter}"]
"@

$nomad_config = @"
data_dir = "C:\\nomad\\data"

# Enable the server
client {
  enabled = true
  template {
    disable_file_sandbox = true
  }  
}

# tls {
#   http = true
#   rpc  = true

#   ca_file   = "nomad-agent-ca.pem"
#   cert_file = "global-server-nomad.pem"
#   key_file  = "global-server-nomad-key.pem"

#   verify_server_hostname = true
#   verify_https_client    = true
# }

### To do: enable talking to Consul over TLS 
consul {
  token = "${consul_token}"

  service_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }
  task_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }  
}

acl {
  enabled    = true
  token_ttl  = "30s"
  policy_ttl = "60s"
  role_ttl   = "60s"
}

vault {
  enabled   = ${vault_enabled}
  address   = "${vault_addr}"
  jwt_auth_backend_path = "${vault_jwt_path}"
}

plugin_dir = "C:\\nomad\\plugin"

plugin "raw_exec" {
  config {
    enabled = true
  }
}

plugin "win_iis" {
  config {
    enabled = true
    stats_interval = "30s"
  }
}

plugin "docker" {
  config {
    allow_caps = [
      "CHOWN", "DAC_OVERRIDE", "FSETID", "FOWNER", "MKNOD",
      "SETGID", "SETUID", "SETFCAP", "SETPCAP", "NET_BIND_SERVICE",
      "SYS_CHROOT", "KILL", "AUDIT_WRITE", "NET_RAW",
    ]
  }
}
"@

New-Item "$CONSUL_CONFIG_PATH\config.hcl"
Set-Content "$CONSUL_CONFIG_PATH\config.hcl" $consul_config

New-Item "$NOMAD_CONFIG_PATH\config.hcl"
Set-Content "$NOMAD_CONFIG_PATH\config.hcl" $nomad_config

## Setup Consul Service
$consulServiceParams = @{
  Name = "Consul"
  BinaryPathName = "C:\consul\bin\consul.exe agent -config-dir C:\consul\conf\"
  DisplayName = "Consul"
  StartupType = "Automatic"
  Description = "Consul - A service mesh solution"
}
New-Service @consulServiceParams
#Start-Service -Name Consul

## Setup Consul Service
$nomadServiceParams = @{
  Name = "Nomad"
  BinaryPathName = "C:\nomad\bin\nomad.exe agent -config C:\nomad\conf\config.hcl"
  DisplayName = "Nomad"
  StartupType = "Automatic"
  Description = "Nomad - The worlds best scheduler"
}
New-Service @nomadServiceParams
#Start-Service -Name Nomad

# Restart machine
Restart-Computer -Force
</powershell>
