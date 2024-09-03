
resource "consul_config_entry" "api_gateway" {
  kind = "api-gateway"
  name = "api-gateway"

  config_json = jsonencode({
    Listeners = [
      {
        Name = "http-listener"
        Port = 8080
        Protocol = "http"
        TLS = {
          Certificates = null
        }
      }      
    ]    
  })
}


resource "consul_config_entry" "http_route_api_gateway" {
  kind = "http-route"
  name = "api-gateway"

  config_json = jsonencode({
    Parents = [
        {
            Kind = "api-gateway"
            Name = "api-gateway"
            SectionName = "http-listener"
        }
    ]

    Hostnames = [var.hostname]

    Rules = [
      {
        Filters = {
          Headers = null,
          URLRewrite = null
        }
        Matches = [
          {
            Headers = null
            Method = ""
            Path = {
              Match = "prefix"
              Value = "/"
            }
            Query = null
          }
        ]
        Services = [
          {
            Name = "test-mesh"
            Weight = 1
            Filters = {
              Headers = null
              URLRewrite = null
            }
          }
        ]
      }
    ]
  })
}