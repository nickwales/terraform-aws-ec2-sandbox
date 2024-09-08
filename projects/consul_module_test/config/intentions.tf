resource "consul_config_entry" "frontend_intention" {
  name = "frontend"
  kind = "service-intentions"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "api-gateway"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "backend_intention" {
  name = "backend"
  kind = "service-intentions"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "frontend"
        Precedence = 9
        Type       = "consul"
      },
      {
        Action     = "allow"
        Name       = "api-gateway"
        Precedence = 9
        Type       = "consul"
      }      
    ]
  })
}