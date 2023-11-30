job "upstream" {

  datacenters = ["dc1"]
  type = "service"

  group "upstream" {
    count = 1

    network {
        port "http" {
          to     = "9091"
        }

    }        
    service {
      name = "upstream"
      port = "9091"

      check {
        type     = "http"
        port     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }

      connect {
          sidecar_service {}
      }      
    }          

    task "upstream" {
      driver = "docker"

      config {
        image   = "nicholasjackson/fake-service:v0.26.0"
        ports   = ["http"]
      }

      env {
        LISTEN_ADDR = "0.0.0.0:9091"
      }

      identity {
        env = false
        file = true
      }               
    }
  }
}

