resource "consul_config_entry" "exported_services_default" {
  kind      = "exported-services"
  name      = "default"
  partition = "default"

  config_json = jsonencode({
    Partition = "default"

    Services = [
      {
        Name      = "backend"
        Namespace = "default"
        Consumers = [
          {
            SamenessGroup = "failover"
          }
        ]
      }
    ]
  })
}

resource "consul_config_entry" "exported_services_database" {
  kind      = "exported-services"
  name      = "database"
  partition = "database"

  config_json = jsonencode({
    Partition = "database"

    Services = [
      {
        Name      = "database"
        Namespace = "default"
        Consumers = [
          {
            SamenessGroup = "failover"
          }
        ]
      },
      {
        Name      = "backend"
        Namespace = "default"
        Consumers = [
          {
            SamenessGroup = "failover"
          }
        ]
      }      
    ]
  })
}