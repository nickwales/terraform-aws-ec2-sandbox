resource "consul_config_entry" "frontend" {
  name = "frontend"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
    Expose      = {}
    MeshGateway = {}
    TransparentProxy = {}
  })
}

resource "consul_config_entry" "backend" {
  name = "backend"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
    Expose      = {}
    MeshGateway = {}
    TransparentProxy = {}
  })
}