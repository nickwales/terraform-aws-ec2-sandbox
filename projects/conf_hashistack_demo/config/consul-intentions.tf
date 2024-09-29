resource "consul_config_entry" "frontend_intention" {
  name = "frontend"
  kind = "service-intentions"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "gateway"
        Precedence = 9
        Type       = "consul"
        Namespace  = "default"
      }
    ]
  })
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
}

resource "consul_config_entry" "backend_intention" {
  kind = "service-intentions"
  name = "backend"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "frontend"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
}

resource "consul_config_entry" "redis_intention" {
  name = "redis"
  kind = "service-intentions"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "backend"
        Precedence = 9
        Type       = "consul"
        Namespace  = "default"
        
      }
    ]
  })
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
}

resource "consul_config_entry" "database_intention_default_ap" {
  kind = "service-intentions"
  name = "database"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "backend"
        Partition  = "default"
        Namespace  = "default"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
}


resource "consul_config_entry" "database_intention" {
  kind      = "service-intentions"
  name      = "database"

  partition = "database"

  config_json = jsonencode({
    Expose = false
    Sources = [
      {
        Action     = "allow"
        Name       = "backend"
        Partition  = "default"
        Namespace  = "default"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
}


## Enables intra sameness group communications
# resource "consul_config_entry" "failover_sg_intention_default_ap" {
#   kind      = "service-intentions"
#   name      = "failover"

#   config_json = jsonencode({
#     Expose = false
#     Sources = [
#       {
#         Action     = "allow"
#         Name       = "backend"
#         Precedence = 9
#         Type       = "consul"
#       }
#     ]
#   })
#   depends_on = [
#     consul_config_entry.proxy_defaults
#   ]
# }

# resource "consul_config_entry" "failover_sg_intention_database_ap" {
#   kind      = "service-intentions"
#   name      = "database"

#   partition = "database"

#   config_json = jsonencode({
#     Expose = false
#     Sources = [
#       {
#         Action     = "allow"
#         Name       = "backend"
#         Partition  = "default"
#         Namespace  = "default"
#         Precedence = 9
#         Type       = "consul"
#       }
#     ]
#   })
#   depends_on = [
#     consul_config_entry.proxy_defaults
#   ]
# }