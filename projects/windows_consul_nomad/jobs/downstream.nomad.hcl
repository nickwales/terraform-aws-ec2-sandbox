job "downstream" {

  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "downstream" {
    count = 1

    network {
      port "http" {
        static = 9091
        to     = 9090
      }
    }        

    service {
      name = "downstream"
      port = "http"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s" 
      }

      tags = [
          "traefik.enable=true",
          "traefik.http.routers.ingress.rule=(HostRegexp(`.*`))",
          "traefik.http.routers.ingress.entrypoints=http"
      ]
    }          

    task "downstream" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        ports = ["http"]
      }

      env {
        NAME = "downstream"
        MESSAGE = "Running on Linux"
        UPSTREAM_URIS = "http://service-on-windows.service.consul:9090"
      }                   
    }
  }
}
