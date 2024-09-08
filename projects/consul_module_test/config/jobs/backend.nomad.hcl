job "backend" {

  datacenters = ["dc1"]
  type = "service"

  group "backend" {
    count = 1

    network {
      mode = "bridge"
      port "expose" {}
    }        

    service {
      name = "backend"
      port = "9090"

      check {
        expose   = true
        type     = "http"
        path     = "/health"
        interval = "30s"
        timeout  = "5s"       
      }
      
      meta {
        version = "backend"
      }

      tags = ["backend"]

      connect {
        sidecar_service {
          proxy {
            transparent_proxy {}              
          }
        }  
      }
    }          

    task "backend" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"  
      }

      env {
        NAME = "backend"
        a = "d"
      }                   
    }
  }
}
