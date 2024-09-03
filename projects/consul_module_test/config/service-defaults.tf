resource "consul_config_entry" "test-mesh" {
  name = "test-mesh"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
    # Expose      = false
    # MeshGateway = "local"
    # TransparentProxy = true
  })
}