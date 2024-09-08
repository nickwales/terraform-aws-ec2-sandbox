resource "consul_config_entry" "proxy_defaults" {
  kind = "proxy-defaults"
  name = "global"

  config_json = jsonencode({
    Config = {
      protocol = "http"
      handshake_timeout_ms     = 10000

    }
    AccessLogs = {}
    Expose = {}
    MeshGateway = {}
    TransparentProxy = {}    
  })
}