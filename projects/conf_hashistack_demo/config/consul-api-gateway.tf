resource "consul_config_entry" "api_gateway" {
  kind = "api-gateway"
  name = "gateway"
  namespace = "default"

  config_json = jsonencode({
    Listeners = [
      {
        Name = "http-listener"
        Port = 8088
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
  name = "gateway"
  namespace = "default"

  config_json = jsonencode({
    Parents = [
        {
            Kind = "api-gateway"
            Name = "gateway"
            SectionName = "http-listener"
        }
    ]

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
            Name = "frontend"
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