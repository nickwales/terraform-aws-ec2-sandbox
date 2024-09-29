resource "consul_config_entry" "proxy_defaults" {
  kind = "proxy-defaults"
  name = "global"

  config_json = jsonencode({
    Config = {
      protocol = "http"
      handshake_timeout_ms = 10000
      PrioritizeByLocality = {
          Mode = "failover"
      }      
    }
    AccessLogs = {}
    Expose = {}
    MeshGateway = {}
    TransparentProxy = {}    
  })
}

resource "consul_config_entry" "proxy_defaults_database" {
  kind = "proxy-defaults"
  name = "global"
  partition = "database"

  config_json = jsonencode({
    Config = {
      protocol = "http"
      handshake_timeout_ms = 10000
    }
    AccessLogs = {}
    Expose = {}
    MeshGateway = {}
    TransparentProxy = {}    
  })
}