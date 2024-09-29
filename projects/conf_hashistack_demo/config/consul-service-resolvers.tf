resource "consul_config_entry" "redis_resolver" {
  kind = "service-resolver"
  name = "redis"
  
  config_json = jsonencode({
    prioritizeByLocality = {
      Mode = "failover"
    }
  })
}